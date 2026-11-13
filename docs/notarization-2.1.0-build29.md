# Easy Write 2.1.0 build 29: notarized candidate

Prepared 2026-11-13 with owner approval. **Status: prepared, not published.** No tag, push,
GitHub release or feed deployment has happened.

Superseded before publication: live UI inspection found the German Settings sidebar truncated
"Kurzbefehle". Build 30 includes a wider Settings window and enforced sidebar minimum.
Keep this accepted build-29 candidate immutable; it is not the artifact selected for publication.

- Source commit: `e86725d7ad60e959c30684a58f1040056f0f6741` (branch `feat/german-ui`)
- Candidate: `dist/release-2.1.0-b29.fb9e0cjw/`
- Previous feed: live `appcast.xml` fetched 2026-11-13 (newest item 2.0.2 / 28),
  SHA-256 `b125a856ce16b22cc1acbd692719c0725db0c5a337c22ab971789bfe9f657c8c`

## Notarization

| Payload | Submission ID | Status |
|---|---|---|
| App | `010500e0-e1d9-4a95-a423-6d696b165ea5` | Accepted |
| DMG | `1d6dc937-db16-4506-b38b-13f1228deb47` | Accepted |

## Artifacts (SHA-256)

- `EasyWrite-2.1.0.dmg` and `EasyWrite.dmg` (identical, 4,034,293 bytes):
  `ea7d1e06a6f73b81b1e7130fd54a0a8887850900366ffe5eaa71406e26e17316`
- `appcast.xml`: `d002f2ac812b8547ed86e331d15f9270497e6124ee88225ccf9deb0da8a7ba06`
- Sparkle payload signature recorded in the candidate's `VERIFIED.json`.

## Gates passed

- Release runner completed with exit 0: isolated build, strict signatures, self-tests,
  real-model smoke tests, stapling, Gatekeeper and read-only mount checks before and after
  DMG stapling, Sparkle signature verification. Evaluation was not skipped.
- Evaluation: 40 rows; shipping prompt 0 formal-register leaks (candidate prompt, not shipped: 4).
  This is not an accuracy score.
- Checked afterwards: the candidate app contains `en.lproj` and `de.lproj`, declares
  `CFBundleLocalizations` en/de, version 2.1.0 / 29; `spctl` reports "Notarized Developer ID"
  and `stapler validate` passes for the DMG.

## Not yet verified

Clean-Mac install, installed Sparkle upgrade from 2.0.2, use of the running app on a Mac set to
German, cross-app delivery and VoiceOver. Publication steps in `docs/release-process.md` still
need separate owner approval.
