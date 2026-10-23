"""Non-destructive release preparation. Publication is a separate owner action."""
import argparse
import base64
import csv
from datetime import datetime, timezone
from email.utils import format_datetime
import hashlib
import html
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

SPARKLE = "http://www.andymatuschak.org/xml-namespaces/sparkle"
SITE = "https://www.onekapisch.com/products/easy-write/"
REPO = "https://github.com/onekapisch/easy-write"
ET.register_namespace("sparkle", SPARKLE)


def run(args, *, timeout=120, **kwargs):
    result = subprocess.run([str(a) for a in args], check=True, text=True,
                            capture_output=True, timeout=timeout, **kwargs)
    return result.stdout.strip()


def read_feed(path):
    data = path if isinstance(path, bytes) else Path(path).read_bytes()
    if len(data) > 2_000_000 or b"<!DOCTYPE" in data.upper() or b"<!ENTITY" in data.upper():
        raise ValueError("Previous appcast is oversized or contains a forbidden XML declaration")
    try:
        tree = ET.fromstring(data)
    except ET.ParseError as error:
        raise ValueError("Previous appcast is not valid XML") from error
    if tree.tag != "rss" or not tree.findall("channel/item"):
        raise ValueError("Previous appcast must have an RSS channel and release history")
    return tree


def release_notes(path, version):
    content = Path(path).read_text()
    match = re.search(r"^## \[" + re.escape(version) + r"\][^\n]*\n(.*?)(?=^## |\Z)", content, re.M | re.S)
    if not match or not match[1].strip():
        raise ValueError(f"CHANGELOG.md needs a nonempty exact [{version}] section")
    return "<pre>" + html.escape(match[1].strip()) + "</pre>"


def validate_inputs(root, version, build, previous):
    with (root / "Info.plist").open("rb") as stream:
        info = plistlib.load(stream)
    if info.get("CFBundleShortVersionString") != version or info.get("CFBundleVersion") != str(build):
        raise ValueError("Commit the requested version and explicit build number in Info.plist first")
    if info.get("CFBundleIdentifier") != "com.onekapisch.easywrite" or info.get("SUFeedURL") != SITE + "appcast.xml":
        raise ValueError("Unexpected bundle identifier or feed URL in Info.plist")
    if len(base64.b64decode(info.get("SUPublicEDKey", ""), validate=True)) != 32:
        raise ValueError("Info.plist must contain the existing 32-byte Sparkle public key")
    items = read_feed(previous).findall("channel/item")
    versions = [item.findtext(f"{{{SPARKLE}}}version", "") for item in items]
    if not all(v.isdigit() for v in versions) or build <= max(int(v) for v in versions):
        raise ValueError("Explicit build number must be newer than every previous appcast item")
    if any(item.findtext(f"{{{SPARKLE}}}shortVersionString") == version for item in items):
        raise ValueError("This version is already in the previous appcast")
    requested = tuple(int(v) for v in (version.split(".") + ["0"])[:3])
    for item in items:
        older = item.findtext(f"{{{SPARKLE}}}shortVersionString", "")
        if not re.fullmatch(r"\d+\.\d+(?:\.\d+)?", older):
            raise ValueError("Previous appcast has an unsupported marketing version")
        if requested <= tuple(int(v) for v in (older.split(".") + ["0"])[:3]):
            raise ValueError("Marketing version must be newer than every previous appcast item")
    release_notes(root / "CHANGELOG.md", version)
    return info


def write_feed(previous, output, version, build, minimum_os, payload, signature, notes):
    if len(base64.b64decode(signature, validate=True)) != 64:
        raise ValueError("Payload signature must be an Ed25519 signature")
    tree = read_feed(previous)
    channel = tree.find("channel")
    item = ET.Element("item")
    fields = {"title": f"Easy Write {version}", "link": SITE,
              "pubDate": format_datetime(datetime.now(timezone.utc), usegmt=True),
              f"{{{SPARKLE}}}version": str(build),
              f"{{{SPARKLE}}}shortVersionString": version,
              f"{{{SPARKLE}}}minimumSystemVersion": minimum_os,
              f"{{{SPARKLE}}}hardwareRequirements": "arm64", "description": notes}
    for name, value in fields.items():
        ET.SubElement(item, name).text = value
    ET.SubElement(item, "enclosure", {"url": f"{REPO}/releases/download/v{version}/{payload.name}",
        "length": str(payload.stat().st_size), "type": "application/octet-stream",
        f"{{{SPARKLE}}}edSignature": signature})
    channel.insert(list(channel).index(channel.find("item")), item)
    ET.ElementTree(tree).write(output, encoding="utf-8", xml_declaration=True)


