import Foundation
import AppKit
import ApplicationServices

/// Dev tool: `EasyWrite --selftest` checks the logic that would fail silently if it broke:
/// long-text splitting, shared-link validation, settings migration, and Bar search.
/// No model, no UI, no real settings. Exits non-zero on any failure (release.sh relies on it).
@MainActor
enum SelfTest {
    private static var failures = 0
    private static var passes = 0

    static func run() async -> Int32 {
        pieces()
        actionLinks()
        migration()
        barSearch()
        studio()
        privacyDefaults()
        clipboardOwnership()
        selectionSafety()
        historyPrivacy()
        await requestSafety()
        contextBudget()
        print("\n\(passes) passed, \(failures) failed")
        return failures == 0 ? 0 : 1
    }

    private static func check(_ ok: Bool, _ name: String) {
        if ok { passes += 1; print("  ✓ \(name)") } else { failures += 1; print("  ✗ \(name)") }
    }

    private static func privacyDefaults() {
        let suite = "com.onekapisch.easywrite.selftest.privacy"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }
        check(!Store(defaults: defaults, legacy: nil).historyEnabled, "history needs explicit opt-in")
        defaults.set(true, forKey: "historyEnabled")
        check(!Store(defaults: defaults, legacy: nil).historyEnabled, "old implicit history setting is not consent")
    }

    private static func clipboardOwnership() {
        let pb = NSPasteboard.withUniqueName()
        defer { pb.releaseGlobally() }
        pb.setString("before", forType: .string)
        // A private pasteboard and injected keyboard sender never touch the real clipboard.
        var restores: [() -> Void] = []
        let element = AXUIElementCreateApplication(100)
        let target = Replacer.SelectionTarget(pid: 100, element: element, window: element,
                                              range: CFRange(location: 0, length: 4), text: "text")
        var sent = 0
        var valid = true
        let replacer = Replacer(pasteboard: pb, command: { _ in sent += 1 },
                                schedule: { restores.append($0) }, targetIsCurrent: { _ in valid })
        check(replacer.replaceSelection(with: "selection", target: target), "verified target sends paste")
        pb.clearContents(); pb.setString("new user copy", forType: .string)
        replacer.restoreClipboard()
        check(pb.string(forType: .string) == "new user copy", "restore preserves a newer user copy")
        _ = replacer.replaceSelection(with: "result", target: target)
        pb.clearContents(); pb.setString("copy during paste", forType: .string)
        restores.forEach { $0() }
        check(pb.string(forType: .string) == "copy during paste", "delayed restore preserves external clipboard changes")
        _ = replacer.replaceSelection(with: "last", target: target)
        replacer.restoreClipboard()
        check(pb.string(forType: .string) == "copy during paste", "unchanged clipboard restores original formats")
        valid = false
        let previous = sent
        check(!replacer.replaceSelection(with: "unsafe", target: target) && sent == previous,
              "invalid target sends no paste")
        check(pb.string(forType: .string) == "copy during paste", "invalid target leaves clipboard unchanged")
        var validations = 0
        let racing = Replacer(pasteboard: pb, command: { _ in sent += 1 }, schedule: { restores.append($0) },
                              targetIsCurrent: { _ in validations += 1; return validations == 1 })
        check(!racing.replaceSelection(with: "unsafe", target: target) && sent == previous,
              "target change during clipboard preparation sends no paste")
        check(pb.string(forType: .string) == "copy during paste", "aborted paste restores owned temporary data")
    }

    private static func selectionSafety() {
        let element = AXUIElementCreateApplication(100)
        let other = AXUIElementCreateApplication(101)
        let target = Replacer.SelectionTarget(pid: 100, element: element, window: element,
                                              range: CFRange(location: 2, length: 4), text: "text")
        check(Replacer.sameSelection(target, target), "same field and selection are eligible")
        var changed = target
        changed.element = other
        check(!Replacer.sameSelection(target, changed), "different field blocks replacement")
        changed = target; changed.window = other
        check(!Replacer.sameSelection(target, changed), "different window blocks replacement")
        changed = target; changed.range.location += 1
        check(!Replacer.sameSelection(target, changed), "moved selection blocks replacement")
        changed = target; changed.text = "edit"
        check(!Replacer.sameSelection(target, changed), "edited text blocks replacement")
        changed = target; changed.pid = 101
        check(!Replacer.sameSelection(target, changed), "different process blocks replacement")
        check(!Replacer.sameSelection(nil, target) && !Replacer.sameSelection(target, nil),
              "unverifiable targets never auto-paste")
    }

    private static func historyPrivacy() {
        let suite = "com.onekapisch.easywrite.selftest.history"
        let d = UserDefaults(suiteName: suite)!
        d.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("ew-history-\(UUID())")
        defer { d.removePersistentDomain(forName: suite); try? FileManager.default.removeItem(at: directory) }
        let store = Store(defaults: d, legacy: nil)
        var now = Date()
        let history = HistoryStore(directory: directory, store: store, clock: { now }, monitor: false)
        let entry = HistoryEntry(kind: .translate, label: "Test", appName: "Test", source: "sample", result: "example")
        history.add(entry, bundleID: "test")
        check(history.entries.isEmpty, "disabled history never records text")
        store.historyEnabled = true
        history.add(entry, bundleID: "test")
        check(history.entries.count == 1, "explicit consent enables history")
        let historyFile = directory.appendingPathComponent("history.json")
        let mode = (try? FileManager.default.attributesOfItem(atPath: historyFile.path)[.posixPermissions]) as? NSNumber
        check(mode?.intValue == 0o600, "history file is owner-readable and writable only")
        let dirMode = (try? FileManager.default.attributesOfItem(atPath: directory.path)[.posixPermissions]) as? NSNumber
        check(dirMode?.intValue == 0o700, "history directory is restricted to its owner")
        check(Store(defaults: d, legacy: nil).historyEnabled, "explicit consent persists across launches")
        history.add(entry, bundleID: "com.apple.Passwords")
        check(history.entries.count == 1, "excluded apps never enter history")
        now = now.addingTimeInterval(8 * 86_400)
        history.prune()
        check(history.entries.isEmpty, "retention removes expired entries")
        history.add(HistoryEntry(kind: .read, label: "Test", appName: "Test", source: "new", result: "new"), bundleID: "test")
        store.historyEnabled = false
        check(history.entries.isEmpty, "disabling history immediately removes stored text")
        let file = directory.appendingPathComponent("history.json")
        check(!FileManager.default.fileExists(atPath: file.path), "disabled history removes the history file")
    }

    private static func requestSafety() async {
        let start = Date()
        do {
            let _: String = try await RequestDeadline.value(seconds: 0.03) {
                // This continuation ignores cancellation, like an uncooperative framework call.
                await withCheckedContinuation { c in
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) { c.resume(returning: "too late") }
                }
            }
            check(false, "stalled requests time out")
        } catch is RequestDeadline.Expired {
            check(Date().timeIntervalSince(start) < 0.5, "deadline does not wait for a stalled producer")
        } catch { check(false, "deadline reports a timeout, not an unrelated error") }
        do {
            let result = try await RequestDeadline.value(seconds: 1) { "ready" }
            check(result == "ready", "completed requests beat the deadline")
        } catch { check(false, "completed request should succeed") }
        let cancelled = Task {
            try await RequestDeadline.value(seconds: 5) {
                try await Task.sleep(nanoseconds: 5_000_000_000)
                return "late"
            }
        }
        await Task.yield()
        cancelled.cancel()
        do { _ = try await cancelled.value; check(false, "cancelled requests do not return text") }
        catch is CancellationError { check(true, "cancelled requests stop promptly") }
        catch { check(false, "cancelled request reports cancellation") }
    }

    private static func contextBudget() {
        check(!LLMTranslator.outputFits(tokenCount: 1536), "token-capped responses are rejected")
        check(!LLMTranslator.outputFits(tokenCount: 1504), "near-cap output is rejected conservatively")
        check(LLMTranslator.outputFits(tokenCount: 100), "short completed output is accepted")
        do {
            let allowance = try LLMTranslator.inputAllowance(instructionTokens: 800)
            check(allowance + 800 + LLMTranslator.responseReserve + 256 == 4096,
                  "context budget reserves instructions, output and framing")
        } catch { check(false, "ordinary instructions fit") }
        do {
            _ = try LLMTranslator.inputAllowance(instructionTokens: 4_000)
            check(false, "oversized glossary and style notes must be rejected")
        } catch { check(true, "oversized glossary and style notes are rejected before generation") }
    }

    // MARK: Long text

    private static func pieces() {
        print("Long text")
        let short = "Hello there.\n\nSecond line."
        check(LLMTranslator.pieces(short) == [.init(text: short, separator: "")], "short text is one piece")

        // Paragraphs separated by blank lines, long enough to need several pieces.
        let para = String(repeating: "Lorem ipsum dolor sit amet. ", count: 20)         // ~560 chars
        let text = [para, "", para, "", "", para, para].joined(separator: "\n")
        let ps = LLMTranslator.pieces(text, limit: 1_200)
        check(ps.count > 1, "long text splits into \(ps.count) pieces")
        check(ps.allSatisfy { $0.text.count <= 1_200 }, "every piece fits the limit")
        check(ps.map { $0.text + $0.separator }.joined() == text, "pieces rebuild the exact original, blank lines included")

        // One paragraph longer than the limit splits by sentence.
        let long = String(repeating: "This is one sentence of many. ", count: 80)        // ~2,400 chars, no newlines
        let lp = LLMTranslator.pieces(long, limit: 1_000)
        check(lp.count >= 3 && lp.allSatisfy { $0.text.count <= 1_000 }, "a single long paragraph splits by sentence")
        check(lp.dropLast().allSatisfy { $0.separator == " " } && lp.last?.separator == "", "sentence pieces rejoin with spaces")

        let (lead, body, trail) = LLMTranslator.splitWhitespace("\n\nHallo Welt\n")
        check(lead == "\n\n" && body == "Hallo Welt" && trail == "\n", "leading and trailing blank lines are kept around a piece")
        check(LLMTranslator.splitWhitespace("\n \n").1.isEmpty, "a whitespace-only piece has no body to translate")
    }

    // MARK: Shared actions

    private static func actionLinks() {
        print("Shared action links")
        let a = WriteAction(name: "Reply politely", instruction: "Antworte kurz, “herzlich”. Ü ß 日本語",
                            output: .replace, shortcut: .init(keyCode: 15, modifiers: 6144))
        guard let share = ActionLink.shareURL(for: a), let app = ActionLink.appURL(for: a) else {
            check(false, "links can be built"); return
        }
        check(share.absoluteString.hasPrefix(ActionLink.pageBase + "#reply-politely."), "share link has a readable slug")
        let back = ActionLink.decode(share)
        check(back?.name == a.name && back?.instruction == a.instruction, "share link round-trips, Unicode included")
        check(back?.output == .popup && back?.shortcut == nil, "imported actions start in popup mode with no shortcut")
        check(ActionLink.decode(app)?.name == a.name, "easywrite:// link round-trips")

        func link(_ json: String) -> URL {
            let b = Data(json.utf8).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
            return URL(string: "easywrite://action?d=" + b)!
        }
        check(ActionLink.decode(link(#"{"v":1,"n":"Fine","i":"Do it","o":"popup"}"#)) != nil, "a valid hand-made link is accepted")
        check(ActionLink.decode(link(#"{"v":2,"n":"Fine","i":"Do it","o":"popup"}"#)) == nil, "unknown versions are rejected")
        check(ActionLink.decode(link(#"{"v":1,"n":"","i":"Do it","o":"popup"}"#)) == nil, "empty names are rejected")
        check(ActionLink.decode(link(#"{"v":1,"n":"Two\nlines","i":"Do it","o":"popup"}"#)) == nil, "names with line breaks are rejected")
        check(ActionLink.decode(link("{\"v\":1,\"n\":\"Safe\u{202E}evil\",\"i\":\"Do it\",\"o\":\"popup\"}")) == nil,
              "bidirectional overrides are rejected")
        let zalgo = "a" + String(repeating: "\u{0301}", count: 1_200)                     // one visible character
        check(ActionLink.decode(link("{\"v\":1,\"n\":\"Z\",\"i\":\"\(zalgo)\",\"o\":\"popup\"}")) == nil,
              "limits count Unicode scalars, so stacked accents can't hide a huge instruction")
        check(ActionLink.decode(URL(string: "easywrite://action?d=%%%")!) == nil, "garbage doesn't crash and is rejected")
        check(ActionLink.decode(URL(string: "https://evil.example/products/easy-write/action/#x." + "eyJ2IjoxfQ")!) == nil,
              "links from other sites are ignored")
    }

    // MARK: Migration from 1.x

    private static func migration() {
        print("Settings migration from 1.x")
        // Throwaway domains on both sides: a real 1.x install's settings are never read or written.
        let oldSuite = "com.onekapisch.easywrite.selftest.v1"
        let newSuite = "com.onekapisch.easywrite.selftest"
        UserDefaults.standard.removePersistentDomain(forName: oldSuite)
        let old = UserDefaults(suiteName: oldSuite)!
        defer { UserDefaults.standard.removePersistentDomain(forName: oldSuite)
                UserDefaults.standard.removePersistentDomain(forName: newSuite) }
        UserDefaults.standard.removePersistentDomain(forName: newSuite)

        let enc = { (m: [String: Store.Shortcut]) in try! JSONEncoder().encode(m) }
        old.set("fr", forKey: "targetLanguageCode")
        old.set(true, forKey: "previewBeforeReplace")
        old.set("Use Mail, not E-Mail.", forKey: "styleGuide")
        old.set(enc([
            "formal":   .init(keyCode: 17, modifiers: 2304),     // v1 default ⌥⌘T: dropped
            "informal": .init(keyCode: 34, modifiers: 2304),     // v1 default ⌥⌘I: dropped
            "plain":    .init(keyCode: 3, modifiers: 6144),      // custom ⌃⌥F: kept as Natural
            "english":  .init(keyCode: 40, modifiers: 2304),     // custom ⌥⌘K: clashes with the Bar, dropped
        ]), forKey: "shortcuts")

        let s = Store(defaults: UserDefaults(suiteName: newSuite)!, legacy: old)
        check(s.targetCode == "fr" && s.previewBeforeReplace, "language and preview carry over")
        check(s.toneNotes == "Use Mail, not E-Mail.", "the 1.x style guide becomes style notes")
        check(s.shortcut(for: .translate)?.keyCode == 17, "⌥⌘T is the two-way translate key")
        check(s.shortcut(for: .formal) == nil && s.shortcut(for: .informal) == nil, "old default shortcuts are not carried over")
        check(s.shortcut(for: .natural) == .init(keyCode: 3, modifiers: 6144), "a custom shortcut is kept in its new slot")
        check(s.shortcut(for: .bar)?.keyCode == 40 && s.shortcut(for: .read)?.keyCode == 14,
              "a migrated shortcut that clashes with a 2.0 default is dropped")
        check(s.duplicateLabels().isEmpty, "no shortcut is assigned twice after migration")
    }

    // MARK: Studio block (ported from Mac 4 Breakfast's StudioDay tests)

    private static func studio() {
        print("Studio")
        let stops = StudioDay.stops
        check(stops.map(\.id) == ["tokens-4-breakfast", "mac-4-breakfast", "lumel", "skylocation",
                                  "clip-4-breakfast", "easy-write"], "roster order matches the site")
        let minutes = stops.map { s -> Int in
            let p = s.time.split(separator: ":").compactMap { Int($0) }
            return p.count == 2 ? p[0] * 60 + p[1] : -1
        }
        check(!minutes.contains(-1) && zip(minutes, minutes.dropFirst()).allSatisfy { $0 < $1 },
              "times parse and ascend through the day")
        check(StudioDay.currentStop?.name == "Easy Write", "the glow sits on Easy Write")
        check(Set(stops.map(\.imageName)).count == stops.count, "every stop has its own tile")
        let missing = (stops.map(\.imageName) + ["studio_icon_onekapisch"]).filter { StudioDay.image($0) == nil }
        check(missing.isEmpty, "every tile ships" + (missing.isEmpty ? "" : " (missing: \(missing.joined(separator: ", ")))"))

        let fractions = (0..<StudioDay.slotCount).map { StudioDay.fraction(forSlot: $0) }
        let gaps = zip(fractions, fractions.dropFirst()).map { $1 - $0 }
        check(StudioDay.slotCount == stops.count + 1 && fractions.allSatisfy { $0 > 0 && $0 < 1 },
              "a slot for each app plus “much more”, all inside the strip")
        check(gaps.allSatisfy { abs($0 - gaps[0]) < 0.0001 }, "slots are evenly spaced, not clock-proportional")

        guard let url = StudioDay.url(for: "lumel", site: "https://getlumel.app"),
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            check(false, "outbound link builds"); return
        }
        let q = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
        check(q == ["source_product": "easy-write", "surface": "about-day-strip", "target_product": "lumel",
                    "campaign": "studio-network", "placement_version": "1"],
              "outbound links carry exactly the studio's five attribution parameters")
        check(stops.allSatisfy { StudioDay.url(for: $0.id, site: $0.site)?.host != nil }
              && StudioDay.studioURL?.host?.contains("onekapisch") == true, "every link resolves")
        check(stops.allSatisfy { $0.tagline.hasSuffix(".") }, "taglines are all present")
    }

    // MARK: Bar search

    private static func barSearch() {
        print("Bar search")
        check(BarModel.matches(["ger", "inf"], "German de Informal du"), "\"ger inf\" finds German · Informal")
        check(BarModel.matches(["du"], "German de Informal du"), "a pronoun finds its tone")
        check(!BarModel.matches(["ger", "for"], "German de Informal du"), "every typed word has to match")
        check(BarModel.matches(["fix"], "Fix grammar"), "actions are found by name")
    }
}
