import Foundation

/// Detects formal second-person forms leaking into a translation that was asked to be informal.
///
/// German only, on purpose. German capitalises nouns, sentence starts, and the formal
/// `Sie`/`Ihr` forms — and nothing else. That makes a *mid-sentence* capitalised `Sie` or
/// `Ihre` a high-precision signal for formal address. The same trick does not transfer:
/// French `vous` and Spanish `ustedes` are also the ordinary plural forms, so flagging them
/// would fire constantly on correct output. Better to check one language well than five badly.
enum RegisterCheck {

    struct Result {
        /// Capitalised formal markers found mid-sentence. These are near-certain leaks.
        var definite: [String] = []
        /// Formal markers at a sentence start, where `Sie`/`Ihr` collides with a capitalised
        /// `sie` (she/they) / `ihr` (her/their). Reported for human review, not scored.
        var ambiguous: [String] = []

        var hasDefiniteLeak: Bool { !definite.isEmpty }
    }

    /// Formal second-person forms in German. All are capitalised when used as formal address.
    private static let germanFormalForms = [
        "Sie", "Ihnen", "Ihr", "Ihre", "Ihrem", "Ihren", "Ihrer", "Ihres",
    ]

    /// Characters that mean "the next word starts a sentence", so its capitalisation is
    /// grammatical rather than a formal-address marker.
    private static let sentenceEnders: Set<Character> = [
        ".", "!", "?", ":", ";", "\n", "\r", "\"", "“", "”", "„", "(", "[", "–", "-", "*",
    ]

    static func check(_ text: String, languageCode: String, expecting register: LLMTranslator.Register?) -> Result {
        // Only meaningful when we explicitly asked for informal German.
        guard languageCode == "de", register == .informal else { return Result() }

        var result = Result()
        for form in germanFormalForms {
            for range in occurrences(of: form, in: text) {
                if isSentenceInitial(range.lowerBound, in: text) {
                    result.ambiguous.append(form)
                } else {
                    result.definite.append(form)
                }
            }
        }
        return result
    }

    /// Whole-word, case-*sensitive* occurrences (lowercase `sie`/`ihr` are not formal markers).
    private static func occurrences(of word: String, in text: String) -> [Range<String.Index>] {
        var found: [Range<String.Index>] = []
        var searchStart = text.startIndex
        while let range = text.range(of: word, options: [.literal], range: searchStart..<text.endIndex) {
            if isWholeWord(range, in: text) { found.append(range) }
            searchStart = range.upperBound
        }
        return found
    }

    private static func isWholeWord(_ range: Range<String.Index>, in text: String) -> Bool {
        let isBoundary: (Character) -> Bool = { !$0.isLetter && $0 != "-" }
        if range.lowerBound > text.startIndex {
            let before = text[text.index(before: range.lowerBound)]
            if !isBoundary(before) { return false }
        }
        if range.upperBound < text.endIndex {
            let after = text[range.upperBound]
            if !isBoundary(after) { return false }
        }
        return true
    }

    /// True when only whitespace and an opening/terminating punctuation mark precede the word.
    private static func isSentenceInitial(_ index: String.Index, in text: String) -> Bool {
        var i = index
        while i > text.startIndex {
            i = text.index(before: i)
            let c = text[i]
            if c.isWhitespace { continue }
            return sentenceEnders.contains(c)
        }
        return true   // start of the string
    }
}
