import Foundation

/// Offline quality harness: `EasyWrite --eval`.
///
/// Scores English → informal German, which is where formal register leaks hurt most.
/// It runs every sentence through BOTH the old (1.1) prompt and the new one, interleaved,
/// so the comparison is on the same machine and the same model state rather than across runs.
///
/// What it measures honestly:
///   • formal-register leak rate — objective, deterministic, see `RegisterCheck`
///   • everything else (meaning, word order, naturalness) — dumped to CSV for a human to read.
///     A 3B model judging its own translations would be circular, and exact-match against one
///     reference translation is wrong because many translations are valid.
@MainActor
enum Eval {

    /// Sentences chosen to provoke the actual failure modes: possessives ("your" → dein),
    /// imperatives ("send me" → schick mir), and polite requests, where the pull toward Sie
    /// is strongest.
    static let corpus = [
        "Could you please send me the report by tomorrow morning?",
        "Can you send me your address?",
        "Let me know what you think.",
        "I'll call you back later today.",
        "Don't forget to bring your laptop.",
        "Thanks for your help with the presentation.",
        "Would you mind checking your calendar?",
        "Please confirm your booking before Friday.",
        "Give me a call when you get home.",
        "What's your phone number?",
        "I sent you the file yesterday, did you get it?",
        "Your idea is really good.",
        "Could you help me move this weekend?",
        "Tell me if you need anything else.",
        "I hope you're doing well.",
        "Are you free on Thursday evening?",
        "Send me your feedback whenever you have time.",
        "I really appreciate everything you've done.",
        "Please let me know if your plans change.",
        "Can I borrow your charger for a minute?",
        "Write to me when you land.",
        "Did you finish your part of the project?",
        "I'd love to hear your opinion on this.",
        "Take care of yourself.",
        "Have you spoken to your manager about it?",
        "Just wanted to check if you're still coming.",
        "Bring your passport, you'll need it.",
        "Sorry, I forgot to answer your message.",
        "How was your weekend?",
        "Can you explain that to me again?",
        "Please don't be late again.",
        "Your package should arrive on Monday.",
        "Let me know your decision as soon as you can.",
        "I'll send you the details tonight.",
        "Do you want me to pick you up?",
        "Check your email, I sent you the invite.",
        "Thanks for waiting, I know your time is valuable.",
        "If you have any questions, just ask me.",
        "I saw your message but couldn't reply.",
        "Could you sign this and send it back to me?",
    ]

    private struct Row {
        let source: String
        var legacy = ""
        var improved = ""
        var legacyLeaks: [String] = []
        var improvedLeaks: [String] = []
        var legacyAmbiguous: [String] = []
        var improvedAmbiguous: [String] = []
    }

    static func run() async {
        let llm = LLMTranslator()
        if let reason = llm.unavailableReason {
            print("Cannot run eval: \(reason.message)")
            exit(1)
        }

        let german = Languages.named("de")
        print("Easy Write translation eval")
        print("EN → German (informal), \(corpus.count) sentences, old prompt vs new prompt\n")

        var rows: [Row] = []
        for (i, source) in corpus.enumerated() {
            var row = Row(source: source)

            for style in [LLMTranslator.PromptStyle.shipping, .candidate] {
                let out: String
                do {
                    out = try await llm.translate(source, to: german, register: .informal,
                                                  promptStyle: style)
                } catch {
                    out = "<ERROR: \(error)>"
                }
                let check = RegisterCheck.check(out, languageCode: "de", expecting: .informal)
                if style == .shipping {
                    row.legacy = out
                    row.legacyLeaks = check.definite
                    row.legacyAmbiguous = check.ambiguous
                } else {
                    row.improved = out
                    row.improvedLeaks = check.definite
                    row.improvedAmbiguous = check.ambiguous
                }
            }

            rows.append(row)
            let mark = { (leaks: [String]) in leaks.isEmpty ? "ok  " : "LEAK" }
            print(String(format: "%2d/%d  old:%@  new:%@  %@",
                         i + 1, corpus.count, mark(row.legacyLeaks), mark(row.improvedLeaks),
                         source))
        }

        report(rows)
        writeCSV(rows)
    }

    private static func report(_ rows: [Row]) {
        let n = rows.count
        let legacyLeaked = rows.filter { !$0.legacyLeaks.isEmpty }.count
        let improvedLeaked = rows.filter { !$0.improvedLeaks.isEmpty }.count
        let pct = { (c: Int) in String(format: "%.0f%%", Double(c) / Double(n) * 100) }

        print("\n" + String(repeating: "=", count: 58))
        print("FORMAL REGISTER LEAKS (sentences containing Sie/Ihnen/Ihr mid-sentence)")
        print(String(repeating: "=", count: 58))
        print("  shipping prompt:   \(legacyLeaked)/\(n)  (\(pct(legacyLeaked)))")
        print("  candidate prompt:  \(improvedLeaked)/\(n)  (\(pct(improvedLeaked)))")

        let fixed = rows.filter { !$0.legacyLeaks.isEmpty && $0.improvedLeaks.isEmpty }.count
        let broken = rows.filter { $0.legacyLeaks.isEmpty && !$0.improvedLeaks.isEmpty }.count
        print("\n  fixed by new prompt:    \(fixed)")
        print("  regressed by new prompt: \(broken)")

        let ambiguous = rows.filter { !$0.improvedAmbiguous.isEmpty }.count
        if ambiguous > 0 {
            print("\n  \(ambiguous) sentence(s) had a sentence-initial Sie/Ihr, which is ambiguous")
            print("  (could be capitalised 'sie' = she/they). Not scored. See the CSV.")
        }
        print("\nMeaning, word order and naturalness are NOT scored here. Read the CSV.")
    }

    private static func writeCSV(_ rows: [Row]) {
        var csv = "source,old_prompt,old_leaks,new_prompt,new_leaks\n"
        for r in rows {
            let cols = [
                r.source, r.legacy, r.legacyLeaks.joined(separator: " "),
                r.improved, r.improvedLeaks.joined(separator: " "),
            ]
            csv += cols.map(escape).joined(separator: ",") + "\n"
        }
        // Outside the repo on purpose, so a run never leaves untracked files in the checkout.
        let path = outputURL().path
        do {
            try csv.write(toFile: path, atomically: true, encoding: .utf8)
            print("\nSide-by-side output written to:\n  \(path)")
        } catch {
            print("\nCould not write CSV: \(error)")
        }
    }

    static func outputURL(environment: [String: String] = ProcessInfo.processInfo.environment,
                          temporaryDirectory: URL = FileManager.default.temporaryDirectory) -> URL {
        let directory = environment["EW_EVAL_OUTPUT_DIRECTORY"].flatMap {
            $0.hasPrefix("/") ? URL(fileURLWithPath: $0, isDirectory: true) : nil
        } ?? temporaryDirectory
        return directory.appendingPathComponent("easywrite-eval-results.csv")
    }

    private static func escape(_ s: String) -> String {
        "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