def notarize(path, profile):
    status = json.loads(run(["xcrun", "notarytool", "submit", path, "--keychain-profile", profile,
                             "--wait", "--output-format", "json"], timeout=1800))
    if status.get("status") != "Accepted":
        raise ValueError(f"Notarization was not Accepted: {status.get('status', 'missing status')}")
    return status


def validate_evaluation(summary, path):
    match = re.search(r"shipping prompt:\s*(\d+)/40", summary)
    with path.open(newline="") as stream:
        rows = list(csv.DictReader(stream))
    if (not match or int(match[1]) > 2 or len(rows) != 40
            or any(not row.get("old_prompt", "").strip() or "<ERROR:" in row["old_prompt"] for row in rows)):
        raise ValueError("Translation evaluation failed, incomplete, or contains model errors")


def verify_app(app, expected):
    run(["codesign", "--verify", "--deep", "--strict", app])
    run(["xcrun", "stapler", "validate", app])
    run(["spctl", "--assess", "--type", "execute", app])
    with (app / "Contents/Info.plist").open("rb") as stream:
        actual = plistlib.load(stream)
    for key in ["CFBundleIdentifier", "CFBundleShortVersionString", "CFBundleVersion", "SUPublicEDKey", "SUFeedURL"]:
        if actual.get(key) != expected.get(key):
            raise ValueError(f"Packaged app changed {key}")
    binary = app / "Contents/MacOS/EasyWrite"
    if run(["lipo", "-archs", binary]) != "arm64":
        raise ValueError("Expected the Apple Silicon release architecture")
    run([binary, "--selftest"], timeout=180)


def verify_mounted(dmg, mount, expected):
    mount.mkdir()
    attached = False
    try:
        run(["hdiutil", "attach", "-readonly", "-nobrowse", "-noautoopen", "-mountpoint", mount, dmg])
        attached = True
        verify_app(mount / "Easy Write.app", expected)
    finally:
        if attached or os.path.ismount(mount):
            run(["hdiutil", "detach", mount])


