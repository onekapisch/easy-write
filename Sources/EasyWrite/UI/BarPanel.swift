import AppKit
import FoundationModels
import SwiftUI

/// A panel that takes keyboard input without activating Easy Write. The app the user was
/// typing in stays frontmost with its selection intact, so Replace pastes straight back.
final class KeyPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class BarModel: ObservableObject {
    struct Item: Identifiable, Equatable {
        enum Kind: Equatable {
            case translate(code: String, tone: Tone)
            case action(UUID)
            case ask(String)
        }
        enum Group: String { case translate = "Translate", actions = "Actions", ask = "Ask" }

        let kind: Kind
        let group: Group
        let title: String
        var subtitle: String? = nil
        var badge: String? = nil
        var shortcut: String? = nil

        var id: String {
            switch kind {
            case .translate(let code, let tone): "t-\(code)-\(tone.rawValue)"
            case .action(let id):                "a-\(id)"
            case .ask:                           "ask"
            }
        }
        var symbol: String {
            switch group {
            case .translate: "globe"
            case .actions:   "sparkles"
            case .ask:       "text.bubble"
            }
        }
    }

    enum Preview: Equatable {
        case idle
        case streaming(String)
        case ready(String)
        case failed(String)

        var text: String? {
            switch self {
            case .streaming(let s), .ready(let s): s
            default: nil
            }
        }
    }

    enum Commit { case replace, copy }

    @Published private(set) var captured: Runner.Captured?
    @Published var query = "" { didSet { if query != oldValue { rebuild(); schedulePreview() } } }
    @Published private(set) var items: [Item] = []
    @Published var selectedID: String? { didSet { if selectedID != oldValue { schedulePreview() } } }
    @Published private(set) var preview: Preview = .idle

    var onFinish: ((Commit, String, Item, Runner.Captured) -> Void)?

    private var previewTask: Task<Void, Never>?
    private var pending: Commit?
    private var varied = false

    var selected: Item? { items.first { $0.id == selectedID } }

    var detectedName: String? {
        guard let g = captured?.detected, g.confidence >= 0.5 else { return nil }
        return Languages.named(g.code).name
    }

    func load(_ c: Runner.Captured, preselect: Item.Kind?, startPreview: Bool = true) {
        captured = c
        pending = nil
        varied = false
        query = ""
        rebuild()
        if let preselect, let match = items.first(where: { $0.kind == preselect }) {
            selectedID = match.id
        }
        if startPreview { schedulePreview(immediately: true) } else { previewTask?.cancel() }
    }

    func reset() {
        previewTask?.cancel()
        captured = nil
        preview = .idle
        pending = nil
    }

    func move(_ delta: Int) {
        guard !items.isEmpty else { return }
        let i = items.firstIndex { $0.id == selectedID } ?? 0
        selectedID = items[(i + delta + items.count) % items.count].id
    }

    func select(_ item: Item) { selectedID = item.id }

    /// Replace or copy as soon as the result is ready; if it's still streaming, finish then.
    func commit(_ c: Commit) {
        guard selected != nil else { return }
        switch preview {
        case .ready(let text): finish(c, text)
        case .failed: pending = c; schedulePreview(immediately: true)
        case .idle, .streaming: pending = c
            if case .idle = preview { schedulePreview(immediately: true) }
        }
    }

    func tryAgain() {
        varied = true
        schedulePreview(immediately: true)
    }

    // MARK: Building the list

