# Easy Write 2.0, build 24: notarization record

Date: 2026-10-23. Owner configured the `easywrite-notary` Keychain profile and
authorized continuing the previously described notarization workflow. No credential
was received in chat, exported or added to the repository. No public release is
implied by this record.

## Pre-submission gates

- Profile authentication succeeded.
- Release build and 75 isolated self-tests passed.
- Six real-model synthetic smoke checks passed.
- Forty-sentence informal German evaluation: shipping prompt had 0 definite formal
  register leaks; candidate prompt had four and remains unused. No generation errors
  occurred. This does not certify meaning, naturalness or all-language accuracy.
- Read-only release configuration review found no scoped P1/P2 blockers.
- Bundle: 2.0 build 24, arm64, minimum macOS 26.0, Developer ID, hardened runtime,
  secure timestamp, release update configuration retained. No app runtime code changed.

## App submission

- Output directory: `dist/notarized-2.0-b24.mHw0DB/` (ignored by Git).
- Archive: `EasyWrite-2.0-b24-notarization.zip`.
- Submission ID: `a49bf252-d7db-4a1a-9df7-b9159163f608`.
- Apple status: **Accepted**. Stapler staple and validate passed; strict signature
  verification passed; Gatekeeper reports **accepted, Notarized Developer ID**.

## DMG submission

- Installer: `EasyWrite-2.0.dmg`, with the existing branded background, fixed icon
  positions and an Applications shortcut. Built using dmgbuild 1.6.7, ds_store 1.3.3
  and mac_alias 2.2.3 in a temporary build-only virtual environment. No Finder
  automation permission was requested and these tools are not bundled in the app.
- Submission ID: `c792766b-a1a2-4248-8ec1-bba5b0d35122`.
- Apple accepted this first DMG, but the mounted app failed strict signature
  verification: the optional hide-extension setting used `SetFile -a E`, adding
  `com.apple.FinderInfo` after app signing. The source app remained valid.
- This first image is retained under `rejected/` for traceability and must never
  be distributed. Its appcast-generation attempt was stopped; no feed was published.
- Added `dmg/settings.py`, with both metadata-mutating options disabled, and a
  regression test (observed failing before the settings existed, then passing).
- Rebuilt image: mounted app passed strict signature, stapler and Gatekeeper.
  A copy extracted into a disposable Applications directory passed the same
  signature/Gatekeeper checks and all 75 self-tests. Icon positions and branded
  background were verified from the volume metadata.
- Corrected DMG submission: `5c086a1d-9462-4587-b0f6-8a1756cb8ecb`.
- Apple status: **Accepted**. Stapler staple/validate, strict DMG signature and
  Gatekeeper checks passed. `hdiutil verify` passed on the final stapled image.
- Final read-only mount: app strict signature, stapler validation, Gatekeeper and
  75 self-tests passed again after the outer DMG was notarized and stapled. The
  disposable extracted copy passed `syspolicy_check distribution` (exit 0).
- Final size: **3,987,107 bytes**.
- Final SHA-256: `586ab04082d3542d4796d3b930b15f750f01a1e44c0c760569b346a438ed4c6c`.
- macOS 27 printed hdiutil deprecation notices; these were toolchain warnings, not failures.

## Update payload and feed

The automated appcast generator stalled on the first image and was stopped without
publication. The final local `appcast.xml` uses Sparkle's documented manual feed
and signing workflow: https://sparkle-project.org/documentation/publishing/.

- `sign_update` signed the final stapled DMG using the existing Keychain key.
- Payload signature verified with Sparkle and independently with Node's Ed25519
  verification against the public key embedded in the release app.
- Feed XML is well-formed, signed and verified by Sparkle. Its version 24, short
  version 2.0, minimum macOS 26.0.0, arm64 requirement, payload length and planned
  version-pinned GitHub download URL match the final artifact.
- This proves local signature/metadata consistency, not a live installed update.
  Do not modify the DMG after signing; any change requires a fresh hash and signature.

## Reproducing the layout

Use an isolated build-only virtual environment with dmgbuild 1.6.7, ds_store 1.3.3
and mac_alias 2.2.3. First notarize and staple the signed app. Run the layout test:

```sh
python3 -m unittest discover -s dmg -p test_settings.py
```

Call `dmgbuild.build_dmg(output, "Easy Write", settings_file="dmg/settings.py",
defines={"app": accepted_app_path, "background": "dmg/background.tiff"})` from the
environment's Python. Use a new output directory, not this accepted candidate's path.
The layout stores cosmetic settings in `.DS_Store`; never enable `hide` or
`hide_extensions`, which invoke SetFile on signed bundle metadata. Mount read-only
and strictly verify the enclosed app before signing/submitting the DMG. After Apple
acceptance, staple and validate the DMG, verify Gatekeeper, and repeat mounted checks.
Only then compute the final hash, payload signature and feed.

`release.sh` was not used: it still has a different Finder-automation packaging
path and destructive/publishing side effects. Update and review it separately
before using it for a future release. The normal root app bundle currently retains
the release-configured, notarized build; a default source rebuild disables updates.

## Publication boundary

No tag, push, GitHub release or website deployment is performed by this record.
The website download control stays disabled until a final installer has passed
acceptance and its public URL is verified. Clean-Mac installation, installed
Sparkle upgrades, physical app compatibility and VoiceOver remain separate gates.
