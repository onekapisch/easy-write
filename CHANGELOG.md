# Changelog

All notable changes to Easy Write are documented here.

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
