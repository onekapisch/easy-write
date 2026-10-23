import AppKit
import ApplicationServices

/// Every way of using Easy Write (hot-keys, panel tiles, the Bar, the reader card, the welcome
/// practice field) goes through here, so permission checks, the HUD, history and stats behave
/// the same everywhere.
@MainActor
final class Runner {
    static let shared = Runner()
    static let didReplace = Notification.Name("EasyWriteDidReplace")

    let replacer = Replacer()
    private let llm = LLMTranslator.shared
    private let hud = NotchHUD.shared
    private var store: Store { Store.shared }

    /// The last app that was frontmost before Easy Write, kept by AppDelegate.
    weak var lastApp: NSRunningApplication?

    private var currentJob: Task<Void, Never>?

    /// Text the user selected, and where it came from.
    struct Captured {
        let text: String
        let app: NSRunningApplication?
        let appName: String
        let bundleID: String?
        let words: Int
        let detected: LanguageDetector.Guess?
        let anchor: NSRect?
        let mouse: NSPoint

        var isOwnApp: Bool { bundleID == Bundle.main.bundleIdentifier && bundleID != nil }
    }

    /// Where ⌥⌘T goes for a given selection.
    struct Plan {
        let lang: Lang
        let tone: Tone
        let reversed: Bool
        var label: String { reversed ? "\(lang.name) · translated back" : "\(lang.name) · \(tone.title)" }
    }

    enum Delivery {
        case replace
        case reader(ReaderPanel.Header, speech: String, editable: Bool)
    }

    // MARK: Entry points

    /// ⌥⌘T. Into the target language, or back into your own when the text is already in it.
    func translateSmart() {
        guard let c = capture() else { return }
        let plan = plan(for: c)
        if store.previewBeforeReplace {
            BarController.shared.show(c, preselect: .translate(code: plan.lang.code, tone: plan.tone))
            return
        }
        perform(.translate(plan.lang, plan.tone), c, label: plan.label, kind: .translate,
                language: plan.lang.code, memory: nil, delivery: .replace)
    }

    /// Optional direct shortcuts for one tone. Remembered for the app it was used in.
    func translate(tone: Tone) {
        guard let c = capture() else { return }
        let lang = Languages.named(store.preference(for: c.bundleID)?.code ?? store.targetCode)
        if store.previewBeforeReplace {
            BarController.shared.show(c, preselect: .translate(code: lang.code, tone: tone))
            return
        }
        perform(.translate(lang, tone), c, label: "\(lang.name) · \(tone.title)", kind: .translate,
                language: lang.code, memory: (lang.code, tone), delivery: .replace)
    }

    /// ⌥⌘E. Into your own language, shown in the reader card.
    func read() {
        guard let c = capture() else { return }
        let home = Languages.named(store.homeCode)
        var target = home
        if let g = c.detected, g.code == home.code, LanguageDetector.isReliable(g, for: c.text) {
            // Already in your language: show it in the language you write to instead.
            let t = Languages.named(store.targetCode)
            target = t.code == home.code ? Languages.named("en") : t
        }
        let from = c.detected.flatMap { $0.confidence >= 0.5 ? Languages.named($0.code).name : nil }
        let header = ReaderPanel.Header.translation(from: from == target.name ? nil : from, to: target.name)
        perform(.translate(target, .natural), c, label: target.name, kind: .read, language: target.code,
                memory: nil, delivery: .reader(header, speech: target.code, editable: replacer.focusedIsEditable()))
    }

    func run(_ action: WriteAction) {
        guard let c = capture() else { return }
        let delivery: Delivery = action.output == .replace && !store.previewBeforeReplace
            ? .replace
            : .reader(.action(action.name), speech: c.detected?.code ?? store.homeCode,
                      editable: replacer.focusedIsEditable())
        perform(.transform(action.instruction), c, label: action.name, kind: .action,
                language: nil, memory: nil, delivery: delivery)
    }

    /// ⌥⌘K.
    func openBar() {
        guard let c = capture() else { return }
        BarController.shared.show(c, preselect: nil)
    }

    func plan(for c: Captured) -> Plan {
        let pref = store.preference(for: c.bundleID)
        let target = Languages.named(pref?.code ?? store.targetCode)
        let tone = pref?.tone ?? store.defaultTone
        if store.twoWay, let g = c.detected, g.code == target.code, LanguageDetector.isReliable(g, for: c.text) {
            var home = Languages.named(store.homeCode)
            if home.code == target.code { home = Languages.named("en") }
            if home.code != target.code { return Plan(lang: home, tone: .natural, reversed: true) }
        }
        return Plan(lang: target, tone: tone, reversed: false)
    }

    // MARK: Finishing (also used by the Bar and the reader card)

