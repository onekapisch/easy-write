# Security & Privacy

Easy Write is designed to be private by default. This document explains exactly what it does, what
permissions it needs and why, and how to report a security issue.

## Data flow

- **Translation and actions run entirely on-device** using Apple's Foundation Models framework.
  Your text is never uploaded or included in diagnostics. Only explicitly enabled history saves it locally.
- **No accounts, no API keys, no telemetry, no analytics.**
- The text you select is read from your current selection, sent to the on-device model, and the
  result is pasted back or shown in a popup.
- Selection capture reads Accessibility directly and does not modify the clipboard. Temporary
  output pastes are restored only while owned. Output pastes are marked transient for compatible
  clipboard managers. Unsupported selection APIs fail without copying unrelated clipboard text.
- Automatic replacement verifies the source process, AX window, field, selection range and text.
  Changed or unverifiable targets show a review card instead. The HUD reports "Paste sent",
  since synthetic keystrokes have no delivery acknowledgement.

## Network access

Easy Write's background networking is limited to **checking for updates**, through
[Sparkle](https://sparkle-project.org), and only if you allow it (Sparkle asks on the second launch;
you can change it in Settings → Updates).

- It requests `https://www.onekapisch.com/products/easy-write/appcast.xml`, and downloads the update
  from GitHub Releases when you choose to install one.
- The request carries the app's version in its user agent. Optional system profiling is turned
  off (`SUEnableSystemProfiling` is false). The server can still observe ordinary HTTP metadata,
  including the connection's IP address.
- Updates are verified with an EdDSA signature and Apple's notarization before they're installed.
- **Nothing you write is ever part of an update check.**

Source builds disable update configuration by default. Release builds use `EW_ENABLE_UPDATES=1`
and still request user consent for checks. Clicking a Studio, support, source or shared-action link
opens an external site in the browser. Studio links include product/campaign attribution parameters,
not selected text. The destination can receive normal browser network metadata.

Generated candidates in `dist/` are ignored by Git. Signing alone does not make a
candidate safe to distribute: Apple notarization, stapling, Gatekeeper acceptance
and a matching signed update payload remain release gates. The current local
candidate is explicitly unnotarized. Credentials and private keys stay in Keychain;
local preparation does not export them.

## What's stored on your Mac

| What | Where | Your control |
|---|---|---|
| Settings, glossary, actions, per-app memory, usage counts | `~/Library/Preferences/com.onekapisch.easywrite.plist` | Settings |
| Opt-in originals and results (up to 100, 1–30 days) | `~/Library/Application Support/Easy Write/history.json` | Off by default; disable to delete, or clear manually; excluded apps |

Password managers and Keychain Access are excluded from history by default.
Unknown source apps are excluded too. History is unencrypted JSON with owner-only permissions
(folder 0700, file 0600), not a defence against malware running as the same user. Expired entries
are pruned every minute while running, after wake, on retention changes and on launch. Cleanup
cannot run while the app is closed. Disabling history deletes the file, not backups or APFS
snapshots. Upgrading an early 2.0 preview requires fresh explicit consent and clears implicit history.

## Permissions

| Permission | Why it's needed |
|---|---|
| **Accessibility** | To read AX selected text and send a target-validated paste. Apps must expose their selection; unverifiable replacement falls back to review. |

Normal app use needs no full-disk access, microphone, camera, contacts, location or screen recording.

The explicit developer command `--launch-assets <directory>` is an exception: it uses existing
Screen Recording permission to record only its own synthetic demo window with ScreenCaptureKit.
It refuses to record if permission is unavailable and never requests it. No desktop display,
other app window, microphone, clipboard or real history is captured. The normal app delegate and
hotkeys do not start in this mode. Its throwaway settings domain is removed after export.

## Shared actions

Actions can be shared as links. A shared action is someone else's instruction, so Easy Write always
shows its full text before adding it, adds it without a shortcut, and starts it in popup mode so it
can't replace any text until you switch it over yourself. Links with control characters or
bidirectional-override characters are rejected, so what you're shown is exactly what runs.

## Why it's not on the Mac App Store

Replacing selected text in arbitrary apps requires posting synthetic keystrokes, which the App Store
sandbox forbids. Source is on GitHub; a notarized 2.0 download is being prepared, not published yet.

## Reporting a vulnerability

If you find a security issue, please **do not open a public issue**. Open a
[GitHub security advisory](../../security/advisories/new) or email support@onekapisch.com. You'll get
a response as quickly as possible, and credit if you'd like it.
