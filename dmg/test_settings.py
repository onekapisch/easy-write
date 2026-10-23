"""Installer layout must not mutate an already signed application bundle."""
import pathlib
import runpy
import unittest


class InstallerSettingsTests(unittest.TestCase):
    def test_layout_disables_post_signing_finder_mutations(self):
        path = pathlib.Path(__file__).with_name("settings.py")
        settings = runpy.run_path(str(path), init_globals={
            "defines": {"app": "/tmp/sample/Easy Write.app", "background": "/tmp/background.tiff"}
        }) if path.exists() else {}
        self.assertEqual(settings.get("hide_extensions"), [])
        self.assertEqual(settings.get("hide"), [])
        self.assertEqual(settings.get("files"), ["/tmp/sample/Easy Write.app"])
        self.assertEqual(settings.get("symlinks"), {"Applications": "/Applications"})
        self.assertEqual(settings.get("icon_locations"), {
            "Easy Write.app": (180, 195), "Applications": (480, 195)
        })


if __name__ == "__main__":
    unittest.main()
