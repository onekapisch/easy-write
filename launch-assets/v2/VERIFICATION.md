# Launch kit verification

2026-10-23. Local artifacts only. No publication or website implementation.

- Release build: passed without compiler warnings.
- App self-tests: 75 passed, zero failed.
- Asset tests: six passed, zero failed after the final encode and inventory regeneration.
- 24 distributable media files, including unmodified native capture, web videos and stills.
- Primary artwork: 2400 × 1800. Social artwork: 1280 × 640; JPEG below 1 MB.
- Native motion proof measures outside shape edges, not changing text or shimmer pixels.
  The native master contains 18 expansion widths and 14 collapse widths at the measurement row.
  Delivered-MP4 tests separately confirm both transitions survive encoding.
- Found and fixed: cached AppKit drawing omitted presentation animation; an output-rate-only
  FFmpeg conversion then lost intermediate frames. Owned-window ScreenCaptureKit capture plus
  an explicit fps filter preserves them. The original recording is retained for comparison.
- Gallery playback completed with no media error. The player keeps its correct 12:7 ratio.
  The 375px layout had no horizontal overflow. Still-image and menu-bar compositions inspected.
- Intermediate capture files are ignored by Git. Manifest paths are relative. Only synthetic
  sample text/settings and the owned demo window are captured; no desktop display is recorded.

The film records the production native HUD on a staged canvas. It does not demonstrate actual
translation latency, text insertion or app compatibility. A separate real workflow movie and
the release/distribution gates remain open in TODO.md and the website proposal.
