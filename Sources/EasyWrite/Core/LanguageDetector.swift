import Foundation
import NaturalLanguage

/// On-device language identification (Apple's NaturalLanguage framework), limited to the
/// languages Easy Write supports so short snippets aren't mistaken for unrelated languages.
enum LanguageDetector {
    struct Guess: Equatable {
        let code: String
        let confidence: Double
    }

    private static let map: [NLLanguage: String] = [
        .german: "de", .french: "fr", .spanish: "es", .italian: "it", .portuguese: "pt",
        .dutch: "nl", .turkish: "tr", .polish: "pl", .russian: "ru", .english: "en",
        .japanese: "ja", .simplifiedChinese: "zh", .traditionalChinese: "zh", .arabic: "ar",
    ]

    static func detect(_ text: String) -> Guess? {
        let r = NLLanguageRecognizer()
        r.languageConstraints = Array(map.keys)
        r.processString(text)
        guard let (lang, p) = r.languageHypotheses(withMaximum: 1).first,
              let code = map[lang] else { return nil }
        return Guess(code: code, confidence: p)
    }

    /// Only trust a guess when there is enough text to go on. One or two words ("OK", a name)
    /// are too ambiguous to flip the translation direction on.
    static func isReliable(_ guess: Guess, for text: String) -> Bool {
        guard guess.confidence >= 0.8 else { return false }
        if ["ja", "zh"].contains(guess.code) { return text.count >= 4 }
        return wordCount(text) >= 3
    }

    static func wordCount(_ text: String) -> Int {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        return tokenizer.tokens(for: text.startIndex..<text.endIndex).count
    }
}
