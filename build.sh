#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "▶ Building (release)…"
swift build -c release

APP="EasyWrite.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp ".build/release/EasyWrite" "$APP/Contents/MacOS/EasyWrite"
cp "Info.plist" "$APP/Contents/Info.plist"
[ -f AppIcon.icns ] && cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

IDENTITY="Easy Write Self-Signed"
if security find-identity -p codesigning 2>/dev/null | grep -q "$IDENTITY"; then
    echo "▶ Code signing with stable identity: $IDENTITY"
    codesign --force --sign "$IDENTITY" "$APP"
else
    echo "▶ Ad-hoc code signing (run ./setup-signing.sh once for a stable identity)…"
    codesign --force --sign - "$APP"
fi

echo "✅ Built $APP"
echo "   Open it with:  open \"$APP\""
