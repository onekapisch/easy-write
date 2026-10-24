# Easy Write 2.0.2, build 28

Public patch date: 2026-10-24. Owner explicitly authorized the Mail selection patch release.
Source: `a83fb0bbe9407c33530b7a5bf929890a3a2a5db0`, tagged `v2.0.2`.
Candidate: `dist/release-2.0.2-b28.5ignq9hc/` (ignored, immutable signed artifacts).

## Preparation and validation

- The first candidate stopped before notarization because macOS ignored TMPDIR for evaluation.
  It has no VERIFIED.json and must not be distributed. The harness now receives an explicit
  absolute developer output directory; two regression checks cover override and fallback.
- 125 self-tests, six real-model smoke scenarios and all 40 synthetic evaluation rows pass.
  No model errors or formal-register leaks were detected in the shipping prompt results.
  This is register/smoke evidence, not an overall quality or compatibility certification.
- App notarization `5c3e35be-a754-4fc1-b28c-d0398793076f`: Accepted, stapled and validated.
- DMG notarization `893abfd4-9fa7-4872-a6f4-a94671d5f37e`: Accepted, stapled and validated.
- Strict signatures, Gatekeeper, hdiutil checks and both read-only mounted-payload checks pass.
  Payload bundle identifier, version/build, arm64 architecture, feed URL and public key match.
- Existing Developer ID and Keychain Sparkle key used without credential export. Optional
  update consent remains unchanged. No old release assets or Finder bundle metadata changed.
- Sparkle payload and newly signed feed verify; independent Node Ed25519 verification against
  the app public key passes. Feed retains 2.0.1 build 27 and 2.0 build 24.

## Public artifact verification

- Public release: https://github.com/onekapisch/easy-write/releases/tag/v2.0.2
- Versioned and stable DMGs: 4,008,406 bytes, SHA-256
  `cc3a7dcd9e9327c536646ec2ed03b01962a5271180131d592286de1636288bd1`.
- Signed appcast SHA-256:
  `b125a856ce16b22cc1acbd692719c0725db0c5a337c22ab971789bfe9f657c8c`.
- All three GitHub assets were downloaded and match VERIFIED.json. Downloaded DMG staple,
  Gatekeeper and independent payload-signature checks pass; downloaded feed signature verifies.
- Canonical website feed deployment and installed upgrade are separate checks recorded below.

## Physical acceptance scope

The owner confirmed Mail translation or preview works on the signed local 27.1 build.
Full in-place replacement, wider application/version compatibility, VoiceOver and clean-Mac
installation remain separate acceptance items. Do not infer any of these from notarization.
