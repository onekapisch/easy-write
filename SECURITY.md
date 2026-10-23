# Security & Privacy

Easy Write is designed to be private by default. This document explains exactly what it does, what
permissions it needs and why, and how to report a security issue.

## Data flow

- **Translation and actions run entirely on-device** using Apple's Foundation Models framework.
  Your text is never uploaded, logged, or sent to any server.
- **No accounts, no API keys, no telemetry, no analytics.**
- The text you select is read from your current selection, sent to the on-device model, and the
  result is pasted back or shown in a popup.
- Your **clipboard is snapshotted before** a swap and **restored after**. The temporary paste is
  marked as transient, so clipboard managers that follow the nspasteboard.org convention don't
  record it.

## Network access

Easy Write goes online for one thing only: **checking for updates**, through
[Sparkle](https://sparkle-project.org), and only if you allow it (Sparkle asks on the second launch;
you can change it in Settings → Updates).

- It requests `https://www.onekapisch.com/products/easy-write/appcast.xml`, and downloads the update
  from GitHub Releases when you choose to install one.
- The request carries the app's version in its user agent. System profiling is turned off
  (`SUEnableSystemProfiling` is false), so nothing about your Mac is sent.
- Updates are verified with an EdDSA signature and Apple's notarization before they're installed.
- **Nothing you write is ever part of an update check.**

Builds made from source without a feed URL and signing key don't check for updates at all.

## What's stored on your Mac

| What | Where | Your control |
|---|---|---|
| Settings, glossary, actions, per-app memory, usage counts | `~/Library/Preferences/com.onekapisch.easywrite.plist` | Settings |
| History of results (up to 100, 1–30 days) | `~/Library/Application Support/Easy Write/history.json` | Settings → History & Privacy: off switch, retention, clear, excluded apps |

Password managers and Keychain Access are excluded from history by default.

## Permissions

| Permission | Why it's needed |
|---|---|
| **Accessibility** | To read your current selection (synthesised ⌘C) and paste the result back (synthesised ⌘V). This is the only way to work across *all* apps. |

No full-disk access, microphone, camera, contacts, location or screen recording.

## Shared actions

Actions can be shared as links. A shared action is someone else's instruction, so Easy Write always
shows its full text before adding it, adds it without a shortcut, and starts it in popup mode so it
can't replace any text until you switch it over yourself. Links with control characters or
bidirectional-override characters are rejected, so what you're shown is exactly what runs.

## Why it's not on the Mac App Store

Replacing selected text in arbitrary apps requires posting synthetic keystrokes, which the App Store
sandbox forbids. Easy Write is distributed as a notarized download from onekapisch.com and as source
on GitHub.

## Reporting a vulnerability

If you find a security issue, please **do not open a public issue**. Open a
[GitHub security advisory](../../security/advisories/new) or email support@onekapisch.com. You'll get
a response as quickly as possible, and credit if you'd like it.
