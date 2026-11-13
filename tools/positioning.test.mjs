import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = (path) => readFileSync(new URL(`../${path}`, import.meta.url), 'utf8');
const tagline = 'Translate and rewrite without switching apps.';

test('README leads with the approved product tagline', () => {
  assert.ok(read('README.md').includes(`### ${tagline}\n`));
});

test('app and launch copy share the approved tagline', () => {
  assert.ok(read('Sources/EasyWrite/Core/AppCopy.swift').includes(`static let tagline = String(localized: "${tagline}")`));
  for (const path of ['UI/SettingsWindow.swift', 'Core/StudioDay.swift', 'Dev/LaunchAssets.swift']) {
    assert.ok(read(`Sources/EasyWrite/${path}`).includes('AppCopy.tagline'), path);
  }
});

test('German interface carries the tagline', () => {
  const catalog = JSON.parse(read('Resources/Localizable.xcstrings'));
  assert.equal(catalog.strings[tagline].localizations.de.stringUnit.value,
    'Übersetzen und umschreiben, ohne die App zu wechseln.');
});
