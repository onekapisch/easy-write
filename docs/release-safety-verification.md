# 2.0 release-safety verification

Date: 2026-10-23. Baseline: e3590fa. Work branch: fix/v2-release-safety.

## Verified
- `swift build -c release` and `./build.sh`: pass; no compiler warnings in the final build.
- `codesign --verify --deep --strict "Easy Write.app"`: pass. Locally Developer-ID signed,
  not notarized by this task.
- `EasyWrite --selftest`: 75 passed, zero failures. Uses isolated defaults and pasteboards.
  Added coverage for external clipboard copies, invalidated targets, window/element/range/text
  matching, history consent and deletion, exclusions, retention, deadlines/cancellation and caps.
- Red phase: the initial regression run had five failures covering implicit history and clipboard loss.
- `EasyWrite --smoketest`: six synthetic, real-model scenarios passed: German formal/informal,
  German-to-English, Arabic, streaming grammar correction, oversized-guidance rejection.
  These do not certify translation accuracy across all languages or long texts.
- 25 synthetic UI snapshots rendered. Settings inspected live: history off by default with an
  explicit retention warning; update checks disabled in source builds.
- Shell syntax and `git diff --check`: pass.
- Independent static review: no remaining critical/high findings within the clipboard, target,
  history, deadline and token-budget scope after follow-up fixes.

## Not passed or not attempted
- Scripted cross-app TextEdit hotkeys did not produce a verified replacement. This is not a pass
  and does not establish whether physical global hotkeys or every host app work. Physical native,
  browser, Electron and changed-focus acceptance remains mandatory before release.
- VoiceOver navigation, older macOS compatibility, notarization, signed-update installation and
  live hosting were not certified. See TODO.md.
- The live product page exists, but its appcast and public latest-release DMG returned 404 in the
  audit. No website deployment, GitHub publication or domain registration was performed.

## Deliberate compatibility trade-off
Selected text is read through Accessibility, not a synthetic Copy. Automatic replacement requires
a verifiable AX window, field, range and selected text. Unsupported hosts fall back to a review
result or a selection error. Sending a paste is not confirmation that the host applied it.

## Data retention
History is now explicit opt-in. On next launch an old preview's implicitly enabled history is
cleared unless fresh consent has been stored. This deletes the local history file, not backups.
