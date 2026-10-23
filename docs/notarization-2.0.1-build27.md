# Easy Write 2.0.1, build 27

Date: 2026-10-23. Owner explicitly requested the appearance fix and Sparkle publication.
This is a new immutable patch; the accepted 2.0 build-24 release remains unchanged.

## Cause and scope

The menu forced vibrantDark and SwiftUI dark mode but supplied no background. Its faint
colors sat on the translucent system popover. The old snapshot tool added a dark substitute
surface and hid the production problem. The menu now inherits appearance and supplies opaque
panel/card/control foundations. Semantic colors adapt; the purple identity and layout remain.
Bar, Reader and onboarding keep their intentional dark window appearance. Inference,
replacement safeguards, history, permissions and update consent are unchanged.

## Verification

- Appearance wiring tests failed before implementation. The initial contrast suite failed
  13 checks before the fix; all 112 current isolated self-tests pass, including contrast >=4.5:1
  for primary/secondary/tertiary text on cards and controls in Aqua, Dark Aqua and both
  accessibility high-contrast appearances, plus opaque foundations and selected white text.
- Both Node appearance tests, safe DMG layout test and six launch-asset tests pass.
- Six synthetic real-model smoke checks passed. This is not an accuracy certification.
- Native snapshots inspect the production MenuPanelView without substitute fills and use
  the same NSPopover factory. Both light/dark views remain readable. Pixel comparisons over
  black/white test backdrops find zero backdrop-dependent or transparent interior pixels.
- Independent read-only review found no P1/P2 blockers and probed appearance propagation.
  Snapshot images capture hosted content, not native arrow/chrome or compositor output.
- Native computer-control inspection timed out; no permission was requested or bypassed.
  Cross-app physical workflow, VoiceOver and a complete installed Sparkle upgrade are not
  certified by these checks. Do not describe feed publication as forced or completed installs.

## Signing and packaging

- Output: `dist/notarized-2.0.1-b27.hT45ha/` (ignored).
- Built from the release SwiftPM binary. Developer ID, hardened runtime, secure timestamp,
  arm64, minimum macOS 26.0, existing bundle identifier, feed URL and public key retained.
- App notarization: `6e97e7ef-60e5-436e-9938-ee3e41165705`, Accepted. Stapled/validated;
  strict signature and Gatekeeper accepted as Notarized Developer ID.
- DMG used existing dmgbuild 1.6.7/ds_store 1.3.3/mac_alias 2.2.3 environment and safe
  `dmg/settings.py`. No post-signing Finder metadata changes and no Finder automation.
- Before signing the image, its read-only mounted app passed strict signature, staple,
  Gatekeeper and all 112 self-tests.
- DMG notarization: `dce9e6d5-4386-4595-9977-064a4456db13`, Accepted. Stapled/validated;
  strict signature, Gatekeeper and hdiutil checksum passed. Repeated mounted checks and
  112 tests after the outer image was notarized/stapled.
- Final versioned and stable DMGs are identical: 4,006,824 bytes, SHA-256
  `be47cf44102634baa07c79dac0dbe390ddc8e755ef2c75d18d48864ebf1ead03`.
- Sparkle payload and feed signed with the existing Keychain key, then verified with Sparkle.
  Independent Node Ed25519 verification against the public key in 2.0 also passed.
  The new feed leads with version 27 / 2.0.1 and retains version 24 / 2.0.
- No credentials or private signing keys were exported. `release.sh` was not used.

## Distribution

Publish new assets under `v2.0.1` before deploying the matching signed feed at
https://www.onekapisch.com/products/easy-write/appcast.xml. Existing official 2.0 builds
can check in Settings → Updates. Automatic checks remain optional. Pre-Sparkle 1.x and
default source builds upgrade manually. Public-byte verification is a separate final step.
