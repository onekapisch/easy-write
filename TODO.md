# Release checklist

## 2.0.1 appearance patch

- [x] Reproduced missing menu foundation and forced-dark appearance in source; regression
  tests failed before the fix and pass after it. Native snapshots now use production backgrounds.
- [x] Verify final signed 2.0.1 build 27, notarize app and DMG, verify mounted payload and Sparkle
  signature. See `docs/notarization-2.0.1-build27.md`.
- [x] Public 2.0.1 GitHub assets match the accepted bytes and signatures; matching website
  deployment is Ready and public download controls point at 2.0.1.
- [ ] Independently verify canonical XML endpoint bytes; browser XML opening/download and
  Vercel Git-deployment file-tree inspection were unavailable. Signed source/output match.
- [ ] Verify an installed 2.0 Sparkle upgrade to 2.0.1. Feed availability is not install completion.

## Website search content

- Done 2026-10-23: published the redesigned page, guides, installer and signed feed with owner
  approval. Public payload bytes/signature and feed bytes/signature passed verification.
- P1: Establish Search Console/Bing query baselines after approved publication. The 62-query
  research map contains suggestions and proposed variants, not search-volume or install metrics.
- P1: Native-speaker review of German examples and physical app compatibility evidence before
  stronger quality, savings or customer-outcome claims. See `docs/seo/2026-10-23/`.

## Completed: 2.0 public delivery, 2026-10-23

- Publish only `dist/notarized-2.0-b24.mHw0DB/EasyWrite-2.0.dmg` (2.0 build 24,
  3,987,107 bytes, SHA-256 `586ab04082d3542d4796d3b930b15f750f01a1e44c0c760569b346a438ed4c6c`)
  and its matching signed appcast. Do not rebuild or mutate the accepted payload for this launch.
- Verified public GitHub release/source state, exact DMG bytes, active canonical-page controls
  and signed feed. See the dated handoff. Versioned and stable-name DMGs have the same hash.
- Deployed the matching appcast and shared-action page on the existing OneKapisch product path.
  DMGs remain GitHub Releases assets. Independent physical acceptance is not implied.

## P0: outstanding acceptance — not completed by publication approval

- Complete the physical workflow recording and clean-Mac installation check in
  `docs/launch-handoff.md`. Build 24 is signed, notarized and stapled;
  static installer and payload-signature checks pass, not clean-Mac acceptance.
- Physical cross-app acceptance on TextEdit/Notes, browser textareas, WhatsApp and Mail: normal
  replacement, moved selection, changed field/tab/window/app, clipboard copies during inference,
  slow paste, Cancel, Bar preview and pinned reader. Use synthetic text, never private drafts.
- Confirm VoiceOver navigation and announcements with VoiceOver enabled.
- Done locally: private notarization credentials configured; app and corrected DMG
  accepted by Apple, stapled and Gatekeeper-verified. See `docs/notarization-2.0-build24.md`.
- Sparkle public-key matching and local payload signature verification passed. Still test an installed older Sparkle build
  updating to the release. Pre-Sparkle 1.x needs a manual upgrade.
- Before any reuse, bring `release.sh` in line with the verified no-Finder packaging
  procedure and mounted strict-signature gate. The build-24 handoff does not use that script.

## P1

- Homebrew is not live and is not part of the approved manual-DMG launch. Assess and validate
  a tap separately before adding Homebrew install instructions or availability claims.
- Review the 2.0 launch gallery and implemented local website preview. The owner reports
  the workflow working after a physical test; do not treat that report as a completed app matrix.
- Before claiming a real workflow demonstration, record a separate select/shortcut/replace movie.
  The current native HUD film uses staged timings and does not demonstrate translation delivery.
- Selection API compatibility matrix for native, browser and Electron apps. Unsupported targets
  must use review mode, never unsafe auto-paste.
- Human evaluation of meaning, register, RTL and truncation across all target languages.
- Test macOS 26.0 byte-budget fallback and 26.4+ model token counts.
- Fault-inject filesystem denial, sleep/wake, offline update feed and model availability changes.

## Hosting

Use https://www.onekapisch.com/products/easy-write/ as the canonical site. No new domain required.
Host the page and small appcast on the current site; signed DMGs belong on GitHub Releases.
DMG: https://github.com/onekapisch/easy-write/releases/download/v2.0/EasyWrite-2.0.dmg.
Feed: https://www.onekapisch.com/products/easy-write/appcast.xml.
Public availability is verified. Even a verified live feed does not prove
an installed automatic upgrade succeeded.
