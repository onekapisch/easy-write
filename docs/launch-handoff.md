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

## 3. Local release candidate: signed, NOT notarized

Prepared an ignored local candidate at
`dist/local-candidate.XuwTE1/EasyWrite-2.0-LOCAL-UNNOTARIZED.dmg`.

- App and DMG Developer ID signatures verified. App has hardened runtime and a
  secure timestamp. Its embedded version is 2.0, build 4, minimum macOS 26.
- DMG integrity verified; mounted read-only; mounted executable matched the
  packaged candidate; all 75 mounted-binary self-tests passed.
- Embedded Sparkle public key matched the existing Keychain public key. A local
  EdDSA signature round-trip over the DMG verified. No private key was exported.
- The normal working source bundle was rebuilt with update configuration disabled.
- DMG SHA-256: `f9043487d434d02f87204995310d98865164241bebca8537ea6828e4aadbfcf5`.
- Gatekeeper correctly rejects the candidate as `Unnotarized Developer ID`.
  Do not distribute this candidate as an installation-ready release.

`notarytool history --keychain-profile easywrite-notary` fails because the profile
does not exist. The owner must configure notarization credentials privately in
Terminal, or identify an existing appropriate profile. Do not put an Apple ID
password, app-specific password or private key in chat or this repository.

Owner-only credential setup in Terminal, using the developer Apple ID for the
existing Developer ID team:

```sh
xcrun notarytool store-credentials easywrite-notary --apple-id YOUR_APPLE_ID --team-id UMSLY366R9
```

Replace `YOUR_APPLE_ID` privately. The command prompts securely for an Apple
app-specific password, validates the credentials and stores them in Keychain.
Do not add `--password` to shell history and do not paste credentials into chat.

After credentials and explicit submission approval: notarize and staple the app,
rebuild/sign/notarize/staple the DMG, check Gatekeeper and a clean-Mac installation,
then generate a fresh appcast. Stapling changes the file: do not reuse the current
DMG's signature, hash or a preview feed for the final payload.

## 4. Coordinated public launch: not executed

Public GitHub still reports v1.1.1 with no binary assets. The appcast and latest DMG
URLs return 404. No tag, push, draft release, notarization submission or deployment
was performed by this preparation task.

Before publishing: validate the installed Sparkle upgrade path, publish the exact
signed payload and matching feed together, switch the website's shared preview
CTA state to the verified version-pinned download, update README/release notes,
and verify all public URLs. Pre-Sparkle 1.x users need one manual upgrade; they
cannot receive an updater retroactively. Optional checks in the new build concern
future releases and still require user consent.

`release.sh` is not a dry-run command. It submits to Apple, changes version data,
creates a tag and creates a remote draft release. Its execution and the final
public launch each require approval at their respective gates.
