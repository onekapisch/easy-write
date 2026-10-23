#!/bin/bash
# Builds a notarized, auto-updatable release of Easy Write.
#
#   ./release.sh 2.0            full release (eval gate, notarize, DMG, appcast, draft GitHub release)
#   ./release.sh 2.0 --no-eval  skip the translation eval gate
#
# One-time setup (stores your notarization credentials in the keychain, you type the password):
#   xcrun notarytool store-credentials easywrite-notary --apple-id YOU@EXAMPLE.COM --team-id UMSLY366R9
#
# Output in ./dist:  EasyWrite-<version>.dmg, EasyWrite.dmg (stable name), appcast.xml, release-notes.html
# The GitHub release is created as a DRAFT. Nothing is public until you publish it and upload
# appcast.xml to https://www.onekapisch.com/products/easy-write/appcast.xml.
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:?Usage: ./release.sh <version> [--no-eval]}"
RUN_EVAL=1; [ "${2:-}" = "--no-eval" ] && RUN_EVAL=0
PROFILE="${EW_NOTARY_PROFILE:-easywrite-notary}"
APP="Easy Write.app"
DIST="dist"
REPO="onekapisch/easy-write"
SPARKLE_BIN=".build/artifacts/sparkle/Sparkle/bin"

step() { printf "\n▶ %s\n" "$1"; }
fail() { printf "✖ %s\n" "$1" >&2; exit 1; }

# ── Preflight ────────────────────────────────────────────────────────────────
step "Preflight"
[ -z "$(git status --porcelain)" ] || fail "Working tree has uncommitted changes. Commit or stash them first."
git rev-parse "v$VERSION" >/dev/null 2>&1 && fail "Tag v$VERSION already exists."
security find-identity -v -p codesigning | grep -q "Developer ID Application" || fail "No Developer ID Application certificate in the keychain."
xcrun notarytool history --keychain-profile "$PROFILE" >/dev/null 2>&1 \
  || fail "No notarization profile '$PROFILE'. Run the one-time setup at the top of this script."
command -v gh >/dev/null || fail "GitHub CLI (gh) is not installed."
grep -q "## \[$VERSION\]" CHANGELOG.md || fail "CHANGELOG.md has no '## [$VERSION]' section."

# ── Version ──────────────────────────────────────────────────────────────────
BUILD=$(git rev-list --count HEAD)
step "Version $VERSION (build $BUILD)"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" Info.plist
trap 'git checkout -- Info.plist 2>/dev/null || true' EXIT     # keep the tree clean if anything fails

# ── Self-test and eval gates ─────────────────────────────────────────────────
step "Self-test"
swift build -c release >/dev/null
./.build/release/EasyWrite --selftest | tail -1
./.build/release/EasyWrite --selftest >/dev/null || fail "Self-test failed. Run ./.build/release/EasyWrite --selftest to see which check."

if [ "$RUN_EVAL" = 1 ]; then
    step "Translation eval (shipping prompt must leak formal register in at most 2 of 40)"
    OUT=$(./.build/release/EasyWrite --eval) || fail "Eval could not run. Is Apple Intelligence ready on this Mac?"
    echo "$OUT" | tail -12
    LEAKS=$(echo "$OUT" | sed -n 's/.*shipping prompt: *\([0-9]*\)\/.*/\1/p')
    [ -n "$LEAKS" ] || fail "Couldn't read the eval result."
    [ "$LEAKS" -le 2 ] || fail "Eval gate failed: $LEAKS/40 register leaks."
fi

# ── Build, sign, notarize the app ────────────────────────────────────────────
step "Build and sign"
EW_TIMESTAMP=--timestamp ./build.sh
codesign --verify --deep --strict "$APP"

rm -rf "$DIST"; mkdir -p "$DIST"
step "Notarize app"
ditto -c -k --keepParent "$APP" "$DIST/app.zip"
xcrun notarytool submit "$DIST/app.zip" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$APP"
rm "$DIST/app.zip"

