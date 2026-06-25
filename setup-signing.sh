#!/bin/bash
# One-time: create a stable self-signed code-signing identity for Easy Write,
# stored in a dedicated keychain with a known password (fully non-interactive,
# so codesign never has to prompt). This gives the app a stable identity so the
# macOS Accessibility grant persists across rebuilds.
set -euo pipefail

KC="$HOME/Library/Keychains/easywrite-signing.keychain-db"
PW="easywrite"
IDENTITY="Easy Write Self-Signed"

OPENSSL="/usr/bin/openssl"
BREW_SSL="$(brew --prefix 2>/dev/null)/bin/openssl"
[ -x "$BREW_SSL" ] && OPENSSL="$BREW_SSL"
echo "▶ openssl: $OPENSSL"

WORK="$(mktemp -d)"
cat > "$WORK/cfg.cnf" <<'CNF'
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
CN = Easy Write Self-Signed
[v3]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
CNF

echo "▶ Generating self-signed code-signing certificate…"
"$OPENSSL" req -x509 -newkey rsa:2048 -nodes \
  -keyout "$WORK/key.pem" -out "$WORK/cert.pem" \
  -days 3650 -config "$WORK/cfg.cnf" -extensions v3 >/dev/null 2>&1

# -legacy + SHA1 MAC so macOS `security import` can read the PKCS12
"$OPENSSL" pkcs12 -export -legacy -macalg SHA1 \
  -inkey "$WORK/key.pem" -in "$WORK/cert.pem" \
  -out "$WORK/ew.p12" -passout pass:"$PW" -name "$IDENTITY" >/dev/null 2>&1

echo "▶ Creating dedicated signing keychain…"
security delete-keychain "$KC" 2>/dev/null || true
security create-keychain -p "$PW" "$KC"
security set-keychain-settings "$KC"            # no auto-lock
security unlock-keychain -p "$PW" "$KC"

# Add to the user keychain search list (keep the existing ones)
EXISTING=$(security list-keychains -d user | sed 's/[\" ]//g')
# shellcheck disable=SC2086
security list-keychains -d user -s "$KC" $EXISTING

echo "▶ Importing identity and authorising codesign…"
security import "$WORK/ew.p12" -k "$KC" -P "$PW" -A -T /usr/bin/codesign >/dev/null
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$PW" "$KC" >/dev/null 2>&1

rm -rf "$WORK"
echo "✅ Done. Code-signing identities now available:"
security find-identity -p codesigning | grep -i "easy write" || \
  security find-identity -p codesigning | tail -5
