import { readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = resolve('launch-assets/v2');
const proof = JSON.parse(readFileSync(resolve(root, '.capture/motion-proof.json'), 'utf8'));
if (proof.distinctExpansionWidths.length < 6) throw new Error('Native animation has too few intermediate states');
const files = [];
for (const folder of ['images', 'raw', 'video', 'social']) {
  for (const name of readdirSync(resolve(root, folder)).sort()) {
    const file = `${folder}/${name}`;
    const full = resolve(root, file);
    const probe = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-show_streams', '-show_format', '-of', 'json', full], {encoding:'utf8'}));
    const stream = probe.streams.find(s => s.codec_type === 'video');
    files.push({file, bytes:statSync(full).size, width:stream?.width, height:stream?.height,
      ...(folder === 'video' ? {duration:Number(probe.format.duration),frameRate:stream?.avg_frame_rate} : {}),
      sha256:createHash('sha256').update(readFileSync(full)).digest('hex')});
  }
}
const manifest = {version:'2.0', created:new Date().toISOString().slice(0,10), desktopCaptured:false, syntheticText:true,
  UI:'Production SwiftUI views, isolated sample settings. Surrounding backdrops are staged.',
  motion:{renderer:'native SwiftUI HUDView',spring:'NotchHUD.animation',timing:'staged',
    capturedFrames:proof.capturedFrames,distinctExpansionWidths:proof.distinctExpansionWidths,
    distinctCollapseWidths:proof.distinctCollapseWidths,capture:proof.capture,permission:proof.permission,
    nativeMasterSha256:proof.nativeMasterSha256,
    notEvidenceOf:'translation speed, successful paste delivery, or universal app compatibility'},files};
writeFileSync(resolve(root, 'manifest.json'), JSON.stringify(manifest,null,2)+'\n');
console.log(`Inventoried ${files.length} launch assets.`);