def prepare(root, args):
    previous_bytes = Path(args.previous_appcast).read_bytes()
    info = validate_inputs(root, args.version, args.build, previous_bytes)
    if run(["git", "status", "--porcelain"], cwd=root):
        raise ValueError("Commit or preserve uncommitted changes before release preparation")
    tag = "v" + args.version
    if run(["git", "tag", "--list", tag], cwd=root) or run(["git", "ls-remote", "--tags", "origin", "refs/tags/" + tag], cwd=root):
        raise ValueError("An existing release tag must never be replaced")
    commit = run(["git", "rev-parse", "HEAD"], cwd=root)
    identities = run(["security", "find-identity", "-v", "-p", "codesigning"])
    identities = re.findall(r'\b([A-Fa-f0-9]{40}) "Developer ID Application:[^\n]+"', identities)
    if args.identity:
        identities = [value for value in identities if value == args.identity]
    if len(identities) != 1:
        raise ValueError("Select one valid Developer ID Application certificate with --identity SHA1")
    identity = identities[0]
    run([args.dmg_python, "-c", "import importlib.metadata as m; assert all(m.version(n)==v for n,v in [('dmgbuild','1.6.7'),('ds_store','1.3.3'),('mac_alias','2.2.3')])"])
    for name in ["node", "swift", "codesign", "xcrun", "hdiutil", "spctl"]:
        if not shutil.which(name):
            raise ValueError(f"Missing required tool: {name}")
    dist = root / "dist"
    if dist.is_symlink():
        raise ValueError("dist must not be a symlink")
    dist.mkdir(exist_ok=True)
    candidate = Path(tempfile.mkdtemp(prefix=f"release-{args.version}-b{args.build}.", dir=dist))
    print(f"Candidate: {candidate}", flush=True)
    try:
        previous = candidate / "previous-appcast.xml"
        previous.write_bytes(previous_bytes)
        app = candidate / "Easy Write.app"
        env = dict(os.environ, EW_APP_PATH=str(app), EW_SIGN_IDENTITY=identity,
                   EW_TIMESTAMP="--timestamp", EW_ENABLE_UPDATES="1")
        print("Building and signing the isolated app", flush=True)
        run(["bash", root / "build.sh"], cwd=root, env=env, timeout=900)
        signer = root / ".build/artifacts/sparkle/Sparkle/bin/sign_update"
        run([signer, "--verify", previous])
        if previous.read_bytes() != previous_bytes:
            raise ValueError("Previous feed snapshot changed during signature verification")
        binary = app / "Contents/MacOS/EasyWrite"
        run([binary, "--selftest"], timeout=180)
        run([binary, "--smoketest"], timeout=300)
        if not args.no_eval:
            evaluation_dir = candidate / "evaluation"
            evaluation_dir.mkdir()
            evaluation = run([binary, "--eval"], timeout=900,
                             env=dict(os.environ, TMPDIR=str(evaluation_dir) + "/"))
            validate_evaluation(evaluation, evaluation_dir / "easywrite-eval-results.csv")
        print("Submitting app to Apple", flush=True)
        archive = candidate / "app.zip"
        run(["ditto", "-c", "-k", "--keepParent", app, archive])
        app_status = notarize(archive, args.profile)
        run(["xcrun", "stapler", "staple", app])
        verify_app(app, info)
        dmg = candidate / f"EasyWrite-{args.version}.dmg"
        print("Building the safe dmgbuild layout", flush=True)
        run([args.dmg_python, "-c", "import dmgbuild,sys; dmgbuild.build_dmg(sys.argv[1], 'Easy Write', settings_file=sys.argv[2], defines={'app':sys.argv[3], 'background':sys.argv[4]})",
             dmg, root / "dmg/settings.py", app, root / "dmg/background.tiff"], timeout=600)
        verify_mounted(dmg, candidate / "mount-before", info)
        run(["codesign", "--force", "--timestamp", "--sign", identity, dmg])
        print("Submitting DMG to Apple", flush=True)
        dmg_status = notarize(dmg, args.profile)
        run(["xcrun", "stapler", "staple", dmg])
        run(["xcrun", "stapler", "validate", dmg])
        run(["codesign", "--verify", "--strict", dmg])
        run(["spctl", "-a", "-t", "open", "--context", "context:primary-signature", dmg])
        run(["hdiutil", "verify", dmg])
        verify_mounted(dmg, candidate / "mount-final", info)
        signature = run([signer, "-p", dmg])
        run([signer, "--verify", dmg, signature])
        run(["node", root / "tools/verify-update.mjs", dmg, info["SUPublicEDKey"], signature])
        notes = release_notes(root / "CHANGELOG.md", args.version)
        (candidate / "release-notes.html").write_text(notes)
        feed = candidate / "appcast.xml"
        write_feed(previous_bytes, feed, args.version, args.build, info["LSMinimumSystemVersion"], dmg, signature, notes)
        run([signer, feed])
        run([signer, "--verify", feed])
        shutil.copyfile(dmg, candidate / "EasyWrite.dmg")
        if run(["git", "status", "--porcelain"], cwd=root) or run(["git", "rev-parse", "HEAD"], cwd=root) != commit:
            raise ValueError("Source tree changed during preparation; candidate must not be published")
        manifest = {"status": "prepared-not-published", "version": args.version, "build": args.build,
                    "commit": commit, "evalSkipped": args.no_eval, "appNotarization": app_status,
                    "dmgNotarization": dmg_status, "payloadSignature": signature,
                    "sha256": {path.name: hashlib.sha256(path.read_bytes()).hexdigest()
                               for path in [dmg, candidate / "EasyWrite.dmg", feed]}}
        (candidate / "VERIFIED.json").write_text(json.dumps(manifest, indent=2) + "\n")
        print(f"Verified candidate: {candidate}\nNo Git or GitHub state was changed. Review docs/release-process.md before publication.")
    except BaseException:
        print(f"Preparation failed. Retained candidate for inspection: {candidate}. Do not publish it.", file=sys.stderr)
        raise


def main(argv=None, root=None):
    parser = argparse.ArgumentParser(description="Read-only release plan by default. --prepare explicitly submits to Apple, never publishes.")
    parser.add_argument("version")
    parser.add_argument("--build", type=int, required=True)
    parser.add_argument("--prepare", action="store_true")
    parser.add_argument("--previous-appcast")
    parser.add_argument("--dmg-python", default="python3")
    parser.add_argument("--identity", help="Developer ID Application certificate SHA1")
    parser.add_argument("--profile", default=os.environ.get("EW_NOTARY_PROFILE", "easywrite-notary"))
    parser.add_argument("--no-eval", action="store_true", help="Explicitly skip the 40-sentence eval, never the smoke/self-tests")
    args = parser.parse_args(argv)
    if not re.fullmatch(r"\d+\.\d+(?:\.\d+)?", args.version) or args.build < 1:
        parser.error("Use a numeric version and a positive explicit build number")
    root = root or Path(__file__).resolve().parents[1]
    if not args.prepare:
        print(f"PLAN ONLY: Easy Write {args.version}, build {args.build}. No release files changed; no signing, credential or network calls.\n"
              "Commit matching Info.plist and CHANGELOG first. Explicit --prepare requires --previous-appcast,\n"
              "a pinned dmgbuild Python environment and Keychain credentials. It submits to Apple, not GitHub.")
        return 0
    if not args.previous_appcast:
        parser.error("--prepare requires --previous-appcast with the latest signed production feed")
    prepare(root, args)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"Release preparation stopped: {error}", file=sys.stderr)
        sys.exit(1)