    private func rebuild() {
        guard let c = captured else { items = []; return }
        let store = Store.shared
        let pref = store.preference(for: c.bundleID)
        let target = Languages.named(pref?.code ?? store.targetCode)
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var list: [Item] = []

        if q.isEmpty {
            let first = pref?.tone ?? store.defaultTone
            for tone in [first] + Tone.allCases.filter({ $0 != first }) {
                list.append(translateItem(target, tone, badge: pref?.tone == tone ? pref?.appName : nil))
            }
            let home = Languages.named(store.homeCode)
            if home.code != target.code, c.detected?.code != home.code {
                list.append(translateItem(home, .natural))
            }
            list += store.actions.map(actionItem)
        } else {
            let tokens = q.split(separator: " ").map(String.init)
            for lang in Languages.all {
                for tone in Tone.allCases {
                    let hay = "\(lang.name) \(lang.code) \(tone.title) \(tone.pronoun(in: lang) ?? "")"
                    if Self.matches(tokens, hay) { list.append(translateItem(lang, tone)) }
                }
            }
            list += store.actions.filter { Self.matches(tokens, $0.name) }.map(actionItem)
            list.append(Item(kind: .ask(query), group: .ask, title: query,
                             subtitle: "Run as an instruction"))
        }
        items = list
        if !list.contains(where: { $0.id == selectedID }) { selectedID = list.first?.id }
    }

    private func translateItem(_ lang: Lang, _ tone: Tone, badge: String? = nil) -> Item {
        Item(kind: .translate(code: lang.code, tone: tone), group: .translate,
             title: "\(lang.name) · \(tone.title)", subtitle: tone.pronoun(in: lang), badge: badge)
    }

    private func actionItem(_ a: WriteAction) -> Item {
        Item(kind: .action(a.id), group: .actions, title: a.name, shortcut: a.shortcut?.label)
    }

    /// Every typed word must start some word of the item: "ger inf" finds German · Informal.
    static func matches(_ tokens: [String], _ haystack: String) -> Bool {
        let words = haystack.lowercased().split { !$0.isLetter && !$0.isNumber }
        return tokens.allSatisfy { t in words.contains { $0.hasPrefix(t) } }
    }

    // MARK: Preview

    func job(for item: Item) -> LLMTranslator.Job? {
        switch item.kind {
        case .translate(let code, let tone):
            return .translate(Languages.named(code), tone, varied: varied)
        case .action(let id):
            guard let a = Store.shared.actions.first(where: { $0.id == id }) else { return nil }
            return .transform(a.instruction, varied: varied)
        case .ask(let s):
            let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return s.isEmpty ? nil : .transform(s, varied: varied)
        }
    }

    private func schedulePreview(immediately: Bool = false) {
        previewTask?.cancel()
        guard let c = captured, let item = selected, let job = job(for: item) else { preview = .idle; return }
        let delay: UInt64 = immediately ? 0 : (item.group == .ask ? 650_000_000 : 260_000_000)
        previewTask = Task { @MainActor [weak self] in
            if delay > 0 { try? await Task.sleep(nanoseconds: delay) }
            guard let self, !Task.isCancelled else { return }
            await self.stream(c.text, job: job, retryIfBusy: true)
        }
    }

    private func stream(_ text: String, job: LLMTranslator.Job, retryIfBusy: Bool) async {
        preview = .streaming("")
        do {
            var last = ""
            for try await partial in LLMTranslator.shared.stream(text, job: job) {
                if Task.isCancelled { return }
                last = partial
                preview = .streaming(partial)
            }
            guard !Task.isCancelled else { return }
            preview = .ready(last)
            if let p = pending { finish(p, last) }
        } catch is CancellationError {
        } catch let error as LanguageModelSession.GenerationError {
            // Switching items quickly can overlap with the previous request winding down.
            if retryIfBusy, case .concurrentRequests = error {
                try? await Task.sleep(nanoseconds: 300_000_000)
                if !Task.isCancelled { await stream(text, job: job, retryIfBusy: false) }
            } else if !Task.isCancelled {
                preview = .failed(LLMTranslator.describe(error)); pending = nil
            }
        } catch {
            if !Task.isCancelled { preview = .failed(LLMTranslator.describe(error)); pending = nil }
        }
    }

    private func finish(_ c: Commit, _ text: String) {
        guard let item = selected, let captured else { return }
        pending = nil
        onFinish?(c, text, item, captured)
    }

    /// Used by `--snapshots` to show a finished preview without running the model.
    func setSnapshotPreview(_ p: Preview) { previewTask?.cancel(); preview = p }
}

