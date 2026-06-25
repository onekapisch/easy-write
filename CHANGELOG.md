# Changelog

All notable changes to Easy Write are documented here.

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
