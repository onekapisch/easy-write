# Release checklist

## Website search content
- P0: Review the dated six-guide website preview before separate publication approval. Retain
  source-only/preview notices until a validated public distribution exists.
- P1: Establish Search Console/Bing query baselines after approved publication. The 62-query
  research map contains suggestions and proposed variants, not search-volume or install metrics.
- P1: Native-speaker review of German examples and physical app compatibility evidence before
  stronger quality, savings or customer-outcome claims. See `docs/seo/2026-10-23/`.

## P0: before publishing 2.0
- Complete the physical workflow recording and clean-Mac installation check in
  `docs/launch-handoff.md`. Local 2.0 build 24 is signed, notarized and stapled;
  static installer and payload-signature checks pass. It is not published.
- Physical cross-app acceptance on TextEdit/Notes, browser textareas, WhatsApp and Mail: normal
  replacement, moved selection, changed field/tab/window/app, clipboard copies during inference,
  slow paste, Cancel, Bar preview and pinned reader. Use synthetic text, never private drafts.
- Confirm VoiceOver navigation and announcements with VoiceOver enabled.
- Done locally: private notarization credentials configured; app and corrected DMG
  accepted by Apple, stapled and Gatekeeper-verified. See `docs/notarization-2.0-build24.md`.
- Sparkle public-key matching and local payload signature verification passed. Still test an installed older Sparkle build
  updating to the release. Pre-Sparkle 1.x needs a manual upgrade.
- Deploy the generated signed appcast and shared-action page on the existing OneKapisch product
  path. Keep DMGs on GitHub Releases. Publication requires explicit owner approval.
- Publish the validated DMG and Homebrew tap, then update README claims.
- Before any reuse, bring `release.sh` in line with the verified no-Finder packaging
  procedure and mounted strict-signature gate. The build-24 handoff does not use that script.

## P1
- Review the 2.0 launch gallery and implemented local website preview. The owner reports
  the workflow working after a physical test; do not treat that report as a completed app matrix.
- Before website publication, record a separate real select/shortcut/replace workflow movie.
  The current native HUD film uses staged timings and does not demonstrate translation delivery.
- Selection API compatibility matrix for native, browser and Electron apps. Unsupported targets
  must use review mode, never unsafe auto-paste.
- Human evaluation of meaning, register, RTL and truncation across all target languages.
- Test macOS 26.0 byte-budget fallback and 26.4+ model token counts.
- Fault-inject filesystem denial, sleep/wake, offline update feed and model availability changes.

## Hosting
Use https://www.onekapisch.com/products/easy-write/ as the canonical site. No new domain required.
Page and small appcast live on the current site; signed DMGs are GitHub release assets.
The feed and DMG are not yet live, so no automatic-update success claim is justified.
