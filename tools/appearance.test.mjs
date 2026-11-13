import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const menu = readFileSync(new URL('../Sources/EasyWrite/UI/MenuPanel.swift', import.meta.url), 'utf8');
const snapshots = readFileSync(new URL('../Sources/EasyWrite/Dev/Snapshots.swift', import.meta.url), 'utf8');
const settings = readFileSync(new URL('../Sources/EasyWrite/UI/SettingsWindow.swift', import.meta.url), 'utf8');

test('Settings sidebar enforces enough minimum width for German labels', () => {
  assert.ok(settings.includes('navigationSplitViewColumnWidth(min: 190, ideal: 215, max: 260)'), 'German sidebar labels need an enforced minimum, not only an ideal width');
  assert.ok(settings.includes('.frame(minWidth: 190)\n            .navigationSplitViewColumnWidth'), 'The List itself must prevent native split-view compression');
  assert.ok(settings.includes('NSSize(width: 900, height: 560)') && settings.includes('.frame(minWidth: 900, minHeight: 560)'), 'Wider sidebar must leave room for the Settings detail controls');
});

test('production menu inherits appearance and supplies its own opaque background', () => {
  assert.doesNotMatch(menu, /NSAppearance\(named: \.vibrantDark\)/);
  assert.doesNotMatch(menu, /environment\(\\\.colorScheme, \.dark\)/);
  assert.match(menu, /\.background\(EW\.panelFill\)/);
});

test('menu snapshots exercise both appearances without a substitute popover fill', () => {
  assert.match(snapshots, /for dark in \[false, true\]/);
  assert.match(snapshots, /for brightBackdrop in \[false, true\]/);
  assert.doesNotMatch(snapshots, /private struct Popover/);
});
