#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
out="launch-assets/v2"
swift build -c release
./.build/release/EasyWrite --launch-assets "$out"
node tools/launch-assets/check-motion.mjs
cp "$out/.capture/notch-native.mp4" "$out/video/notch-native-master.mp4"
ffmpeg -y -loglevel error -ss 3.7 -i "$out/.capture/notch-native.mp4" -frames:v 1 -update 1 "$out/images/notch-poster.png"
for file in "$out"/images/*.png; do
  ffmpeg -y -loglevel error -i "$file" -c:v libwebp -quality 92 -compression_level 6 "${file%.png}.webp"
done
ffmpeg -y -loglevel error -i "$out/social/github-social.png" -q:v 2 -frames:v 1 -update 1 "$out/social/github-social.jpg"
ffmpeg -y -loglevel error -i "$out/.capture/notch-native.mp4" -vf fps=60 -fps_mode cfr -c:v libx264 -crf 17 -preset slow -pix_fmt yuv420p -movflags +faststart -an "$out/video/notch-animation.mp4"
ffmpeg -y -loglevel error -i "$out/video/notch-animation.mp4" -c:v libvpx-vp9 -b:v 0 -crf 28 -row-mt 1 -an "$out/video/notch-animation.webm"
ffmpeg -y -loglevel error -i "$out/video/notch-animation.mp4" -filter_complex 'fps=18,scale=720:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=sierra2_4a:diff_mode=rectangle' -loop 0 "$out/video/notch-animation.gif"
node tools/launch-assets/manifest.mjs
node --test tools/launch-assets/verify.test.mjs
