"""Checks the string catalog: every interface string has German, and placeholders survive translation.

Run: python3 -m unittest discover -s tools -p test_localization.py

To pick up new or changed strings after editing Swift code:
    swift build -c release -Xswiftc -emit-localized-strings -Xswiftc -emit-localized-strings-path -Xswiftc /tmp/ew-strings
    rm /tmp/ew-strings/{Eval,SelfTest,Snapshots,LaunchAssets,RegisterCheck,main}.stringsdata
    xcrun xcstringstool sync Resources/Localizable.xcstrings --stringsdata /tmp/ew-strings/*.stringsdata
Then add the German for each new key (state "translated") and run this test.
"""
import json
import re
import unittest
from collections import Counter
from pathlib import Path

CATALOG = Path(__file__).resolve().parent.parent / "Resources" / "Localizable.xcstrings"
SPEC = re.compile(r"%(?:\d+\$)?(?:ll|l)?[@dfs]")


def specs(text):
    """Placeholder types, ignoring position: German may reorder them with %1$@, %2$@."""
    return Counter(re.sub(r"\d+\$", "", s) for s in SPEC.findall(text))


def values(loc):
    """Every string a localization can produce: a plain value or each plural form."""
    if "stringUnit" in loc:
        yield loc["stringUnit"]
    for forms in loc.get("variations", {}).values():
        for form in forms.values():
            yield form["stringUnit"]


class CatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.strings = json.loads(CATALOG.read_text())["strings"]

    def test_source_language_is_english(self):
        self.assertEqual(json.loads(CATALOG.read_text())["sourceLanguage"], "en")

    def test_every_string_has_german(self):
        missing = [k for k, e in self.strings.items()
                   if e.get("shouldTranslate", True) and "de" not in e.get("localizations", {})]
        self.assertEqual(missing, [], "strings without German")

    def test_german_is_translated_not_draft(self):
        drafts = [k for k, e in self.strings.items()
                  for u in values(e.get("localizations", {}).get("de", {}))
                  if u["state"] != "translated" or not u["value"].strip()]
        self.assertEqual(drafts, [], "German strings that are empty or not marked translated")

    def test_placeholders_match(self):
        bad = []
        for key, e in self.strings.items():
            for lang, loc in e.get("localizations", {}).items():
                for u in values(loc):
                    if specs(u["value"]) != specs(key):
                        bad.append((lang, key, u["value"]))
        self.assertEqual(bad, [], "placeholders differ from the English key")

    def test_no_stale_strings(self):
        stale = [k for k, e in self.strings.items() if e.get("extractionState") == "stale"]
        self.assertEqual(stale, [], "strings no longer in the code; remove them from the catalog")


if __name__ == "__main__":
    unittest.main()
