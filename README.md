<div align="center">

<img src="docs/icon.png" width="120" height="120" alt="Easy Write app icon">

# Easy Write on Mac

### Translate & rewrite text anywhere on your Mac — formal or informal — 100% on-device.

Select text in any app, press a shortcut, and it's **replaced in place** with the translation, in the
tone you choose (German *Sie* vs *du*, French *vous* vs *tu*, …). Or run your own actions: fix the
grammar, make it shorter, reply politely. Powered entirely by Apple's **on-device** model (Apple
Intelligence). **No accounts. No API keys. No cloud.** Your text never leaves your Mac.

See [launch preparation status](docs/launch-handoff.md) for the website preview,
local candidate checks and remaining release gates. The local candidate is not notarized.

**2.0 preview branch.** Build from source below. Signed downloads and automatic updates are
not published yet. The latest public release is 1.1.1.

![macOS 26+](https://img.shields.io/badge/macOS-26%2B-black?logo=apple&logoColor=white)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-required-black?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![100% on-device](https://img.shields.io/badge/AI-100%25%20on--device-2ea44f)
![No account](https://img.shields.io/badge/account-not%20required-2ea44f)
![License: MIT](https://img.shields.io/badge/License-MIT-blue)
![PRs welcome](https://img.shields.io/badge/PRs-welcome-ff69b4)

**[🧠 How it works](HOW_IT_WORKS.md) · [⬇️ Install](#️-install) · [🆚 How it compares](#-how-it-compares) · [🐛 Report a bug / request a feature](../../issues)**

![Easy Write — type in any app, press one shortcut, and the text is replaced in place](docs/demo.gif)

</div>

---

## Why Easy Write?

If you write emails, messages, or docs in a language that isn't your first, you're stuck in a loop:
copy → open a translator website → paste → translate → copy → paste back. And the result often gets
the *words* right but the **tone** wrong — which in German (and French, Spanish, Italian…) is the
difference between polite and rude.

- 🌐 **Cloud translators** mean sign-ups, monthly limits, and your private text leaving your machine.
- 🧩 **Local LLM tools** get privacy right but make you install Ollama, download a model, or paste in
  an API key first.

**Easy Write uses the AI already built into macOS 26** — so it's private *and* there's nothing to set
up, and it understands formality, which a plain dictionary translator can't.

## What's new in 2.0

- 🔎 **Easy Write Bar** (`⌥⌘K`) — every language, tone and action next to your selection. Type to
  filter, or type any instruction and run it once. The result streams in before anything changes.
- 🔁 **Both directions with one key** — `⌥⌘T` translates into your target language, or back into
  yours if the text is already in it.
- 🧠 **Remembered per app** — formal in Mail, informal in Slack, without touching a setting.
- ✨ **Actions** — your own instructions on a shortcut, shareable as a link.
- 🏝️ **Notch HUD** — progress and results right at the top of the screen, with ⌘Z to undo.
- 📥 **Release tooling** for a notarized download and optional updates, pending validation.

See the full [changelog](CHANGELOG.md).

## What you get

- ⚡ **Translate in place** — select → shortcut → replaced, in any app
- 🗣️ **Formal / informal / natural** — German *Sie* vs *du*, French *vous* vs *tu*, Spanish *usted* vs *tú*…
- 📖 **Read mode** — translate text you can't edit into your own language, in a card you can pin or have read aloud
- 🌍 **13 languages** — German, French, Spanish, Italian, Portuguese, Dutch, Turkish, Polish, Russian, English, Japanese, Chinese, Arabic
- ✨ **Actions** — Fix grammar, Make it shorter, Reply politely, Explain the grammar, Sound native, Japanese keigo, or write your own
- 📚 **Glossary & style notes** — exact terms and your preferences in every result
- 🕘 **Opt-in history**: originals and results stay local; disabling it deletes the history file
- ⌨️ **Custom shortcuts** — rebind everything
- ♿️ **VoiceOver** — labelled controls and spoken results
- 🔒 **100% local** — no account, no API key, no telemetry; the only network access is the optional update check

## 🆚 How it compares

The honest version: these tools are good — Easy Write just occupies a different corner (free,
private, nothing to set up, register-aware).

| | **Easy Write** | DeepL | Google Translate | Apple Translate | Ollama-based tools |
|---|:---:|:---:|:---:|:---:|:---:|
| Runs on-device / private | ✅ | ❌ cloud | ❌ cloud | ✅ | ✅ |
| No account or API key | ✅ | ❌ | ⚠️ | ✅ | ⚠️ needs setup |
| Formal vs informal (Sie/du) | ✅ | Pro only | ❌ | ❌ | ✅ |
| Replace selection in place | ✅ | app only | ❌ | ✅ | varies |
| Works in any app | ✅ | ✅ | ❌ | ⚠️ some | ✅ |
| Your own rewrite actions | ✅ | ❌ | ❌ | ❌ | varies |
| Setup | build from source (2.0 preview) | account | — | built-in | install Ollama + model |
| Open source | ✅ | ❌ | ❌ | ❌ | ✅ |
| Price | **Free** | Free / Pro | Free | Free | Free |

## Requirements

- **macOS 26 (Tahoe) or later** on **Apple Silicon**
- **Apple Intelligence turned on** — System Settings → *Apple Intelligence & Siri*

## ⬇️ Install

**2.0 is a source-only preview.** The notarized DMG, Homebrew tap and update feed are not live.
The welcome window checks Accessibility and Apple Intelligence, then offers a practice swap.
For this unreleased preview, use the local 2.0 checkout; the public default branch is still 1.x.

**Build from source.**

```bash
git clone https://github.com/onekapisch/easy-write.git
cd easy-write
./setup-signing.sh      # once, if you don't have a Developer ID: keeps the Accessibility grant across rebuilds
./build.sh              # compile + bundle + sign → "Easy Write.app"
cp -R "Easy Write.app" /Applications/
open "/Applications/Easy Write.app"
```

**Upgrading from 1.x?** Your settings move over automatically. macOS asks for Accessibility again
because the app is now signed by OneKapisch. If the old "EasyWrite" entry is still in
System Settings → Privacy & Security → Accessibility, remove it, then delete the old
`EasyWrite.app` from Applications.

## Usage

| Shortcut | Action |
|:---:|---|
| `⌥⌘K` | Open the **Easy Write Bar** next to your selection |
| `⌥⌘T` | **Translate** — into your target language, or back into yours |
| `⌥⌘E` | **Read** — translate into your language in a card (for text you can't edit) |
| `⌥⌘G` | **Fix grammar** (a built-in action) |
| `⌃⌥R` | **Reply politely** (a built-in action) |

Click the menu-bar icon for the panel: status, your target language and tone, and quick tiles. Every
shortcut can be changed in **Settings → Shortcuts**, and any action can get one.

## 🔒 Privacy & security

Your text never leaves your Mac. The model runs locally; there is no analytics, no telemetry, and no
account. The only time Easy Write goes online is to check for updates, and only if you allow it — it
sends no selected text. The permission it needs is **Accessibility**, to
read your selection and paste the result back. Your clipboard is restored
after temporary pastes. Opening Studio or support links visits the destination in your browser.

Automatic replacement requires the original window, field, selection range and text to remain
verifiable. Otherwise the result appears for review instead of being pasted. The HUD says
"Paste sent" because synthetic keystrokes have no delivery acknowledgement.

History is off by default, including upgrades from early 2.0 previews. Opting in stores originals
and results as unencrypted local JSON. Disabling deletes that file. Expired entries are removed
every minute while running, after wake, and on the next launch. Backups may retain earlier copies.

See [SECURITY.md](SECURITY.md) for the full data flow, what's stored where, and how to report a
vulnerability.

## 🧠 How it works

See **[HOW_IT_WORKS.md](HOW_IT_WORKS.md)** — the on-device LLM, the permissive-guardrails gotcha, the
in-place swap, the Bar that types without stealing focus, the notch HUD, two-way language detection,
and how shared actions stay safe.

## Roadmap

**2.1 — Screen Translate:** drag over any part of the screen (an image, a video subtitle, a scanned
PDF) and read it in your language, on-device. Ideas and PRs welcome — open an [issue](../../issues).

## FAQ

**Is it really free?** Yes — free and open source (MIT). No account, no subscription, no upsell.

**Does it send my data anywhere?** No. Your text is only ever processed on your Mac. The optional
update check sends the app version, nothing else.

**Why does it need Accessibility permission?** To read your current selection and paste the result
back using macOS APIs. The app must expose its selected text through Accessibility. If it does
not, capture fails safely instead of using unrelated clipboard contents.

**Why not the Mac App Store?** Posting keystrokes to other apps is incompatible with App Store
sandboxing. Source builds are available; a notarized download is being prepared.

**"Apple Intelligence is still preparing."** Apple Intelligence is on but still downloading its model
— that happens the first time you turn it on and can take a while. Wait until System Settings →
*Apple Intelligence & Siri* shows it's ready (it needs free storage and a network connection). The
panel and the welcome window update on their own when it's done.

**How is this different from Apple's built-in Translate or Writing Tools?** Apple's Translate opens
a popover you copy from and can't do formal vs informal. Writing Tools rewrites through a menu.
Easy Write is one keystroke in any app, translates with the right tone, and runs your own actions.

## Contributing

**2.0 launch media:** [asset guide](launch-assets/v2/README.md),
[local gallery](launch-assets/v2/gallery.html), and [website proposal](launch-assets/v2/WEBSITE-REDESIGN.md).
Reproduce the native screenshots and owned-window HUD recording with
`bash tools/launch-assets/export.sh`. These synthetic demos are not translation benchmarks.

PRs and issues welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Run `EasyWrite --selftest` before
opening a PR, and `--eval` for any prompt or language change.

## License

[MIT](LICENSE) © onekapisch

---

<div align="center">

⭐ **If Easy Write saves you a trip to a translation site, star the repo — it genuinely helps other people find it.**

Made with Swift + Apple's on-device intelligence · No cloud, no accounts, no tracking.

</div>
