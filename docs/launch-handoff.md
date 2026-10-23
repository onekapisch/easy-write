# Easy Write 2.0 launch handoff

Updated 2026-10-23. The owner explicitly approved publishing Easy Write 2.0 build 24 now.
Publication and public artifact delivery were verified on 2026-10-23 at 09:46 UTC.
The accepted app/DMG were not rebuilt or changed. Physical compatibility and installed
upgrade acceptance remain separate from successful public delivery.

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
the version-pinned download is now active and verified on the deployed page.
The control is not an Apple badge. The earlier checks above describe the local preview;
current publication evidence is recorded in section 4.

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

The signed appcast is locally verified and its public copy is byte-identical and verifies.
It was prepared using Sparkle's supported manual signing path after an automated generator
attempt stalled. No private key was exported.
See [the notarization record](notarization-2.0-build24.md) for IDs and packaging details.
Clean-Mac install/launch, installed Sparkle upgrades and physical compatibility remain outstanding.

## 4. Coordinated public launch: live and verified

The earlier pre-launch public check reported v1.1.1 with no binary assets and 404 responses
for the appcast and latest DMG. That is historical evidence, not a current live check.
The owner approved publication, and the exact accepted artifact has now been published.

Verified public destinations:

- DMG: https://github.com/onekapisch/easy-write/releases/download/v2.0/EasyWrite-2.0.dmg
- Product: https://www.onekapisch.com/products/easy-write/
- Feed: https://www.onekapisch.com/products/easy-write/appcast.xml

- GitHub release `v2.0` is public, non-prerelease and latest, published 09:41 UTC.
  Annotated tag resolves to `8785ce6fc9bfcf0deb11700b0d924a7ee3e46d1a`.
- Downloaded both `EasyWrite-2.0.dmg` and stable `EasyWrite.dmg` from GitHub. Both
  match the size and SHA-256 in section 3. The public versioned DMG passes strict
  signing, stapler validation, Gatekeeper and Sparkle payload-signature verification.
- Downloaded the public feed. It is byte-identical to the locally signed feed, is
  valid XML and passes Sparkle verification. Feed SHA-256:
  `5474a641d7a99efc0a89ff6c12b23fdae688933b8c1934bbff217c30550172b6`.
- Production deployment `dpl_HmDk97pEESTQBLQ1ABJfL99vdnqp` is Ready and aliased to
  `www.onekapisch.com`. It was built from website main commit
  `d858f20e132c8652af74154a15161d474a1e3fd2`.
- Live browser verification found the new page, three active pinned download links,
  source/release links and media. The shared-action utility rendered a synthetic
  recipe correctly and offered its reviewed-import deep link without auto-opening it.
- Final website checks: build/lint/syntax, 25 site tests, 13 Easy Write checks,
  static release verification (48 routes, 51 HTML, 263 files), and 69 browser checks
  with 75 screenshots passed. Four documented non-fatal Orbit warnings remain.
  Additional 375px inspection has no visible overflow.

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
