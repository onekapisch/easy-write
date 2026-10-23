import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { resolve } from 'node:path';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';

const root = resolve('launch-assets/v2');
const imageNames = ['hero-daylight', 'hero-midnight', 'menu-bar', 'tones', 'reader', 'actions', 'notch-poster'];

test('complete launch images, raw UI, video and social assets exist', () => {
  const files = [...imageNames.flatMap(n => [`images/${n}.png`, `images/${n}.webp`]),
    ...['bar', 'menu-bar', 'reader', 'actions'].map(n => `raw/${n}.png`),
    'video/notch-native-master.mp4', 'video/notch-animation.mp4', 'video/notch-animation.webm', 'video/notch-animation.gif',
    'social/github-social.jpg', 'manifest.json', 'gallery.html', 'README.md'];
  for (const file of files) assert.ok(existsSync(resolve(root, file)), `missing ${file}`);
});

test('hero is high resolution and GitHub social image is below 1 MB', () => {
  const png = readFileSync(resolve(root, 'images/hero-daylight.png'));
  assert.equal(png.readUInt32BE(16), 2400);
  assert.equal(png.readUInt32BE(20), 1800);
  assert.ok(statSync(resolve(root, 'social/github-social.jpg')).size < 1_000_000);
});

test('native animation has at least six seconds and sixty fps', () => {
  const result = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-show_streams', '-show_format',
    '-of', 'json', resolve(root, 'video/notch-animation.mp4')], { encoding: 'utf8' }));
  const video = result.streams.find(s => s.codec_type === 'video');
  assert.equal(video.avg_frame_rate, '60/1');
  assert.ok(Number(result.format.duration) >= 6);
  assert.equal(video.width, 1440);
  assert.equal(video.height, 840);
});

test('provenance discloses staged timings and no desktop capture', () => {
  const manifest = JSON.parse(readFileSync(resolve(root, 'manifest.json'), 'utf8'));
  assert.equal(manifest.desktopCaptured, false);
  assert.equal(manifest.syntheticText, true);
  assert.equal(manifest.motion.timing, 'staged');
  assert.equal(manifest.motion.renderer, 'native SwiftUI HUDView');
  assert.ok(manifest.motion.distinctExpansionWidths.length >= 6);
  assert.ok(manifest.motion.distinctCollapseWidths.length >= 6);
});

test('manifest hashes match every deliverable and bind the proof to the native master', () => {
  const manifest = JSON.parse(readFileSync(resolve(root, 'manifest.json'), 'utf8'));
  for (const file of manifest.files) {
    const bytes = readFileSync(resolve(root, file.file));
    assert.equal(bytes.length, file.bytes, file.file);
    assert.equal(createHash('sha256').update(bytes).digest('hex'), file.sha256, file.file);
  }
  assert.equal(manifest.motion.nativeMasterSha256,
    manifest.files.find(f => f.file === 'video/notch-native-master.mp4').sha256);
});

test('delivered MP4 preserves expansion and collapse, not just declared frame rate', () => {
  const rows = execFileSync('ffmpeg', ['-v','error','-i',resolve(root,'video/notch-animation.mp4'),
    '-vf','fps=60,format=rgb24,crop=1440:1:0:20','-f','rawvideo','-pix_fmt','rgb24','pipe:1'], {maxBuffer:16*1024*1024});
  const widths=[];
  for(let f=0;f<Math.floor(rows.length/4320);f++) {
    let first=-1,last=-1;
    for(let x=0;x<1440;x++) {
      const i=f*4320+x*3;
      if(rows[i]<25&&rows[i+1]<25&&rows[i+2]<25){if(first<0)first=x;last=x;}
    }
    widths.push(first<0?0:last-first+1);
  }
  for(const trace of [widths.slice(45,140),widths.slice(300,365)]) {
    assert.ok(new Set(trace).size>=6,'intermediate shape widths survive encoding');
    assert.ok(Math.max(...trace)>=700,'expanded state survives encoding');
    assert.ok(Math.min(...trace)<=380,'collapsed state survives encoding');
  }
});
