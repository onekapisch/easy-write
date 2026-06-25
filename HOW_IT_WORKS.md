# How Easy Write works

A tour of the interesting parts. Easy Write is a ~600-line native Swift menu-bar app that does
register-aware translation **100% on-device** using Apple's Foundation Models, and swaps the result
straight into whatever app you're using. No accounts, no servers, no API keys.

---

## 1. The engine: Apple's on-device LLM, not a translation API

The translation isn't done by Apple's `Translate` framework (the dictionary-style engine). It's done
by the **Foundation Models** framework — the ~3B-parameter on-device LLM that powers Apple
Intelligence on macOS 26.

Why an LLM instead of a translator? Because a plain translator can't do **register**. German has
*Sie* (formal) vs *du* (informal); French has *vous*/*tu*; Spanish *usted*/*tú*. An LLM can be
*instructed*:

```swift
let session = LanguageModelSession(model: model, instructions: """
    Translate into German using the formal Sie register (use Sie / Ihnen / Ihr consistently;
    never use du). Output ONLY the translation.
    """)
let result = try await session.respond(to: "Text to translate:\n\(text)",
                                       options: GenerationOptions(temperature: 0.1)).content
```

A single instruction string is all that separates formal, informal, and "preserve the source tone."

### The guardrail gotcha (the interesting part)

Out of the box, the on-device model **refuses ordinary text**. A harmless message like
*"Haben wir noch nicht. Waren nur essen."* throws:

```
guardrailViolation("Response may contain sensitive or unsafe content")
```

The default safety filter is tuned for open-ended generation and false-flags **translation**, which is
a content-*transformation* task. Apple ships a purpose-built mode for exactly this:

```swift
let model = SystemLanguageModel(useCase: .general,
                                guardrails: .permissiveContentTransformations)
```

Switching to it makes legitimate translations stop getting blocked. If you build anything that
transforms user-provided text on-device, you almost certainly want this.

### Keeping it from hanging

Each translation races the model against a 20s timeout (`withThrowingTaskGroup`), and transient
errors retry once. A stalled request can never wedge the app.

---

## 2. System-wide in-place swap

To replace text in *any* app, Easy Write doesn't integrate with each app — it drives the keyboard:

1. Snapshot the clipboard.
2. Synthesise **⌘C** (`CGEvent`) to copy the current selection; read it from `NSPasteboard`.
3. Translate.
4. Put the result on the clipboard, synthesise **⌘V** to paste over the selection.
5. Restore the original clipboard.

```swift
let down = CGEvent(keyboardEventSource: source, virtualKey: 8 /* C */, keyDown: true)
down?.flags = .maskCommand
down?.post(tap: .cghidEventTap)
```

The event source uses `.privateState` so physically-held modifier keys (from the hot-key you just
pressed) don't contaminate the synthetic ⌘C. This requires **Accessibility** permission.

**Read mode is different.** When you're *reading* incoming foreign text (a web page, an email, a PDF),
the source is non-editable — pasting back is impossible. So `⌥⌘E` shows the English in a popup
instead of trying to swap it. Same engine, different presentation.

---

## 3. Global hot-keys

Carbon's `RegisterEventHotKey` registers shortcuts that fire from any app, even when Easy Write isn't
focused. A single installed event handler dispatches by hot-key id to the right action. Shortcuts are
user-rebindable; changing one unregisters all and re-registers from the saved config.

---

## 4. The signing gotcha (so Accessibility persists)

Ad-hoc signing (`codesign --sign -`) does **not** hold an Accessibility grant on macOS 26 — the
toggle shows "on" but `AXIsProcessTrusted()` stays false, and every rebuild invalidates it. The fix is
a **stable self-signed identity** (`setup-signing.sh` creates one in a dedicated keychain). With a
stable code signature, TCC pins the grant to the app's designated requirement, so it survives rebuilds.

---

## 5. Privacy

Nothing leaves the machine. The model runs locally; there is no network code, no analytics, no
accounts. The clipboard is snapshotted and restored around each swap. The only permission required is
Accessibility (to read the selection and paste the result).

---

## File map

| File | Responsibility |
|------|----------------|
| `main.swift` | Dock-less menu-bar agent entry point |
| `AppDelegate.swift` | Menu, hot-key wiring, translate→replace/popup flow |
| `LLMTranslator.swift` | Foundation Models engine, register prompts, permissive guardrails |
| `Replacer.swift` | Synthesised ⌘C / ⌘V swap + clipboard save/restore |
| `HotKey.swift` | Carbon global hot-keys |
| `Store.swift` | Settings (target language, shortcuts, style guide) |
| `PreferencesController.swift` | SwiftUI preferences + shortcut recorder |
| `KeyDisplay.swift` | Keycode ⇄ shortcut string |
| `Languages.swift` | Supported languages + formal/informal pronoun labels |

Requirements: macOS 26+ on Apple Silicon with Apple Intelligence enabled.