# ── DMG ──────────────────────────────────────────────────────────────────────
step "Build DMG"
DMG="$DIST/EasyWrite-$VERSION.dmg"
STAGE=$(mktemp -d)
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
mkdir "$STAGE/.background"
cp dmg/background.tiff "$STAGE/.background/background.tiff"
hdiutil create -volname "Easy Write" -srcfolder "$STAGE" -fs HFS+ -format UDRW -ov "$DIST/rw.dmg" >/dev/null
MOUNT=$(hdiutil attach -readwrite -noverify -noautoopen "$DIST/rw.dmg" | awk -F'\t' '/\/Volumes\//{print $NF}')
# Window layout. Finder may ask once for permission to be controlled by Terminal; without it
# the DMG still works, just without the background.
osascript <<OSA || echo "  (Finder layout skipped)"
tell application "Finder"
  tell disk "Easy Write"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {200, 120, 860, 520}
    set opts to the icon view options of container window
    set arrangement of opts to not arranged
    set icon size of opts to 112
    set background picture of opts to file ".background:background.tiff"
    set position of item "$APP" of container window to {180, 195}
    set position of item "Applications" of container window to {480, 195}
    update without registering applications
    delay 1
    close
  end tell
end tell
OSA
sync
hdiutil detach "$MOUNT" -quiet
hdiutil convert "$DIST/rw.dmg" -format UDZO -imagekey zlib-level=9 -o "$DMG" >/dev/null
rm -rf "$DIST/rw.dmg" "$STAGE"

step "Sign and notarize DMG"
DEVID=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | awk '{print $2}')
codesign --force --timestamp --sign "$DEVID" "$DMG"
xcrun notarytool submit "$DMG" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$DMG"
spctl -a -t open --context context:primary-signature -v "$DMG"
cp "$DMG" "$DIST/EasyWrite.dmg"

# ── Sparkle appcast ──────────────────────────────────────────────────────────
step "Appcast"
# Release notes: this version's CHANGELOG section as simple HTML.
awk -v v="## \\[$VERSION\\]" 'index($0, "## [")==1 { if (found) exit; if ($0 ~ v) { found=1; next } } found' CHANGELOG.md \
  | sed -e 's/^### \(.*\)/<h3>\1<\/h3>/' -e 's/^- \(.*\)/<li>\1<\/li>/' -e 's/\*\*\([^*]*\)\*\*/<b>\1<\/b>/g' \
  > "$DIST/EasyWrite-$VERSION.html"
APPCAST_DIR=$(mktemp -d)
cp "$DMG" "$DIST/EasyWrite-$VERSION.html" "$APPCAST_DIR/"
"$SPARKLE_BIN/generate_appcast" "$APPCAST_DIR" \
  --download-url-prefix "https://github.com/$REPO/releases/download/v$VERSION/" \
  --link "https://www.onekapisch.com/products/easy-write/" \
  --embed-release-notes
cp "$APPCAST_DIR/appcast.xml" "$DIST/appcast.xml"
cp "$DIST/EasyWrite-$VERSION.html" "$DIST/release-notes.html"
rm -rf "$APPCAST_DIR"

# ── Commit version, tag, draft release ───────────────────────────────────────
step "Tag and draft GitHub release"
trap - EXIT
git add Info.plist
git commit -q -m "Release $VERSION"
git tag "v$VERSION"
NOTES=$(awk -v v="## \\[$VERSION\\]" 'index($0, "## [")==1 { if (found) exit; if ($0 ~ v) { found=1; next } } found' CHANGELOG.md)
gh release create "v$VERSION" "$DMG" "$DIST/EasyWrite.dmg" \
  --repo "$REPO" --draft --title "Easy Write $VERSION" --notes "$NOTES"

cat <<DONE

✅ Easy Write $VERSION is built, notarized and drafted.

Next, when you're ready to go public:
  1. git push origin HEAD --tags
  2. Publish the draft:  gh release edit v$VERSION --repo $REPO --draft=false
  3. Upload dist/appcast.xml to https://www.onekapisch.com/products/easy-write/appcast.xml
     (existing installs find the update from there)
  4. The site's download button can always point at:
     https://github.com/$REPO/releases/latest/download/EasyWrite.dmg
DONE
