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

## Remaining publication and physical gates

Publish the exact accepted source tag and assets before deploying the matching signed feed
and EN/DE downloads. Public payload/download consistency and an installed 2.0.2-to-2.1.0
Sparkle upgrade must be verified after publication. Clean-Mac installation, VoiceOver and
the broader host-app compatibility matrix remain separate, uncompleted checks.
