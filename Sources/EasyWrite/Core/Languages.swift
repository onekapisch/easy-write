import Foundation

struct Lang: Identifiable {
    var id: String { code }
    let code: String
    let name: String
    /// Short pronoun label shown in the menu (e.g. "Sie").
    let formal: String?
    /// Short pronoun label shown in the menu (e.g. "du").
    let informal: String?
    /// Optional per-language guidance appended to the model instruction (e.g. dialect choice).
    var note: String? = nil

    /// Full register instruction handed to the model. The pronoun label alone is not enough:
    /// picking "du" is the part the model already gets right. It leaks formality in the
    /// *rest* of the paradigm — possessives and imperatives — so spell the whole thing out.
    var formalSpec: String? = nil
    var informalSpec: String? = nil
}

enum Languages {
    static let all: [Lang] = [
        Lang(code: "de", name: "German",     formal: "Sie",      informal: "du",
             formalSpec: "Use the Sie-form consistently: Sie (subject), Ihnen (dative), "
                       + "Ihr/Ihre/Ihrem/Ihren (possessive). Imperatives take the Sie-form "
                       + "(\"Schicken Sie mir…\", \"Rufen Sie mich an\"). Keep the Sie-form throughout, "
                       + "including possessives.",
             // Deliberately states only what TO use. An earlier version enumerated the forbidden
             // forms ("never use Sie, Ihnen, Ihre…") and measurably made things worse: naming the
             // tokens raised their probability, and the model emitted "Ihre Hilfe" on exactly the
             // polite sentences the warning was aimed at. Negation is not a reliable instruction
             // for a 3B model. Do not reintroduce a forbidden-forms list here without re-running
             // `EasyWrite --eval`.
             informalSpec: "Address the reader with the du-form in every position, not just as the "
                         + "subject: du (subject), dich (accusative), dir (dative), "
                         + "dein/deine/deinen/deinem (possessive). Imperatives take the bare du-form "
                         + "(\"Schick mir…\", \"Ruf mich an\"). Keep the du-form in polite requests "
                         + "too; polite and informal together is normal German, e.g. \"Kannst du mir "
                         + "bitte deine Adresse schicken?\""),
        Lang(code: "fr", name: "French",     formal: "vous",     informal: "tu"),
        Lang(code: "es", name: "Spanish",    formal: "usted",    informal: "tú"),
        Lang(code: "it", name: "Italian",    formal: "Lei",      informal: "tu"),
        Lang(code: "pt", name: "Portuguese", formal: "o senhor", informal: "você"),
        Lang(code: "nl", name: "Dutch",      formal: "u",        informal: "je"),
        Lang(code: "tr", name: "Turkish",    formal: "siz",      informal: "sen"),
        Lang(code: "pl", name: "Polish",     formal: "Pan/Pani", informal: "ty"),
        Lang(code: "ru", name: "Russian",    formal: "вы",       informal: "ты"),
        Lang(code: "en", name: "English",    formal: nil,        informal: nil),
        Lang(code: "ja", name: "Japanese",   formal: nil,        informal: nil),
        Lang(code: "zh", name: "Chinese",    formal: nil,        informal: nil),
        Lang(code: "ar", name: "Arabic",     formal: nil,        informal: nil,
             note: "Use clear Modern Standard Arabic (الفصحى); do not mix in colloquial dialect."),
    ]

    static func named(_ code: String) -> Lang { all.first { $0.code == code } ?? all[0] }
}