@MainActor
final class BarController {
    static let shared = BarController()

    let model = BarModel()
    private var panel: KeyPanel?
    private var keyMonitor: Any?
    private var resignObserver: NSObjectProtocol?
    private var closing = false

    var isOpen: Bool { panel?.isVisible == true }

    static let size = NSSize(width: 700, height: 430)
    private static let margin: CGFloat = 28            // room for the shadow around the glass

    init() {
        model.onFinish = { [weak self] commit, text, item, captured in
            self?.finish(commit, text, item, captured)
        }
    }

    func show(_ c: Runner.Captured, preselect: BarModel.Item.Kind?) {
        model.load(c, preselect: preselect)
        let p = panel ?? makePanel()
        position(p, anchor: c.anchor, mouse: c.mouse)
        closing = false
        p.makeKeyAndOrderFront(nil)
        installMonitor()
    }

    func close(restoreClipboard: Bool) {
        guard !closing else { return }
        closing = true
        if let m = keyMonitor { NSEvent.removeMonitor(m); keyMonitor = nil }
        panel?.orderOut(nil)
        model.reset()
        if restoreClipboard { Runner.shared.replacer.restoreClipboard() }
    }

    private func finish(_ commit: BarModel.Commit, _ text: String, _ item: BarModel.Item, _ c: Runner.Captured) {
        close(restoreClipboard: false)
        let label: String
        let kind: HistoryEntry.Kind
        var language: String?
        var memory: (String, Tone)?
        switch item.kind {
        case .translate(let code, let tone):
            label = item.title; kind = .translate; language = code; memory = (code, tone)
        case .action:
            label = item.title; kind = .action
        case .ask(let s):
            label = "Ask: \(s)"; kind = .ask
        }
        // Give the source app a moment to take keyboard focus back before pasting.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            switch commit {
            case .replace:
                Runner.shared.deliverReplace(text, c, label: label, kind: kind, language: language, memory: memory)
            case .copy:
                Runner.shared.replacer.restoreClipboard()
                Runner.shared.deliverCopy(text, c, label: label, kind: kind, language: language, memory: memory)
            }
        }
    }

    private func makePanel() -> KeyPanel {
        let m = Self.margin
        let p = KeyPanel(contentRect: NSRect(x: 0, y: 0, width: Self.size.width + m * 2, height: Self.size.height + m * 2),
                         styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
                         backing: .buffered, defer: true)
        p.isFloatingPanel = true
        p.level = .floating
        p.hidesOnDeactivate = false
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.appearance = NSAppearance(named: .darkAqua)
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        p.contentView = NSHostingView(rootView: BarView(model: model,
                                                        close: { [weak self] in self?.close(restoreClipboard: true) })
            .padding(m))
        resignObserver = NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification,
                                                                object: p, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.close(restoreClipboard: true) }   // clicked elsewhere
        }
        panel = p
        return p
    }

    /// Just below the selection when the app reports where it is, otherwise near the pointer.
    private func position(_ panel: NSPanel, anchor: NSRect?, mouse: NSPoint) {
        let m = Self.margin
        let full = NSSize(width: Self.size.width + m * 2, height: Self.size.height + m * 2)
        let ref = anchor.map { NSPoint(x: $0.minX, y: $0.minY) } ?? mouse
        let screen = NSScreen.screens.first { NSMouseInRect(ref, $0.frame, false) } ?? NSScreen.main
        let vf = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)

        var origin: NSPoint
        if let a = anchor {
            origin = NSPoint(x: a.minX - m, y: a.minY - 10 - full.height + m)
            if origin.y + m < vf.minY { origin.y = a.maxY + 10 - m }          // no room below: open above
        } else {
            origin = NSPoint(x: mouse.x - full.width / 2, y: mouse.y - full.height - 6 + m)
        }
        origin.x = min(max(origin.x, vf.minX - m + 8), vf.maxX - full.width + m - 8)
        origin.y = min(max(origin.y, vf.minY - m + 8), vf.maxY - full.height + m - 8)
        panel.setFrame(NSRect(origin: origin, size: full), display: false)
    }

    /// Arrow keys, Return, Esc, ⌘C and ⌘R work no matter which control has focus.
    private func installMonitor() {
        if let m = keyMonitor { NSEvent.removeMonitor(m) }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
            guard let self, let panel = self.panel, e.window === panel else { return e }
            let cmd = e.modifierFlags.contains(.command)
            switch (e.keyCode, cmd) {
            case (126, false): self.model.move(-1); return nil                // ↑
            case (125, false): self.model.move(1); return nil                 // ↓
            case (36, _), (76, _): self.model.commit(.replace); return nil    // Return / Enter
            case (53, _): self.close(restoreClipboard: true); return nil      // Esc
            case (8, true): self.model.commit(.copy); return nil              // ⌘C
            case (15, true): self.model.tryAgain(); return nil                // ⌘R
            default: return e
            }
        }
    }
}