    /// Pastes over the selection. Only into the app the text came from: if the user switched
    /// away while the model was working, the result goes on the clipboard instead of into
    /// whatever window happens to be in front now.
    func deliverReplace(_ result: String, _ c: Captured, label: String, kind: HistoryEntry.Kind,
                        language: String?, memory: (String, Tone)?, recordHistory: Bool = true) {
        let front = NSWorkspace.shared.frontmostApplication
        if let app = c.app, !c.isOwnApp, front?.processIdentifier != app.processIdentifier {
            replacer.copyForUser(result)
            hud.problem("You switched apps, so it’s on your clipboard")
            return
        }
        replacer.replaceSelection(with: result)
        hud.done("Replaced", detail: c.words == 1 ? "1 word" : "\(c.words) words", keycap: "⌘Z", hint: "to undo")
        if let m = memory { store.remember(code: m.0, tone: m.1, for: c.bundleID, appName: c.appName) }
        if recordHistory {
            record(result, c, label: label, kind: kind, language: language, replaced: true)
        } else {
            store.recordUse(words: 0, language: nil, app: nil, replaced: true)
        }
        NotificationCenter.default.post(name: Self.didReplace, object: nil)
    }

    func deliverCopy(_ result: String, _ c: Captured, label: String, kind: HistoryEntry.Kind,
                     language: String?, memory: (String, Tone)?) {
        replacer.copyForUser(result)
        hud.done("Copied", detail: label)
        if let m = memory { store.remember(code: m.0, tone: m.1, for: c.bundleID, appName: c.appName) }
        record(result, c, label: label, kind: kind, language: language, replaced: false)
    }

    func record(_ result: String, _ c: Captured, label: String, kind: HistoryEntry.Kind,
                language: String?, replaced: Bool) {
        guard !c.isOwnApp else { return }                // the welcome practice doesn't count
        store.recordUse(words: c.words, language: language, app: c.bundleID, replaced: replaced)
        HistoryStore.shared.add(HistoryEntry(kind: kind, label: label, appName: c.appName,
                                             source: c.text, result: result), bundleID: c.bundleID)
    }

    // MARK: Private

    /// Checks prerequisites, then copies the selection from the right app. Every early exit
    /// says why in the HUD, so a shortcut never silently does nothing.
    private func capture() -> Captured? {
        // Any Easy Write shortcut pressed while a job runs stops it. Long text can take a
        // while, and there should always be a way out.
        if AppState.shared.busy {
            currentJob?.cancel()
            hud.problem("Stopped")
            return nil
        }
        guard !BarController.shared.isOpen else { return nil }
        guard AXIsProcessTrusted() else {
            hud.problem("Easy Write needs Accessibility")
            WelcomeController.shared.show()
            return nil
        }
        if let reason = llm.unavailableReason { hud.problem(reason.short); return nil }

        // Our own welcome window holds a practice field; anywhere else in Easy Write, the user
        // means the app they were in before.
        let ownTarget = NSApp.isActive && NSApp.keyWindow?.identifier == WelcomeController.windowID
        var reactivated: NSRunningApplication?
        if NSApp.isActive && !ownTarget, let prev = lastApp {
            prev.activate()
            usleep(150_000)
            reactivated = prev
        }
        // frontmostApplication updates through the run loop, which the sleep above blocks, so
        // right after reactivating it can still report Easy Write. Use the app we activated.
        let app = ownTarget ? NSRunningApplication.current : (reactivated ?? NSWorkspace.shared.frontmostApplication)
        let mouse = NSEvent.mouseLocation
        guard let text = replacer.copySelection(),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            replacer.restoreClipboard()
            hud.problem("Select some text first")
            return nil
        }
        return Captured(text: text, app: app, appName: app?.localizedName ?? "this app",
                        bundleID: app?.bundleIdentifier, words: LanguageDetector.wordCount(text),
                        detected: LanguageDetector.detect(text), anchor: replacer.selectionBounds(), mouse: mouse)
    }

    private func perform(_ job: LLMTranslator.Job.Kind, _ c: Captured, label: String, kind: HistoryEntry.Kind,
                         language: String?, memory: (String, Tone)?, delivery: Delivery) {
        let job: LLMTranslator.Job = switch job {
        case .translate(let lang, let tone): .translate(lang, tone)
        case .transform(let instruction):    .transform(instruction)
        }
        AppState.shared.busy = true
        hud.working(label)
        currentJob = Task { @MainActor in
            defer { AppState.shared.busy = false; currentJob = nil }
            do {
                let result = try await llm.run(c.text, job: job) { i, n in
                    self.hud.working(label, detail: "part \(i) of \(n)")
                }
                try Task.checkCancellation()           // stopped while the last piece finished
                switch delivery {
                case .replace:
                    deliverReplace(result, c, label: label, kind: kind, language: language, memory: memory)
                case .reader(let header, let speech, let editable):
                    replacer.restoreClipboard()
                    hud.hide()
                    ReaderPanel.shared.show(result, original: c.text, header: header, speechCode: speech,
                                            canReplace: editable, at: c.mouse) {
                        self.deliverReplace(result, c, label: label, kind: kind, language: language,
                                            memory: memory, recordHistory: false)
                    }
                    record(result, c, label: label, kind: kind, language: language, replaced: false)
                }
            } catch is CancellationError {
                replacer.restoreClipboard()            // the HUD already says "Stopped"
            } catch {
                replacer.restoreClipboard()
                hud.problem(LLMTranslator.describe(error))
            }
        }
    }
}
