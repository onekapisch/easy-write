#!/bin/bash
# Builds "Easy Write.app" in this folder.
#
# Signing, in order of preference:
#   1. $EW_SIGN_IDENTITY, if set
#   2. a "Developer ID Application" identity in your keychain (hardened runtime; this is what
#      release.sh notarizes)
#   3. the "Easy Write Self-Signed" identity from ./setup-signing.sh
#   4. ad-hoc
# Any stable identity (1–3) keeps the Accessibility permission across rebuilds.
set -euo pipefail
cd "$(dirname "$0")"

APP="Easy Write.app"
TIMESTAMP="${EW_TIMESTAMP:---timestamp=none}"     # release.sh passes --timestamp

echo "▶ Building (release)…"
swift build -c release

rm -rf "$APP" "EasyWrite.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"
cp ".build/release/EasyWrite" "$APP/Contents/MacOS/EasyWrite"
cp "Info.plist" "$APP/Contents/Info.plist"
[ -f AppIcon.icns ] && cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp Resources/Studio/*.png "$APP/Contents/Resources/"     # Studio page tiles (make-studio-icons.py output)

# Sparkle (updates). The app isn't sandboxed, so Sparkle's XPC services aren't needed.
SPARKLE=".build/release/Sparkle.framework"          # .build/release links to the real product folder
if [ -d "$SPARKLE" ]; then
    cp -R "$SPARKLE" "$APP/Contents/Frameworks/"
    rm -rf "$APP/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices"
fi
[ -z "$(ls -A "$APP/Contents/Frameworks")" ] && rmdir "$APP/Contents/Frameworks"

IDENTITY="${EW_SIGN_IDENTITY:-}"
RUNTIME=()
if [ -z "$IDENTITY" ]; then
    DEVID=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application" | head -1 | awk '{print $2}' || true)
    if [ -n "$DEVID" ]; then
        IDENTITY="$DEVID"
    elif security find-identity -p codesigning 2>/dev/null | grep -q "Easy Write Self-Signed"; then
        IDENTITY="Easy Write Self-Signed"
    else
        IDENTITY="-"
    fi
fi
if [ "$IDENTITY" != "-" ] && security find-identity -v -p codesigning 2>/dev/null | grep "$IDENTITY" | grep -q "Developer ID"; then
    RUNTIME=(--options runtime)
fi

sign() { codesign --force "${RUNTIME[@]+"${RUNTIME[@]}"}" $TIMESTAMP --sign "$IDENTITY" "$@"; }

if [ -d "$APP/Contents/Frameworks/Sparkle.framework" ]; then
    FW="$APP/Contents/Frameworks/Sparkle.framework/Versions/B"
    sign "$FW/Autoupdate"
    sign "$FW/Updater.app"
    sign "$APP/Contents/Frameworks/Sparkle.framework"
fi
echo "▶ Code signing with: $( [ "$IDENTITY" = "-" ] && echo ad-hoc || security find-identity -v -p codesigning | grep "$IDENTITY" | sed 's/.*"\(.*\)"/\1/' | head -1 )"
sign "$APP"

echo "✅ Built $APP"
echo "   Open it with:  open \"$APP\""
