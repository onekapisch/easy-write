# Easy Write 2.0 launch handoff

Verified 2026-10-23. This is preparation, not publication approval or a released build.

## 1. Website preview: implemented locally

The isolated OneKapisch website branch is `codex/easy-write-v2-product-page`.
Its existing `/products/easy-write/` route now contains the native Bar, menu panel,
register examples, reader, actions and user-played notch film. Canonical URL and
shared navigation/legal links are preserved. The page has no analytics.

Website verification: build, lint, syntax, 25 existing release tests, four new
preview tests, static artifact verification and 69 browser checks passed. The
browser pass produced 75 screenshots; four documented non-fatal Orbit warnings
remain outside this product page. The founder subsequently approved the page
direction and requested an official direct-download control. That design is local
and explicitly disabled until a validated installer exists; it is not an Apple badge.

## 2. Real workflow film: physical capture required

The owner reported physical use working. The current native HUD film is explicitly
staged and remains unsuitable as proof of real translation or replacement speed.
The automated TextEdit shortcut attempt again left the disposable sentence
unchanged. This bridge does not establish physical Carbon hotkey acceptance.

Record a physical selection, Option-Command-T and actual text replacement using
only a disposable document. Use macOS Screenshot recording with a bounded area,
avoid private content and notifications, and keep the raw movie. Do not substitute
edited text or synthetic timing for the real workflow. Browser/Electron, changed
focus and VoiceOver acceptance remain separate checks.

## 3. Local release candidate: notarized build 24

The owner configured `easywrite-notary` privately and authorized submission.
The superseded unnotarized build-4 image remains local only. The current candidate is
`dist/notarized-2.0-b24.mHw0DB/EasyWrite-2.0.dmg`.

- Apple accepted the app and corrected DMG. Both are Developer-ID signed,
  timestamped, stapled and Gatekeeper-accepted as `Notarized Developer ID`.
- Version 2.0, build 24, arm64, minimum macOS 26. The release app has optional
  Sparkle update configuration enabled; source builds still disable it by default.
- The final image passed integrity verification. Its read-only mounted app passed
  strict signature verification, stapler validation, Gatekeeper and all 75 self-tests.
  An extracted copy also passed signature checks, Gatekeeper and distribution policy checks.
- Six real-model smoke checks passed. The shipping prompt had 0 definite formal
  leaks across 40 synthetic informal German examples. This is not all-language accuracy evidence.
- Payload and feed signatures verify. Independent Ed25519 verification used the
  embedded public key and exact final DMG bytes; version, length, URL and architecture match.
- DMG SHA-256: `586ab04082d3542d4796d3b930b15f750f01a1e44c0c760569b346a438ed4c6c`.
- The first notarized DMG failed a mounted strict-signature check because a cosmetic
  setting added Finder metadata after signing. It is quarantined under `rejected/`.
  The corrected layout disables these mutations and has a regression test.

The signed appcast is local only. It was prepared using Sparkle's supported manual
signing path after an automated generator attempt stalled. No private key was exported.
See [the notarization record](notarization-2.0-build24.md) for IDs and packaging details.
Clean-Mac install/launch, installed Sparkle upgrades and physical compatibility remain outstanding.

## 4. Coordinated public launch: not executed

The last public check reported v1.1.1 with no binary assets and 404 responses for the
appcast and latest DMG. No tag, push, draft release or deployment has been performed
by this preparation task. Notarization is complete locally, not publication.

Before publishing: validate the installed Sparkle upgrade path, publish the exact
signed payload and matching feed together, switch the website's shared preview
CTA state to the verified version-pinned download, update README/release notes,
and verify all public URLs. Pre-Sparkle 1.x users need one manual upgrade; they
cannot receive an updater retroactively. Optional checks in the new build concern
future releases and still require user consent.

`release.sh` is not a dry-run command. It submits to Apple, changes version data,
creates a tag and creates a remote draft release. Its execution and the final
public launch each require approval at their respective gates. It still uses the
older Finder-automation layout, not the verified dmgbuild procedure; do not run it
over the prepared artifact directory or assume its output has these acceptance results.
