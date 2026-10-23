# Release checklist

## Website search content

- P0: Publication is approved on 2026-10-23. The coordinator must verify the deployed guides,
  product page, version-pinned DMG and signed feed, then replace publication-in-progress notices
  with the verified live state. Do not treat approval as proof of public availability.
- P1: Establish Search Console/Bing query baselines after approved publication. The 62-query
  research map contains suggestions and proposed variants, not search-volume or install metrics.
- P1: Native-speaker review of German examples and physical app compatibility evidence before
  stronger quality, savings or customer-outcome claims. See `docs/seo/2026-10-23/`.

## P0: authorized 2.0 publication — coordinator verification pending

- Publish only `dist/notarized-2.0-b24.mHw0DB/EasyWrite-2.0.dmg` (2.0 build 24,
  3,987,107 bytes, SHA-256 `586ab04082d3542d4796d3b930b15f750f01a1e44c0c760569b346a438ed4c6c`)
  and its matching signed appcast. Do not rebuild or mutate the accepted payload for this launch.
- Coordinator: verify the GitHub release/source state, exact public DMG bytes, canonical product
  page download control and deployed signed feed. Record dated live evidence in the handoff and
  replace pending-state wording in README, CHANGELOG, SECURITY, AGENTS and the notarization record.
- Deploy the generated signed appcast and shared-action page on the existing OneKapisch product
  path. Keep DMGs on GitHub Releases. Owner publication approval is recorded; this docs task
  must not deploy, publish, commit, tag or push.

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
Planned DMG: https://github.com/onekapisch/easy-write/releases/download/v2.0/EasyWrite-2.0.dmg.
Planned feed: https://www.onekapisch.com/products/easy-write/appcast.xml.
Public availability awaits coordinator verification. Even a verified live feed does not prove
an installed automatic upgrade succeeded.
