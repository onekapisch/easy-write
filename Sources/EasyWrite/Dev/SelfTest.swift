import Foundation

/// Dev tool: `EasyWrite --selftest` checks the logic that would fail silently if it broke:
/// long-text splitting, shared-link validation, settings migration, and Bar search.
/// No model, no UI, no real settings. Exits non-zero on any failure (release.sh relies on it).
@MainActor
enum SelfTest {
    private static var failures = 0
    private static var passes = 0

    static func run() -> Int32 {
        pieces()
        actionLinks()
        migration()
        barSearch()
        studio()
        print("\n\(passes) passed, \(failures) failed")
        return failures == 0 ? 0 : 1
    }

    private static func check(_ ok: Bool, _ name: String) {
        if ok { passes += 1; print("  ✓ \(name)") } else { failures += 1; print("  ✗ \(name)") }
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
