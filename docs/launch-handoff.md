# Easy Write 2.0 launch handoff

Updated 2026-10-23. The owner explicitly approved publishing Easy Write 2.0 build 24 now.
Publication is in progress through the coordinating task; public availability has not yet
been verified here. This documentation task does not publish, commit, tag, push, rebuild,
or modify app/runtime/artifacts.

## 1. Website preview: implemented locally

The isolated OneKapisch website branch is `codex/easy-write-v2-product-page`.
Its existing `/products/easy-write/` route now contains the native Bar, menu panel,
register examples, reader, actions and user-played notch film. Canonical URL and
shared navigation/legal links are preserved. The page has no analytics.

Website verification: build, lint, syntax, 25 existing release tests, four new
preview tests, static artifact verification and 69 browser checks passed. The
browser pass produced 75 screenshots; four documented non-fatal Orbit warnings
remain outside this product page. The founder subsequently approved the page
direction and requested an official direct-download control. A validated installer now exists;
the coordinator must activate the version-pinned download and verify the deployed result.
The control is not an Apple badge. The checks above describe the local preview, not a live deployment.

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
- DMG size: **3,987,107 bytes**. Publish these exact bytes; no rebuild is needed for this launch.
- The first notarized DMG failed a mounted strict-signature check because a cosmetic
  setting added Finder metadata after signing. It is quarantined under `rejected/`.
  The corrected layout disables these mutations and has a regression test.

The signed appcast is locally verified; its public deployment awaits coordinator verification.
It was prepared using Sparkle's supported manual signing path after an automated generator
attempt stalled. No private key was exported.
See [the notarization record](notarization-2.0-build24.md) for IDs and packaging details.
Clean-Mac install/launch, installed Sparkle upgrades and physical compatibility remain outstanding.

## 4. Coordinated public launch: approved, publication in progress

The earlier pre-launch public check reported v1.1.1 with no binary assets and 404 responses
for the appcast and latest DMG. That is historical evidence, not a current live check.
The owner has now approved publication. The coordinator owns GitHub/source publication and
website deployment; this documentation pass changes neither source/runtime nor artifacts.

Approved destinations (planned, not yet verified live here):

- DMG: https://github.com/onekapisch/easy-write/releases/download/v2.0/EasyWrite-2.0.dmg
- Product: https://www.onekapisch.com/products/easy-write/
- Feed: https://www.onekapisch.com/products/easy-write/appcast.xml

Publish the exact signed payload and matching feed together, switch the website's shared
CTA state to the version-pinned download, then verify all public URLs. Compare the downloaded
DMG's size and SHA-256 with section 3, and verify the deployed feed's signature and enclosure
URL/version/length against the same payload. Confirm the intended 2.0 source/release state.
Record dated live evidence before replacing publication-in-progress language in README,
CHANGELOG, TODO, SECURITY, AGENTS and the notarization record. These substitutions belong to
the coordinator's final verified handoff; approval alone is insufficient.

Pre-Sparkle 1.x users need one manual upgrade; they cannot receive an updater retroactively.
Optional checks in the new build concern future releases and still require user consent.
Source builds disable updates by default. Homebrew is not live and is outside this launch.
Clean-Mac install/launch, physical app compatibility, VoiceOver and installed Sparkle upgrade
acceptance remain open. Do not mark them complete or claim automatic upgrade success from
notarization, a working download or a live signed feed. Capture the real workflow before
presenting any film as evidence of actual translation delivery.

`release.sh` is not a dry-run command. It submits to Apple, changes version data,
creates a tag and creates a remote draft release. The approved launch uses the existing
verified artifact, not this script; do not execute it as part of the documentation handoff.
It still uses the older Finder-automation layout, not the verified dmgbuild procedure; do not run it
over the prepared artifact directory or assume its output has these acceptance results.
