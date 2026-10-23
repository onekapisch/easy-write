import Foundation

/// How formal a translation should be. `natural` keeps the tone of the source text.
enum Tone: String, Codable, CaseIterable, Identifiable {
    case formal, informal, natural

    var id: String { rawValue }

    var title: String {
        switch self {
        case .formal:   "Formal"
        case .informal: "Informal"
        case .natural:  "Natural"
        }
    }

    var register: LLMTranslator.Register? {
        switch self {
        case .formal:   .formal
        case .informal: .informal
        case .natural:  nil
        }
    }

    /// The pronoun that marks this tone in a language, e.g. "du" for German informal.
    func pronoun(in lang: Lang) -> String? {
        switch self {
        case .formal:   lang.formal
        case .informal: lang.informal
        case .natural:  nil
        }
    }
}

/// A user instruction bound to a shortcut, run on the selection by the on-device model.
struct WriteAction: Codable, Identifiable, Equatable {
    enum Output: String, Codable, CaseIterable {
        case replace, popup
        var title: String { self == .replace ? "Replace selection" : "Show in popup" }
    }

    var id = UUID()
    var name: String
    var instruction: String
    var output: Output
    var shortcut: Store.Shortcut?

    static let presets: [WriteAction] = [
        WriteAction(name: "Fix grammar",
                    instruction: "Correct spelling, grammar and punctuation. Keep the wording, tone and language "
                               + "the same, and change as little as possible.",
                    output: .replace,
                    shortcut: .init(keyCode: 5, modifiers: KeyDisplay.option | KeyDisplay.cmd)),   // ⌥⌘G
        WriteAction(name: "Make it shorter",
                    instruction: "Make this shorter and clearer. Keep every fact and the same language and tone.",
                    output: .replace, shortcut: nil),
        WriteAction(name: "Reply politely",
                    instruction: "Write a short, warm reply to this message in the same language. Answer any "
                               + "question in it. Keep it under three sentences.",
                    output: .popup,
                    shortcut: .init(keyCode: 15, modifiers: KeyDisplay.control | KeyDisplay.option)), // ⌃⌥R
        WriteAction(name: "Explain the grammar",
                    instruction: "Explain in simple English how the grammar of this sentence works, including "
                               + "word order and any formal or informal forms. Use short bullet points.",
                    output: .popup, shortcut: nil),
        WriteAction(name: "Sound native",
                    instruction: "Rewrite this so it sounds like natural, idiomatic English written by a native "
                               + "speaker. Keep the meaning and the level of formality.",
                    output: .replace, shortcut: nil),
        WriteAction(name: "Japanese keigo",
                    instruction: "Translate this into polite business Japanese using appropriate keigo.",
                    output: .replace, shortcut: nil),
    ]
}

/// A term the user always wants translated a particular way, e.g. "E-Mail" → "Mail".
struct GlossaryTerm: Codable, Identifiable, Equatable {
    var id = UUID()
    var source: String
    var target: String
}

/// What Easy Write remembers about one app: the language and tone last used there.
struct AppPreference: Codable, Equatable {
    var code: String
    var tone: Tone
    var appName: String
}

/// Counts shown in the menu-bar panel. Kept on this Mac only.
struct UsageStats: Codable, Equatable {
    var swaps = 0
    var words = 0
    var languages: Set<String> = []
    var apps: Set<String> = []
}

struct HistoryEntry: Codable, Identifiable, Equatable {
    enum Kind: String, Codable { case translate, read, action, ask }
    var id = UUID()
    var date = Date()
    var kind: Kind
    var label: String          // "German · Informal", "Fix grammar", …
    var appName: String
    var source: String
    var result: String
}

/// Encodes an action as a link people can share, and reads one back.
///
/// The shared link points at a recipe page on onekapisch.com. The recipe travels in the URL
/// fragment, so the page needs no server and nothing about the action is ever sent anywhere:
/// browsers do not include the fragment in requests. "Add to Easy Write" on that page opens
/// `easywrite://action?d=…`, which the app handles with a confirmation step.
enum ActionLink {
    static let pageBase = "https://www.onekapisch.com/products/easy-write/action/"
    static let maxName = 60
    static let maxInstruction = 1_000

    private struct Payload: Codable {
        var v = 1
        var n: String
        var i: String
        var o: String
    }

    static func shareURL(for action: WriteAction) -> URL? {
        guard let blob = encode(action) else { return nil }
        return URL(string: pageBase + "#" + slug(action.name) + "." + blob)
    }

    static func appURL(for action: WriteAction) -> URL? {
        guard let blob = encode(action) else { return nil }
        return URL(string: "easywrite://action?d=" + blob)
    }

    /// Accepts `easywrite://action?d=…` and the https share link (`…/action/#slug.blob`).
    /// Imported actions never carry a shortcut, and always start in popup mode, so nothing
    /// replaces text until the user has seen what the action does.
    static func decode(_ url: URL) -> WriteAction? {
        var blob: String?
        if url.scheme == "easywrite" {
            blob = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first { $0.name == "d" }?.value
        } else if url.absoluteString.hasPrefix(pageBase), let fragment = url.fragment {
            blob = fragment.split(separator: ".").last.map(String.init)
        }
        guard let blob, blob.count <= 8_000, let data = base64URLDecode(blob),
              let p = try? JSONDecoder().decode(Payload.self, from: data), p.v == 1 else { return nil }
        let name = p.n.trimmingCharacters(in: .whitespacesAndNewlines)
        let instruction = p.i.trimmingCharacters(in: .whitespacesAndNewlines)
        // Limits count Unicode scalars, not visible characters: stacked combining marks could
        // otherwise hide a huge instruction behind a short-looking one.
        guard !name.isEmpty, !instruction.isEmpty,
              name.unicodeScalars.count <= maxName, instruction.unicodeScalars.count <= maxInstruction,
              !name.unicodeScalars.contains(where: { isControl($0) || isDirectional($0) }),
              !instruction.unicodeScalars.contains(where: isDirectional)
        else { return nil }
        return WriteAction(name: name, instruction: instruction, output: .popup, shortcut: nil)
    }

    /// Line breaks, tabs and other control characters have no place in a name and could
    /// make the confirmation dialog misleading.
    private static func isControl(_ s: Unicode.Scalar) -> Bool {
        CharacterSet.controlCharacters.contains(s)
    }

    /// Bidirectional overrides and marks can visually reorder text, so what the confirmation
    /// dialog shows would not be what runs.
    private static func isDirectional(_ s: Unicode.Scalar) -> Bool {
        (0x202A...0x202E).contains(s.value) || (0x2066...0x2069).contains(s.value)
            || s.value == 0x200E || s.value == 0x200F || s.value == 0x061C
    }

    private static func encode(_ a: WriteAction) -> String? {
        let p = Payload(n: String(String.UnicodeScalarView(a.name.unicodeScalars.prefix(maxName))),
                        i: String(String.UnicodeScalarView(a.instruction.unicodeScalars.prefix(maxInstruction))),
                        o: a.output.rawValue)
        guard let data = try? JSONEncoder().encode(p) else { return nil }
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func base64URLDecode(_ s: String) -> Data? {
        var b = s.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while b.count % 4 != 0 { b += "=" }
        return Data(base64Encoded: b)
    }

    private static func slug(_ name: String) -> String {
        let s = name.lowercased().map { $0.isLetter || $0.isNumber ? $0 : "-" }
        return String(s).split(separator: "-").joined(separator: "-")
    }
}
