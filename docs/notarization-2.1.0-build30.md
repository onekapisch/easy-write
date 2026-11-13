# Easy Write 2.1.0 build 30

Prepared 2026-11-13 with owner approval to complete German UI checks and publish.
Status at preparation: accepted candidate, not yet published. Build 29 stays immutable
and is superseded before publication because the live German sidebar truncated a label.

## Source and UI acceptance

- Source commit: `debf488c87f742adbbbd59d8433697dfebebad76`, branch `feat/german-ui`.
- Settings now enforces a 190-point List minimum and a 900-point window minimum. The
  native split column's ideal width alone did not prevent compression on this Mac.
- Live German menu, Settings and full "Kurzbefehle" labels/controls inspected; proof under
  ignored `dist/release-proof-2.1.0/`. The owner confirmed that the German Bar opens and is readable.
- Language was overridden only for the temporary test process; the Mac's system language
  and the installed 2.0.2 app were not changed for this UI check.
- Six appearance/positioning checks, 23 Python release/localization checks and 125 native
  self-tests passed. The source-width regression failed before the layout fix.

## Accepted artifacts

Candidate: `dist/release-2.1.0-b30.nw5oepq5/`.

- App notarization: `b9acfa28-d1d4-48a2-adff-fbd56de7679e`, Accepted.
- DMG notarization: `cfd590c5-dcd5-4782-9959-f5bf9e4e878a`, Accepted.
- Versioned/stable DMGs: 4,034,077 bytes, SHA-256
  `ad76d7f16d223966ac3132b0f026c44ac6dc2848b84038f624f1e492afa86209`.
- Signed feed SHA-256: `beb3fd44af04bd2cafb63808e8ad89247f0628df1a74a84a93ed658d830fc04c`.
- `SHA256SUMS.txt` is generated from the accepted final files and must be attached to the release.
- Full runner exited 0: strict signatures, six real-model smoke checks, Accepted statuses,
  stapling, Gatekeeper, mounted checks before/after outer notarization and Sparkle signatures.
- Evaluation was not skipped: 40 rows, no model errors and no detected shipping-prompt
  formal-register leaks. This is not a meaning/naturalness or general accuracy certification.
- Feed leads with version 30 / 2.1.0 and preserves prior releases. Do not edit signed bytes.

## Publication and installed-upgrade evidence, 2026-11-13

- Public release: <https://github.com/onekapisch/easy-write/releases/tag/v2.1.0>.
  The annotated tag resolves to the accepted source commit above. Versioned/stable DMGs,
  signed `appcast.xml` and generated `SHA256SUMS.txt` are attached; no accepted bytes rebuilt.
- Public DMG/feed downloads match the hashes above. Public checksum asset SHA-256:
  `fe247c9a0ddff6e510e777dfdc66145bce13592ad9da905a14e472b4bbc43f53`.
  Sparkle payload and feed signature verification passed on downloaded files.
- Homebrew cask version/hash updated in `onekapisch/homebrew-tap` commit
  `e7571564eb7ffc4efe9bd0336c0f8c317dd49a5b`; Ruby syntax passed. A Homebrew installation
  was not performed.
- Website release commit `8a9c91f0f09038f8e0f499bdc866c5e17ba918b3` deployed Ready as
  `dpl_ECsXR9btNGBj6wCQDVYbnNXT5LVy` to <https://www.onekapisch.com/products/easy-write/>.
  English/German download links and schema version are 2.1.0. Both routes fit at 375px.
  Build/lint/type checks, 25 general tests, 23 scoped tests and 98 browser checks passed;
  browser evidence contains 90 screenshots and four documented nonfatal Orbit warnings.
- The installed `/Applications/Easy Write.app` began at 2.0.2 build 28. Settings → Updates
  discovered 2.1.0 from the live feed. Install Update downloaded it, then Install and Relaunch
  replaced the app and launched 2.1.0 build 30. A further check reports up to date.
- Strict/deep code signature verification, Gatekeeper Notarized Developer ID assessment and
  stapler validation passed on the installed app. Installed executable SHA-256 equals the
  accepted candidate: `9229aa665f0fb0672d2527147e38c44773d7c439f8cbdc0403bc7bd48def31c9`.
- Only the installed app remains running. Update preferences, history consent and system
  language were not changed. Local proof images remain ignored, not public marketing assets.

## Remaining physical gates

Clean-Mac installation, unattended update behavior, VoiceOver and the broader host-app
compatibility matrix remain separate, uncompleted checks. Publication does not force updates.
