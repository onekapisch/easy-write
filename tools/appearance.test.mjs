import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const menu = readFileSync(new URL('../Sources/EasyWrite/UI/MenuPanel.swift', import.meta.url), 'utf8');
const snapshots = readFileSync(new URL('../Sources/EasyWrite/Dev/Snapshots.swift', import.meta.url), 'utf8');

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
