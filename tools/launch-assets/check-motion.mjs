import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';

const file = 'launch-assets/v2/.capture/notch-native.mp4';
const probe = JSON.parse(execFileSync('ffprobe', ['-v','error','-show_streams','-show_format','-of','json',file], {encoding:'utf8'}));
// The top edge stays inside the pill through both transitions; lower rows disappear
// early during retraction and cannot measure the complete collapse spring.
const rows = execFileSync('ffmpeg', ['-v','error','-i',file,'-vf','fps=60,format=rgb24,crop=1440:1:0:20','-f','rawvideo','-pix_fmt','rgb24','pipe:1'], {maxBuffer:16*1024*1024});
const widths = [];
for (let frame = 0; frame < Math.floor(rows.length / 4320); frame++) {
  let first = -1, last = -1;
  for (let x = 0; x < 1440; x++) {
    const i = frame * 4320 + x * 3;
    if (rows[i] < 25 && rows[i+1] < 25 && rows[i+2] < 25) {
      if (first < 0) first = x;
      last = x;
    }
  }
  // Measure the outside edges, not the dark-pixel count (text and shimmer change that count).
  widths.push(first < 0 ? 0 : last - first + 1);
}
const expansion = [...new Set(widths.slice(45,140))].sort((a,b)=>a-b);
const collapse = [...new Set(widths.slice(300,365))].sort((a,b)=>a-b);
const stream = probe.streams.find(s=>s.codec_type==='video');
const proof = {desktopCaptured:false, capture:'ScreenCaptureKit owned-window filter', permission:'pre-existing only',
  capturedFrames:Number(stream.nb_frames),duration:Number(probe.format.duration),
  nativeMasterSha256:createHash('sha256').update(readFileSync(file)).digest('hex'),
  distinctExpansionWidths:expansion,distinctCollapseWidths:collapse};
writeFileSync('launch-assets/v2/.capture/motion-proof.json', JSON.stringify(proof,null,2)+'\n');
if (expansion.length < 6 || collapse.length < 6) throw new Error(`Animation not preserved: ${expansion.length} expansion / ${collapse.length} collapse widths`);
console.log(`Native motion verified: ${expansion.length} expansion widths, ${collapse.length} collapse widths.`);
