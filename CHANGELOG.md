# Changelog

All notable changes to Easy Write are documented here.

## Unreleased

### Changed, 2026-10-23
- Adopted the owner-approved tagline: "Translate and rewrite without switching apps."
  README, About, Studio entry and launch-artwork templates share the new positioning.
- This is source/documentation preparation. The signed 2.0.1 installer and feed are unchanged;
  in-app copy will reach installed users in the next signed release.

## [2.0.1] — 2026-10-23

### Release verification
- Published new signed/notarized build-27 assets and deployed the matching signed feed and
  version-pinned downloads. Public GitHub payload/feed hashes and signatures match local
  originals. Website production is Ready; installed Sparkle discovery/upgrade still awaits
  owner acceptance. Canonical XML byte verification was blocked by browser/tool limitations.

### Fixed
- Fixed washed-out menu text over bright windows by giving the production panel and cards
  opaque foundations instead of relying on NSPopover's translucent backdrop.
- The menu now follows system light and dark appearance. Text, controls, language chips,
  shortcut keycaps and status colors use appearance-aware colors with stronger contrast.
- Retained the purple accent, native typography and existing layout. Translation and
  replacement behavior, privacy settings and update consent are unchanged.
- Removed substitute menu backgrounds from developer captures so they cannot mask this bug.
  Added light/dark, high-contrast, control-contrast and backdrop-independence regression checks.

## [2.0] — 2026-10-23

### Public launch verified

- Published the existing notarized 2.0 build 24 with owner approval. Public GitHub downloads
  match the accepted DMG's SHA-256; the downloaded signed feed is byte-identical and verifies.
- Deployed the redesigned product page, six guides and shared-action utility on the existing
  OneKapisch site. All three download links are active; source and release are public.
- Updated launch documentation for official manual DMG installation, manual 1.x upgrades,
  source builds with updates off by default, and ordinary network/clipboard privacy cautions.
- Homebrew is not live. Clean-Mac installation, physical app/VoiceOver checks and installed
  Sparkle upgrade acceptance remain unverified; authorization does not complete those checks.
- No runtime or accepted release artifact changed during publication. Earlier preparation
  entries below describe their own historical scope.

### Notarized local installer, 2026-10-23
- Apple accepted the app and corrected DMG for 2.0 build 24. Both are stapled and
  pass Gatekeeper. The mounted final payload passed strict signature checks and 75 self-tests.
- Disabled post-signing Finder metadata mutations in the new dmgbuild layout and added a
  regression test. Quarantined the first faulty image; it must not be distributed.
- Prepared and cryptographically verified a local signed appcast for the exact final DMG.
  No credentials or private keys were exported. No public release or deployment performed.
- Clean-Mac installation, physical app/VoiceOver checks and installed Sparkle upgrade acceptance
  remain separate gates. Public download verification is recorded in the launch entry above.

### Website research and content, 2026-10-23
- Added source-backed SEO/GEO research, a 62-query candidate map with explicit evidence labels,
  competitor fact checking and a prioritized 90-day content/distribution plan.
- Drafted six substantial guides for the existing OneKapisch website and integrated deployable
  copies in the website preview: selected-text translation, German register, offline choices,
  Writing Tools shortcuts, custom actions and setup. Public 1.x and local 2.0 remain distinct.
- No native app behavior, analytics, model inference, distribution or publication was changed.

### Launch preparation, 2026-10-23
- Recorded the founder's page approval, release-gated direct-download design and
  private Terminal instructions for the notarization credential profile (now configured).
- Implemented the product-page preview in an isolated OneKapisch website branch,
  with release-state-aware source links and native media. No deployment performed.
- Prepared and locally verified a Developer-ID-signed DMG, mounted-binary tests
  and a Sparkle signature round-trip. That initial unnotarized build-4 candidate is
  superseded by notarized build 24; its former Gatekeeper rejection remains recorded.
- Ignored generated release artifacts under `dist/` and recorded remaining physical
  recording, notarization, update acceptance and publication gates in the launch handoff.

### Launch media, 2026-10-23
- Added a project-local launch kit: menu-bar panel, Bar, tone, reader and action images,
  Daylight and Midnight heroes, GitHub social artwork, and raw native UI renders.
- Added reproducible native HUD motion capture using the production SwiftUI view and spring.
  ScreenCaptureKit records only the owned staged window using existing permission.
- Added media validation, provenance, local gallery and a proposed website redesign.
  No website deployment, GitHub push or release publication is part of this task.

### Release-safety review, 2026-10-23
- Clipboard restoration preserves newer external copies, including copies during a pending paste.
- Automatic replacement checks the original window, field, selected text and range; unverifiable
  targets show a copyable result instead. Synthetic pastes are not reported as confirmed success.
- History requires explicit opt-in, clears on disable, uses owner-only permissions, and prunes
  during idle use and after wake. Early preview implicit consent is not migrated.
- Streaming and normal model requests have deadlines. Context budgeting includes instructions,
  glossary, style notes, output and framing overhead.
- At review time, download and Homebrew claims were marked pending; source builds disable updates by default.
- Added regression tests and release-acceptance documentation.
- Retested the signed build: 75 isolated checks and six real-model checks passed. Automated
  global-shortcut and replacement acceptance remains unverified. Publication is now approved,
  without changing that acceptance status.

The biggest update yet: a new interface, one shortcut for everything, your own actions, and a
notarized installer with optional update checks.

### Added
- **Notarized installer and optional update checks.** Build 24 and its exact signed payload/feed
  passed local and public-delivery verification. Installed upgrade acceptance is unverified.
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
- Read mode no longer captures the selection through the clipboard. Temporary paste data is
  marked transient; restoration preserves newer user copies. Clipboard-manager behavior varies.
- If the source selection cannot be verified when a result arrives, a copyable reader card opens
  instead of pasting into another field or overwriting the clipboard.
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
