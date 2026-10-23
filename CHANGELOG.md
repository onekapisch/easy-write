# Changelog

All notable changes to Easy Write are documented here.

## [2.0]

The biggest update yet: a new interface, one shortcut for everything, your own actions, and a
notarized download that updates itself.

### Added
- **Download it.** A notarized app from onekapisch.com. No Terminal, no build step, and it updates
  itself (only if you allow it).
- **Easy Write Bar** (⌥⌘K). Opens next to your selection with every language, tone and action. Type
  to filter, or type any instruction ("sound more excited") and run it once. The result streams in
  before anything changes; ↩ replaces, ⌘C copies, ⌘R tries again.
- **Translate both directions** with ⌥⌘T. If the text is already in your target language, it comes
  back into your own.
- **Remembered per app.** The language and tone you pick in Mail or Slack become the default there.
- **Actions.** Your own instructions on a shortcut: Fix grammar, Make it shorter, Reply politely and
  more, all editable. Share any action as a link; the link opens a page with an Add button.
- **Notch HUD.** Progress and results grow out of the notch (or a pill on other displays), with ⌘Z
  to undo.
- **New menu-bar panel** with live status, your counts, the language and tone, and quick tiles.
- **Reader card** for read mode: detected language, Speak, Pin, and Replace when the text is
  editable. Read mode now translates into your own language, not only English.
- **Welcome window** that checks permissions and Apple Intelligence live and ends with a practice
  swap.
- **History** of recent results, kept on your Mac, with retention, an off switch, and excluded apps
  (password managers by default).
- **Glossary** of exact terms, plus style notes, used in every translation and action.
- **Long text** is split into pieces so long emails translate fully, keeping their layout.
- **VoiceOver**: labelled controls and spoken results.

### Changed
- New settings window with General, Languages, Actions, Shortcuts, Glossary, History & Privacy,
  Updates and About.
- Three default shortcuts: ⌥⌘K Bar, ⌥⌘T Translate, ⌥⌘E Read. Formal and informal live in the Bar and
  per-app memory. Shortcuts you had customised in 1.x are kept.
- Pressing any Easy Write shortcut while a job runs stops it.
- New app ID (com.onekapisch.easywrite). Your settings move over automatically. macOS asks for
  Accessibility once more, because the app is now signed by OneKapisch.

### Fixed
- Read mode left your clipboard changed. The clipboard is now always restored, and Easy Write's
  temporary paste no longer appears in clipboard managers.
- If you switch apps while a result is on its way, it goes to your clipboard instead of into the
  wrong window.
- ⌘C, ⌘V and ⌘Z work in Easy Write's own text fields.

## [1.1.1] — 2026-07-14

### Fixed
- **Clearer "Apple Intelligence unavailable" message.** The app used to show a single generic
  "enable it in Settings" line for every reason the on-device model wasn't ready — even for users
  who *had* already enabled Apple Intelligence but whose model was still downloading. It now reads
  the actual reason and tells you which one it is: device not supported, Apple Intelligence turned
  off, or **model still downloading in the background** (the most common case right after enabling).

## [1.1] — 2026-07-13

### Added
- **Arabic** — added to the language list by user request. It's one of Apple's supported
  Foundation Models languages, tuned here to produce **Modern Standard Arabic (الفصحى)** rather than
  mixed dialect. Uses natural-register translation (no forced formal/informal split, since Arabic
  formality doesn't reduce to a single pronoun pair the way German *Sie/du* does — same treatment as
  English, Japanese, and Chinese). Strong on everyday messages; like any on-device translation it can
  occasionally slip on more complex sentences, so double-check anything important.

### Changed
- The translation prompt now explicitly emphasises subject/object direction (who does what to whom),
  improving accuracy across all languages.

## [1.0] — 2026-06-25

First public release. 🎉

### Added
- **In-place translation** — select text in any app, press a shortcut, and the selection is replaced
  with the translation.
- **Formal / informal register** — `⌥⌘T` formal (Sie/vous/usted…), `⌥⌘I` informal (du/tu/tú…),
  powered by Apple's on-device model.
- **Plain mode** (`⌥⌘P`) — translation that preserves the source's natural tone.
- **Read mode** (`⌥⌘E`) — translate incoming foreign text to English in a popup, for non-editable
  text like web pages, emails, and chats.
- **12 target languages**, switchable from the menu.
- **Personal style & glossary** — injected into every translation.
- **Custom shortcuts** with a built-in recorder.
- **Launch at login**, menu-bar-only (no Dock icon).
- **100% on-device** via Apple Foundation Models — no accounts, no API keys, no network.

### Notes
- Uses `permissiveContentTransformations` guardrails so ordinary text isn't false-flagged by the
  on-device model's default safety filter.
- Ships with a stable self-signed identity setup so the Accessibility grant persists across rebuilds.

Requires macOS 26+ on Apple Silicon with Apple Intelligence enabled.
