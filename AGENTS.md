# Easy Write project instructions

## Stack and layout
Native macOS 26+ Swift/SwiftUI/AppKit app. SwiftPM builds with Swift language mode 5,
Foundation Models, NaturalLanguage, ApplicationServices, Carbon and Sparkle 2.
`Sources/EasyWrite/Core` contains execution and persistence, `UI` contains native surfaces,
and `Dev` contains self-tests, snapshots and model evaluation. Do not introduce a web stack.

## Design
Preserve the current studio design. Reuse `UI/Theme.swift`: purple accent #7C5CFF,
dark layered panels with native macOS typography. Settings and onboarding use existing native
controls. Respect Reduce Motion and preserve VoiceOver labels. No unrelated redesigns.

## Safety
Never log selected text. History requires explicit consent. Never paste unless the source
process, window, element, selection range and selected text can still be verified.
Preserve externally changed clipboard contents. Never retain secrets in diagnostics.
Keep AI inference local. Update checks are optional; disclose external links separately.

## Verification
`swift build -c release`
`./.build/release/EasyWrite --selftest`
`./.build/release/EasyWrite --smoketest` uses only synthetic text and the real on-device model.
`bash -n build.sh release.sh setup-signing.sh`
`python3 -m unittest discover -s dmg -p test_settings.py` checks the safe DMG layout.
`./build.sh` packages locally and signs; it does not publish.
`EasyWrite --snapshots <temporary-directory>` uses synthetic sample data.
`bash tools/launch-assets/export.sh` creates native launch media. Its owned-window recording
uses existing Screen Recording permission and never requests it; it does not capture the desktop.
`node --test tools/launch-assets/verify.test.mjs` verifies the distributable asset inventory.
`EasyWrite --eval` runs a real model and needs Apple Intelligence ready.
Cross-app Accessibility, VoiceOver and end-to-end signed updates require separate acceptance.

## Website content and search evidence
The native app has no web stack. Dated SEO research and draft snapshots live in `docs/seo/`.
The OneKapisch website maintains deployable guide content separately in its existing static
generator. Keep public 1.x source distinct from the local 2.0 preview. Do not claim exclusive
features, verified search volumes, user outcomes or app compatibility without evidence.

## Publication policy
Preserve existing branches and dirty work. Stage only scoped changes. No merge, push,
notarization submission, GitHub release, domain purchase or website deployment without explicit
approval. Do not run `release.sh` as a test: it writes tags and creates a remote draft.
Keep README, CHANGELOG, TODO and SECURITY aligned with verified delivery, not future intent.
For the verified build-24 packaging procedure and artifact hashes, see
`docs/notarization-2.0-build24.md`. Never mutate signed app Finder metadata in a DMG.
