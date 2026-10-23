"""Release safety tests. Never submit to Apple, sign, mount, or contact GitHub."""
import base64
import contextlib
import io
import importlib.util
from pathlib import Path
import plistlib
import subprocess
import shutil
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
SPARKLE = "http://www.andymatuschak.org/xml-namespaces/sparkle"


class EntryPointTests(unittest.TestCase):
    def test_release_does_not_delete_all_candidates(self):
        self.assertNotIn('rm -rf "$DIST"', (ROOT / "release.sh").read_text())


class ReleaseSafetyTests(unittest.TestCase):
    def setUp(self):
        module = ROOT / "tools/release_support.py"
        self.assertTrue(module.exists(), "release safety helpers must exist before exercising the CLI")
        spec = importlib.util.spec_from_file_location("release_support", module)
        self.release = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.release)
        self.temp = tempfile.TemporaryDirectory(prefix="easywrite-release-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.plist = {"CFBundleShortVersionString": "2.0.2", "CFBundleVersion": "28",
                      "CFBundleIdentifier": "com.onekapisch.easywrite", "LSMinimumSystemVersion": "26.0",
                      "SUFeedURL": "https://www.onekapisch.com/products/easy-write/appcast.xml",
                      "SUPublicEDKey": base64.b64encode(bytes(32)).decode()}
        (self.root / "Info.plist").write_bytes(plistlib.dumps(self.plist))
        (self.root / "CHANGELOG.md").write_text("# Changelog\n\n## [2.0.2] - 2026-10-23\n\n- Preserve <meaning> & tone.\n\n## [2.0.1]\nold\n")
        self.feed = self.root / "previous.xml"
        self.feed.write_text(f'<rss xmlns:sparkle="{SPARKLE}" version="2.0"><channel><title>Updates</title><item><title>Older</title><sparkle:version>27</sparkle:version><sparkle:shortVersionString>2.0.1</sparkle:shortVersionString><enclosure url="https://example.com/old.dmg" length="12" /></item></channel></rss>')

    def test_no_destructive_or_automatic_publication_path(self):
        source = (ROOT / "release.sh").read_text() + (ROOT / "tools/release_support.py").read_text()
        for unsafe in ['rm -rf', 'git checkout', 'tell application "Finder"', 'gh release create', 'git tag', 'git commit', 'git push']:
            self.assertNotIn(unsafe, source)

    def test_plan_does_not_run_external_commands_or_write_files(self):
        before = sorted(self.root.rglob("*"))
        with patch.object(self.release, "run", side_effect=AssertionError("plan invoked a tool")), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(self.release.main(["2.0.2", "--build", "28"], root=self.root), 0)
        self.assertEqual(before, sorted(self.root.rglob("*")))

    def test_invalid_arguments_fail_before_any_external_action(self):
        for args in [["../../bad", "--build", "28"], ["2.0.2", "--build", "0"],
                     ["2.0.2", "--build", "28", "--unknown"]]:
            with self.subTest(args=args), patch.object(self.release, "run", side_effect=AssertionError("unexpected tool")), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit):
                    self.release.main(args, root=self.root)

    def test_version_mismatch_is_rejected_without_editing_source(self):
        original = (self.root / "Info.plist").read_bytes()
        with self.assertRaisesRegex(ValueError, "Info.plist"):
            self.release.validate_inputs(self.root, "2.0.3", 28, self.feed)
        self.assertEqual(original, (self.root / "Info.plist").read_bytes())

    def test_reused_build_is_rejected(self):
        self.plist["CFBundleVersion"] = "27"
        (self.root / "Info.plist").write_bytes(plistlib.dumps(self.plist))
        with self.assertRaisesRegex(ValueError, "newer"):
            self.release.validate_inputs(self.root, "2.0.2", 27, self.feed)

    def test_lower_marketing_version_is_rejected(self):
        self.plist["CFBundleShortVersionString"] = "1.9"
        (self.root / "Info.plist").write_bytes(plistlib.dumps(self.plist))
        with self.assertRaisesRegex(ValueError, "newer"):
            self.release.validate_inputs(self.root, "1.9", 28, self.feed)

    def test_eval_rejects_translation_errors_even_with_zero_register_leaks(self):
        csv = self.root / "eval.csv"
        csv.write_text('source,old_prompt\n' + 'Example,<ERROR: unavailable>\n' * 40)
        with self.assertRaisesRegex(ValueError, "evaluation"):
            self.release.validate_evaluation("shipping prompt: 0/40", csv)

    def test_eval_accepts_complete_results_but_rejects_incomplete_results(self):
        csv = self.root / "eval.csv"
        csv.write_text('source,old_prompt\n' + 'Example,Hallo\n' * 40)
        self.release.validate_evaluation("shipping prompt: 0/40", csv)
        csv.write_text('source,old_prompt\nExample,Hallo\n')
        with self.assertRaises(ValueError):
            self.release.validate_evaluation("shipping prompt: 0/40", csv)

    def test_prepare_failure_preserves_old_artifacts_and_never_certifies_candidate(self):
        saved = self.root / "dist/accepted/keep.dmg"
        saved.parent.mkdir(parents=True)
        saved.write_bytes(b"accepted immutable bytes")
        calls = []
        def fake_run(args, **kwargs):
            calls.append([str(arg) for arg in args])
            if args[:3] == ["git", "rev-parse", "HEAD"]:
                return "source-commit"
            if args[0] == "security":
                return '  1) ' + 'A' * 40 + ' "Developer ID Application: Example (UMSLY366R9)"'
            if args[:3] == ["xcrun", "notarytool", "submit"]:
                return '{"status":"Invalid"}'
            return ""
        args = SimpleNamespace(version="2.0.2", build=28, previous_appcast=str(self.feed),
                               identity=None, dmg_python="python3", no_eval=True, profile="test-only")
        with patch.object(self.release, "run", side_effect=fake_run), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Accepted"):
                self.release.prepare(self.root, args)
        self.assertEqual(saved.read_bytes(), b"accepted immutable bytes")
        candidates = list((self.root / "dist").glob("release-*"))
        self.assertEqual(len(candidates), 1)
        self.assertFalse((candidates[0] / "VERIFIED.json").exists())
        self.assertFalse(any(call[0] == "gh" for call in calls))
        self.assertFalse(any("staple" in call for call in calls))

    def test_notes_use_exact_version_and_escape_markup(self):
        notes = self.release.release_notes(self.root / "CHANGELOG.md", "2.0.2")
        self.assertIn("&lt;meaning&gt; &amp; tone.", notes)
        self.assertNotIn("old", notes)
        with self.assertRaises(ValueError):
            self.release.release_notes(self.root / "CHANGELOG.md", "2.0")

    def test_feed_retains_history_and_matches_payload(self):
        payload = self.root / "EasyWrite-2.0.2.dmg"
        payload.write_bytes(b"synthetic payload")
        signature = base64.b64encode(bytes(64)).decode()
        output = self.root / "appcast.xml"
        self.release.write_feed(self.feed, output, "2.0.2", 28, "26.0", payload, signature, "<pre>Notes</pre>")
        items = ET.parse(output).findall("channel/item")
        self.assertEqual([i.findtext(f"{{{SPARKLE}}}version") for i in items], ["28", "27"])
        enclosure = items[0].find("enclosure")
        self.assertEqual(enclosure.get("length"), str(payload.stat().st_size))
        self.assertEqual(enclosure.get("url"), "https://github.com/onekapisch/easy-write/releases/download/v2.0.2/EasyWrite-2.0.2.dmg")
        self.assertEqual(enclosure.get(f"{{{SPARKLE}}}edSignature"), signature)
        self.assertEqual(items[1].find("enclosure").get("url"), "https://example.com/old.dmg")
        self.assertEqual(items[0].findtext(f"{{{SPARKLE}}}hardwareRequirements"), "arm64")

    def test_invalid_or_entity_feed_is_rejected(self):
        for content in ["not XML", '<!DOCTYPE rss [<!ENTITY x "text">]><rss><channel>&x;</channel></rss>', '<rss><channel /></rss>']:
            self.feed.write_text(content)
            with self.assertRaises(ValueError):
                self.release.read_feed(self.feed)

    def test_notarization_requires_accepted_status(self):
        with patch.object(self.release, "run", return_value='{"status":"Invalid"}'):
            with self.assertRaisesRegex(ValueError, "Accepted"):
                self.release.notarize(self.root / "sample.zip", "profile")

    def test_mounted_verification_detaches_on_failure(self):
        calls = []
        def fake_run(args, **kwargs):
            calls.append(args)
            if args[0] == "codesign":
                raise subprocess.CalledProcessError(1, args)
            return ""
        with patch.object(self.release, "run", side_effect=fake_run):
            with self.assertRaises(subprocess.CalledProcessError):
                self.release.verify_mounted(self.root / "sample.dmg", self.root / "mount", self.plist)
        self.assertEqual(calls[-1][:2], ["hdiutil", "detach"])
        self.assertIn("-readonly", calls[0])

    def test_partial_attachment_detaches_after_timeout(self):
        calls = []
        def fake_run(args, **kwargs):
            calls.append(args)
            if args[1] == "attach":
                raise subprocess.TimeoutExpired(args, 120)
            return ""
        with patch.object(self.release, "run", side_effect=fake_run), patch.object(self.release.os.path, "ismount", return_value=True):
            with self.assertRaises(subprocess.TimeoutExpired):
                self.release.verify_mounted(self.root / "sample.dmg", self.root / "partial", self.plist)
        self.assertEqual(calls[-1][:2], ["hdiutil", "detach"])

    def test_preparation_uses_frozen_history_when_original_feed_changes(self):
        args = SimpleNamespace(version="2.0.2", build=28, previous_appcast=str(self.feed),
                               identity=None, dmg_python="python3", no_eval=True, profile="test-only")
        original_feed = self.feed.read_bytes()
        def fake_run(command, **kwargs):
            command = [str(arg) for arg in command]
            if command[:3] == ["git", "rev-parse", "HEAD"]:
                return "source-commit"
            if command[0] == "security":
                return '  1) ' + 'A' * 40 + ' "Developer ID Application: Example (UMSLY366R9)"'
            if command[:1] == ["bash"]:
                app = Path(kwargs["env"]["EW_APP_PATH"])
                (app / "Contents/MacOS").mkdir(parents=True)
                (app / "Contents/Info.plist").write_bytes(plistlib.dumps(self.plist))
            if command[:3] == ["xcrun", "notarytool", "submit"]:
                self.feed.write_bytes(original_feed.replace(b">27<", b">29<"))
                return '{"status":"Accepted","id":"00000000-0000-0000-0000-000000000001"}'
            if command[0] == "python3" and "dmgbuild.build_dmg" in command[2]:
                Path(command[3]).write_bytes(b"synthetic dmg")
            if command[:2] == ["hdiutil", "attach"]:
                mount = Path(command[command.index("-mountpoint") + 1])
                app = next((self.root / "dist").glob("release-*/Easy Write.app"))
                shutil.copytree(app, mount / "Easy Write.app")
            if command[0] == "lipo":
                return "arm64"
            if command[0].endswith("sign_update") and command[1] == "-p":
                return base64.b64encode(bytes(64)).decode()
            return ""
        with patch.object(self.release, "run", side_effect=fake_run), contextlib.redirect_stdout(io.StringIO()):
            self.release.prepare(self.root, args)
        output = next((self.root / "dist").glob("release-*/appcast.xml"))
        versions = [item.findtext(f"{{{SPARKLE}}}version") for item in ET.parse(output).findall("channel/item")]
        self.assertEqual(versions, ["28", "27"])
        self.assertTrue((output.parent / "VERIFIED.json").exists())

    def test_payload_verifier_accepts_only_the_configured_public_key(self):
        verifier = ROOT / "tools/verify-update.mjs"
        self.assertTrue(verifier.exists())
        script = '''const {generateKeyPairSync,sign}=require('node:crypto');
const fs=require('node:fs'); const {publicKey,privateKey}=generateKeyPairSync('ed25519');
const file=process.argv[1]; fs.writeFileSync(file,'synthetic update');
console.log(JSON.stringify({key:publicKey.export({format:'der',type:'spki'}).subarray(-32).toString('base64'),signature:sign(null,fs.readFileSync(file),privateKey).toString('base64')}));'''
        import json
        payload = self.root / "update.dmg"
        key = json.loads(subprocess.check_output(["node", "-e", script, str(payload)], text=True))
        args = ["node", str(verifier), str(payload), key["key"], key["signature"]]
        self.assertEqual(subprocess.run(args, capture_output=True).returncode, 0)
        payload.write_bytes(b"tampered")
        self.assertNotEqual(subprocess.run(args, capture_output=True).returncode, 0)


if __name__ == "__main__":
    unittest.main()
