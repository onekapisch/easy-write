# How Easy Write works

A tour of the interesting parts. Easy Write is a native Swift menu-bar app (about 4,400 lines, plus
dev tools) that translates and rewrites text **100% on-device** using Apple's Foundation Models, and
swaps the result straight into whatever app you're using. No accounts, no servers, no API keys.

---

## 1. The engine: Apple's on-device LLM, not a translation API

The translation isn't done by Apple's `Translate` framework (the dictionary-style engine). It's done
by the **Foundation Models** framework, the ~3B-parameter on-device model behind Apple Intelligence.

Why an LLM instead of a translator? Because a plain translator can't do **register**. German has
*Sie* (formal) vs *du* (informal); French has *vous*/*tu*; Spanish *usted*/*tú*. An LLM can be
*instructed*, so one instruction string is all that separates Formal, Informal and Natural (keep the
source's tone). The same engine runs **actions**: your own instructions, like "Fix grammar" or
"Reply politely".

### The guardrail gotcha

Out of the box, the on-device model **refuses ordinary text**. A harmless message like
*"Haben wir noch nicht. Waren nur essen."* throws `guardrailViolation`. The default filter is tuned
for open-ended generation and false-flags translation, which is a content-*transformation* task.
Apple ships a mode for exactly this:

```swift
let model = SystemLanguageModel(useCase: .general,
                                guardrails: .permissiveContentTransformations)
```

### Long text

The model has a 4,096-token window shared by instructions, input and output. Text over ~1,500
characters is split along line breaks (and by sentence for one very long paragraph). Every piece
remembers the exact separator that followed it, and its own leading and trailing blank lines are
put back around the result, so a long email comes back with its layout intact.

### Streaming, retries, timeouts

The Bar streams the result (`session.streamResponse`) so you watch it appear. Every piece races a
25 s timeout; "busy" errors retry once, guardrail and context errors don't. Pressing any Easy Write
shortcut while a job runs cancels it.

### Measuring prompt changes

`EasyWrite --eval` runs 40 sentences through the shipping prompt and a candidate prompt into
informal German and scores formal-register leaks with a German-specific detector (a capitalised
*Sie*/*Ihre* mid-sentence is near-certain formal address). A prompt change ships only when the eval
shows it's better. `release.sh` runs it as a gate.

---

## 2. System-wide in-place swap

Easy Write reads selected text through Accessibility. It never temporarily copies source text:

1. Capture the AX window, field, selection range and selected text.
2. Run the model without changing the clipboard.
3. Prepare the clipboard snapshot, then verify the original target is still selected.
4. Put the result on the clipboard, recheck the target and send **⌘V** to its process.
5. Restore the clipboard only if its change count still belongs to this operation.

The event source uses `.privateState` so the modifier keys you're still holding from the shortcut
don't leak into synthetic keys. This needs **Accessibility** permission.

Details that matter in practice:

- **Clipboard managers ignore the temporary paste.** It carries the `org.nspasteboard.TransientType`
  marker that Clip 4 Breakfast, Maccy and others respect.
- **Restores respect newer copies.** Each restore checks both operation generation and pasteboard
  change count. An external copy is not owned by Easy Write and is left alone.
- **Promised and dynamic clipboard types aren't read** when snapshotting, so copying a huge
  spreadsheet range doesn't stall the app.
- **Fail-closed replacement.** Changed or unverifiable windows, fields or selections get a reader
  result instead. Apps that do not expose selected text through Accessibility are not supported
  for capture. Synthetic pastes are reported as "Paste sent", not confirmed delivery.

---

## 3. The Bar: typing into a panel without stealing focus

The Bar (⌥⌘K) is a `NSPanel` with `.nonactivatingPanel` that overrides `canBecomeKey`, like
Spotlight. It receives your keystrokes, but the app you were writing in **stays frontmost with its
selection intact**, so Replace can paste straight back.

It opens next to the selection when the app reports where that is (`kAXBoundsForRangeParameterized
Attribute`), otherwise near the pointer. A local key monitor handles ↑↓, Return, Esc, ⌘C and ⌘R,
and steps aside while an input method (Japanese, Chinese, Korean) is composing.

Every preview is tagged with the exact item and instruction it was made for. Return only ever
commits the result for what's selected *now*; choosing another item clears a pending Return.

---

## 4. Two directions with one key

`⌥⌘T` runs Apple's on-device language identification (`NLLanguageRecognizer`, limited to the
supported languages). If the selection is already in your target language, it translates back into
your own language instead. It only flips when there are at least three words and the guess is
confident, so "OK" or a name never sends you the wrong way.

The language and tone you pick in the Bar are **remembered per app** (Mail formal, Slack informal).

---

## 5. The notch HUD

Feedback appears where your eyes already are. On MacBooks, Easy Write reads the notch's size from
`NSScreen.safeAreaInsets` and `auxiliaryTopLeftArea`/`auxiliaryTopRightArea`, then draws a black
pill that starts exactly notch-sized and springs open, so it looks like the notch itself growing.
On other displays it's a pill under the menu bar. It respects Reduce Motion, ignores the mouse, and
every result and problem is announced to VoiceOver.

---

## 6. Shared actions

"Share action" copies a link like
`https://www.onekapisch.com/products/easy-write/action/#reply-politely.eyJ2Ijox…`. The action is
base64url JSON in the **URL fragment**, which browsers never send to a server, so the recipe page
needs no backend and nothing is logged. Its "Add to Easy Write" button opens `easywrite://action?d=…`.

A shared action is someone else's instruction, so the app treats it as untrusted:

- it always shows the full instruction before adding it,
- it starts in popup mode, so it can't change your text until you switch it to Replace,
- it never comes with a shortcut,
- names and instructions are length-limited by Unicode scalars (stacked accents can't hide a huge
  instruction), and control characters or bidirectional overrides are rejected so the confirmation
  shows exactly what will run.

---

## 7. Signing, so Accessibility survives updates

macOS ties the Accessibility grant to the app's code signature. Release builds are signed with a
**Developer ID** and the hardened runtime, so the grant survives every update. Contributors without
one can run `setup-signing.sh` once for a stable self-signed identity; ad-hoc signing doesn't keep
the grant on macOS 26.

---

## 8. Updates and privacy

The model runs locally. There are no accounts, analytics or telemetry. The only network access is
**Sparkle** checking `onekapisch.com` for updates, and only after you allow it. It sends the app
version and nothing else (system profiling is off). History is a JSON file in Application Support,
with a retention limit, an off switch, and excluded apps (password managers by default).

---

## File map

| File | Responsibility |
|------|----------------|
| `main.swift` | Entry point; dev flags `--eval`, `--selftest`, `--snapshots` |
| `AppDelegate.swift` | Status item, hot-key wiring, URL handling |
| `Core/Runner.swift` | Every flow: capture → model → replace / reader, HUD, history, stats |
| `Core/LLMTranslator.swift` | Foundation Models jobs, prompts, streaming, long-text pieces, errors |
| `Core/Replacer.swift` | AX selection capture, target-validated paste, clipboard ownership |
| `Core/LanguageDetector.swift` | On-device language identification for two-way translate |
| `Core/Store.swift` | Settings, per-app memory, stats, 1.x migration |
| `Core/Models.swift` | Tone, actions, glossary terms, history entries, share-link codec |
| `Core/HistoryStore.swift` | Local history with retention |
| `Core/AppState.swift` | Live permission and model status |
| `Core/UpdateController.swift` | Sparkle |
| `Core/HotKey.swift`, `KeyDisplay.swift`, `Languages.swift` | Hot-keys, shortcut labels, languages |
| `UI/MenuPanel.swift` | The menu-bar panel |
| `UI/BarPanel.swift` | The Easy Write Bar |
| `UI/NotchHUD.swift` | The notch HUD |
| `UI/ReaderPanel.swift` | Reader card for read mode and popup actions |
| `UI/WelcomeWindow.swift` | First-run setup and practice swap |
| `UI/SettingsWindow.swift` | Settings |
| `UI/ImportAction.swift` | Shared-action import, main menu |
| `UI/Theme.swift` | Colours and shared components |
| `Dev/` | Eval harness, self-test, snapshot renderer |

Requirements: macOS 26+ on Apple Silicon with Apple Intelligence enabled.