struct BarView: View {
    @ObservedObject var model: BarModel
    var close: () -> Void
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            top
            Divider().overlay(Color.white.opacity(0.07))
            HStack(spacing: 0) {
                list.frame(width: 330)
                Divider().overlay(Color.white.opacity(0.07))
                previewPane
            }
            Divider().overlay(Color.white.opacity(0.07))
            footer
        }
        .frame(width: BarController.size.width, height: BarController.size.height)
        .ewGlass()
        .environment(\.colorScheme, .dark)
        .onAppear { searchFocused = true }
    }

    // MARK: Parts

    private var top: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Text("Selection").foregroundStyle(EW.dim)
                Text("“\(model.captured?.text.replacingOccurrences(of: "\n", with: " ") ?? "")”")
                    .foregroundStyle(Color(hex: 0xDAD7E8)).lineLimit(1).truncationMode(.tail)
                Spacer(minLength: 8)
                HStack(spacing: 5) {
                    if let d = model.detectedName { chip(d) }
                    if let w = model.captured?.words { chip(w == 1 ? "1 word" : "\(w) words") }
                    if let a = model.captured?.appName { chip(a) }
                }
            }
            .font(.system(size: 11.5))

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").font(.system(size: 16)).foregroundStyle(Color(hex: 0xA39FB8))
                TextField("", text: $model.query, prompt: Text("Translate, rewrite, or describe a change").foregroundStyle(EW.faint))
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .foregroundStyle(EW.text)
                    .focused($searchFocused)
                    .accessibilityLabel("Search languages and actions, or type an instruction")
                Button(action: close) { Keycap(text: "esc") }.buttonStyle(.plain).accessibilityLabel("Close")
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var list: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(model.items.enumerated()), id: \.element.id) { i, item in
                        if i == 0 || model.items[i - 1].group != item.group {
                            Text(item.group.rawValue.uppercased())
                                .font(.system(size: 10, weight: .semibold)).tracking(0.7)
                                .foregroundStyle(Color(hex: 0x7D7993))
                                .padding(.horizontal, 16).padding(.top, i == 0 ? 8 : 12).padding(.bottom, 4)
                                .accessibilityAddTraits(.isHeader)
                        }
                        row(item).id(item.id)
                    }
                    if model.query.isEmpty {
                        Text("Type anything else to run it once as an instruction")
                            .font(.system(size: 12)).foregroundStyle(Color(hex: 0x7D7993))
                            .padding(.horizontal, 16).padding(.vertical, 8)
                    }
                }
                .padding(.bottom, 8)
            }
            .onChange(of: model.selectedID) { _, id in
                if let id { withAnimation(.easeOut(duration: 0.12)) { proxy.scrollTo(id, anchor: .center) } }
            }
        }
    }

    private func row(_ item: BarModel.Item) -> some View {
        let on = item.id == model.selectedID
        return Button { model.select(item); model.commit(.replace) } label: {
            HStack(spacing: 10) {
                IconSquare(symbol: item.symbol, tint: item.group == .actions ? EW.pink : item.group == .ask ? EW.blue : EW.accentText)
                Text(item.title).font(.system(size: 13)).foregroundStyle(EW.text).lineLimit(1)
                if let s = item.subtitle { Text(s).font(.system(size: 12)).foregroundStyle(EW.dim).lineLimit(1) }
                Spacer(minLength: 6)
                if let b = item.badge {
                    Text(b).font(.system(size: 10.5)).foregroundStyle(EW.accentText)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(EW.accent.opacity(0.18), in: RoundedRectangle(cornerRadius: 5))
                        .help("Remembered for \(b)")
                }
                if let s = item.shortcut { Keycap(text: s, size: 10) }
                if on { Keycap(text: "↩", size: 10) }
            }
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background {
                if on {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(EW.accent.opacity(0.24))
                        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(EW.accent.opacity(0.5)))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .accessibilityLabel(item.title + (item.subtitle.map { ", \($0)" } ?? ""))
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private var previewPane: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 7) {
                StatusDot(color: previewDotColor)
                Text(previewTitle).font(.system(size: 11.5)).foregroundStyle(EW.dim).lineLimit(1)
            }
            ScrollView {
                Group {
                    switch model.preview {
                    case .idle:
                        Text(model.selected?.group == .ask ? "Type an instruction, then press ↩." : "")
                            .foregroundStyle(EW.faint)
                    case .streaming(let s):
                        Text("\(s)\(Text(" ▍").foregroundStyle(EW.accent))").foregroundStyle(Color(hex: 0xF3F1FA))
                    case .ready(let s):
                        Text(s).foregroundStyle(Color(hex: 0xF3F1FA)).textSelection(.enabled)
                    case .failed(let msg):
                        Text(msg).foregroundStyle(EW.warn)
                    }
                }
                .font(.system(size: 16))
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(model.preview.text.map { "Preview: \($0)" } ?? "No preview yet")
            }
            HStack(spacing: 10) {
                Text("On-device")
                Text("Nothing changes until you press ↩")
            }
            .font(.system(size: 11)).foregroundStyle(Color(hex: 0x7D7993))
            HStack(spacing: 6) {
                Button { model.commit(.replace) } label: { Label("Replace", systemImage: "arrow.turn.down.left") }
                    .buttonStyle(EWButtonStyle(kind: .primary))
                Button { model.commit(.copy) } label: { Label("Copy", systemImage: "doc.on.doc") }
                    .buttonStyle(EWButtonStyle())
                Button { model.tryAgain() } label: { Label("Try again", systemImage: "arrow.clockwise") }
                    .buttonStyle(EWButtonStyle())
                    .disabled(model.preview.text == nil)
            }
            .labelStyle(.titleAndIcon)
            .disabled(model.selected == nil)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var previewTitle: String {
        guard let item = model.selected else { return "Preview" }
        switch item.kind {
        case .translate(let code, let tone):
            return "Preview · \(Languages.named(code).name), \(tone.title.lowercased())"
        case .action, .ask:
            return "Preview · \(item.group == .ask ? "your instruction" : item.title)"
        }
    }

    private var previewDotColor: Color {
        switch model.preview {
        case .ready: EW.good
        case .failed: EW.warn
        case .streaming: EW.accent
        case .idle: EW.faint
        }
    }

    private var footer: some View {
        HStack(spacing: 16) {
            hint("↑↓", "choose"); hint("↩", "replace"); hint("⌘C", "copy"); hint("⌘R", "try again"); hint("esc", "close")
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 9)
    }

    private func hint(_ key: String, _ text: String) -> some View {
        HStack(spacing: 5) {
            Keycap(text: key, size: 10)
            Text(text).font(.system(size: 11)).foregroundStyle(Color(hex: 0x7D7993))
        }
    }

    private func chip(_ s: String) -> some View {
        Text(s).foregroundStyle(EW.dim)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 5))
    }
}
