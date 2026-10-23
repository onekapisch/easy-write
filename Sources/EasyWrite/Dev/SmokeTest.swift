import Foundation

/// Synthetic, on-device requests only. Never reads clipboard, user settings or saved history.
@MainActor
enum SmokeTest {
    static func run() async -> Int32 {
        let llm = LLMTranslator()
        if let reason = llm.unavailableReason {
            print("Model smoke tests unavailable: \(reason.message)")
            return 2
        }
        var failed = 0
        let samples: [(String, String, Tone)] = [
            ("Please send me the file.", "de", .formal),
            ("Please send me the file.", "de", .informal),
            ("Bitte senden Sie mir die Datei.", "en", .natural),
            ("Thank you for your help.", "ar", .natural),
        ]
        for (text, code, tone) in samples {
            do {
                let output = try await llm.run(text, job: .init(kind: .translate(Languages.named(code), tone)))
                let nonempty = !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                if !nonempty { failed += 1 }
                print("\(nonempty ? "PASS" : "FAIL") \(code) \(tone.title): \(output)")
            } catch { failed += 1; print("FAIL \(code): \(LLMTranslator.describe(error))") }
        }
        do {
            var output = ""
            let job = LLMTranslator.Job(kind: .transform("Correct the grammar, preserving the meaning and language."))
            for try await partial in llm.stream("She are arriving tomorrow.", job: job) { output = partial }
            if output.isEmpty { failed += 1 }
            print("\(output.isEmpty ? "FAIL" : "PASS") streaming: \(output)")
        } catch { failed += 1; print("FAIL streaming: \(LLMTranslator.describe(error))") }
        do {
            let job = LLMTranslator.Job(kind: .translate(Languages.named("de"), .natural),
                                        notes: String(repeating: "unbounded guidance ", count: 2_000))
            _ = try await llm.run("Hello", job: job)
            failed += 1; print("FAIL oversized guidance was accepted")
        } catch is LLMTranslator.ContextBudgetError { print("PASS actual token-budget rejection") }
        catch { failed += 1; print("FAIL unexpected budget error: \(LLMTranslator.describe(error))") }
        print("Model smoke tests: \(failed) failures. Nonempty output is not a translation-quality certification.")
        return failed == 0 ? 0 : 1
    }
}
