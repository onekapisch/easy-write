# Easy Write 2.0 launch assets

Local launch kit for the existing OneKapisch product page and GitHub repository. Nothing in this
folder publishes a release or changes the website. Daylight is the main treatment; Midnight is
an alternate hero. All sample sentences and settings are synthetic.

Open `gallery.html` through a local HTTP server to review the images and play the film.

## Use these files

| Folder | Purpose |
| --- | --- |
| `images/` | Framed, high-resolution PNG masters and compressed WebP website images |
| `raw/` | Unframed native UI renders: menu-bar panel, Bar, reader and grammar action |
| `video/` | Original native recording, 60 fps MP4/WebM, and an optimized GIF |
| `social/` | 1280 × 640 GitHub social card, PNG master and JPEG below 1 MB |
| `manifest.json` | Dimensions, byte sizes, hashes and capture provenance |
| `WEBSITE-REDESIGN.md` | Proposed narrative, copy, media placement and acceptance gates |

The menu-bar panel is included as both `raw/menu-bar.png` and `images/menu-bar.png`.
History is off and usage counters are zero. Remembered Mail and Slack settings are examples,
not compatibility certification or user testimonials.

## What the notch film records

The film captures the production `HUDView` running natively in a dedicated AppKit window,
using the shipping `NotchHUD.animation` spring. It shows collapsed, expanding, working,
“Paste sent,” and collapsing states. The menu bar, notch backdrop and timings are staged.
This is not a desktop screen recording, a recording of an actual translation, or a speed test.
No private windows, clipboard contents, model requests or user history are captured.

Use the MP4/WebM with native playback controls and a static poster. Respect reduced motion.
Use the GIF only where video is unsuitable, such as a GitHub README. Prefer a static poster
linking to the animation rather than an always-playing hero. Preserve the provenance
caption near the demo, not only inside this file. Keep “Paste sent,” not “Replaced.”

## Reproduce and verify

Requires the app's Swift toolchain, Apple frameworks, Node.js, FFmpeg and FFprobe on PATH.

```bash
bash tools/launch-assets/export.sh
node --test tools/launch-assets/verify.test.mjs
python3 -m http.server 58491 --bind 127.0.0.1 --directory launch-assets/v2
```

The exporter opens its own small animation window briefly. ScreenCaptureKit captures only that
window, using pre-existing Screen Recording permission. It fails without requesting access if
permission is unavailable. It never runs the normal app delegate, registers hotkeys, changes
Accessibility permission, or captures the desktop.
Settings use a fresh throwaway defaults domain. Intermediate native recording and capture
proof live under ignored `.capture/`; the distributable files and manifest remain in this folder.

The tests check required files, master dimensions, social size, film duration/frame rate,
every deliverable's hash, the native-master proof binding, and intermediate HUD widths in both
transitions of the delivered MP4. These checks are not end-to-end translation or release certification.

Do not publish a 2.0 download CTA until the signed, notarized public release is available.
The website plan is a proposal, not approval to implement or deploy it.
