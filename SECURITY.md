# Security & Privacy

Easy Write is designed to be private by default. This document explains exactly what it does, what
permissions it needs and why, and how to report a security issue.

## Data flow (there isn't much)

- **Translation runs entirely on-device** using Apple's Foundation Models framework. There is **no
  network code** in this app — nothing is uploaded, logged, or sent to any server.
- **No accounts, no API keys, no telemetry, no analytics.**
- The text you translate is read from your current selection, sent to the on-device model, and the
  result is pasted back. It is held in memory only for the duration of the translation.
- Your **clipboard is snapshotted before** a swap and **restored after**, so Easy Write doesn't
  clobber what you had copied.

## Permissions

| Permission | Why it's needed |
|---|---|
| **Accessibility** | To read your current selection (synthesised ⌘C) and paste the translation back (synthesised ⌘V). This is the only way to work across *all* apps. |

That's it. No network, no full-disk access, no microphone/camera, no contacts.

## Why it's not sandboxed / not on the Mac App Store

Replacing selected text in arbitrary apps requires posting synthetic keystrokes, which the App Store
sandbox forbids. Easy Write is therefore distributed as build-from-source (and possibly a notarized
download later). Because you build it yourself, you can audit every line first — it's ~600 lines of Swift.

## Reporting a vulnerability

If you find a security issue, please **do not open a public issue**. Instead, open a
[GitHub security advisory](../../security/advisories/new) or email the maintainer. You'll get a
response as quickly as possible, and credit if you'd like it.
