# How to translate selected text on a Mac with a keyboard shortcut

Easy Write translates text where you are writing: select a passage in a supported Mac app, choose the translation shortcut, and review the result in the same workflow. It uses Apple's on-device model, so translation processing does not require sending your selected text to a translation service.

**Version check, 23 October 2026:** the latest public release is **1.1.1**, distributed as source. **2.0 is an unreleased local preview.** Its Bar, two-way translation, custom actions, and revised replacement safeguards are described separately below. The public default branch does not install those preview features. Check the [official release listing](https://github.com/onekapisch/easy-write/releases) before following version-specific instructions.

## Start with a short, editable passage

You need an Apple Silicon Mac running macOS 26 or later, with Apple Intelligence enabled and its model ready. Installation currently involves building the public source; follow the [official repository instructions](https://github.com/onekapisch/easy-write). A finished notarized 2.0 download and Homebrew installation are not available yet.

For a first translation, use a disposable note rather than an important message:

1. Open Easy Write and grant its requested Accessibility permission.
2. Open Preferences from its menu-bar icon and set the target language.
3. Type a short sentence in an editable app and select that sentence.
4. On public 1.x, press **Option–Command–T** for formal translation, **Option–Command–I** for informal translation, or **Option–Command–P** for plain translation that keeps the source's natural tone.
5. Read the entire result before sending or saving the message. Check names, dates, numbers, and who is doing what.

These are the defaults documented for public 1.x. Your own bindings may differ. If another app intercepts a combination, change it in Easy Write's shortcut preferences.

The useful change is fewer manual transfers between your draft and a separate translator. There is no measured time-saving claim here: the benefit depends on your writing habits and whether your app supports the workflow.

## Choose the relationship before the shortcut

Formal and informal describe forms of address, not translation quality. When writing German, an explicit choice helps distinguish *Sie* from *du*. It cannot decide your relationship with the recipient for you.

**Illustrative example, not a recorded app output or benchmark:**

| Intended message | Example German wording |
|---|---|
| Ask one person formally | Können Sie mir den Entwurf schicken? |
| Ask one person informally | Kannst du mir den Entwurf schicken? |

Both ask for a draft. The pronoun and verb change together. Read [the German formal and informal translation guide](german-formal-informal-translation.md) for object pronouns, possessives, and the difference between singular *du* and plural *ihr*.

Plain translation is useful when you want to preserve an existing tone. It is less explicit when the source is ambiguous: English “you” does not tell the model whether the recipient is one person, several people, or someone addressed formally.

## Translate something you are reading

An incoming email or webpage is different from a draft: you want to understand it without editing the original. Public 1.x provides **Option–Command–E** to translate selected text into English in a popup.

Select a complete sentence or short paragraph so the model has context. A single word may have several meanings. Text in an image or scanned PDF is not the same as selectable text; this guide does not promise OCR or screen translation.

If selection capture is unavailable, try a selectable text view or a plain-text document you control. Do not assume a visible highlight means every app exposes usable selection information.

## What changes in the local 2.0 preview

**This section requires the unreleased local 2.0 checkout.** Cloning today's public default branch gives you the public 1.x workflow above.

The preview adds the **Easy Write Bar**, opened with **Option–Command–K**, for choosing language, tone, or an action next to a selection. **Option–Command–T** becomes a two-way Translate command; it is no longer the public 1.x formal shortcut. **Option–Command–E** normally reads into your configured home language. If the selection already reliably matches that language, Read switches to your target writing language; it uses English as a fallback when both language settings match.

Preview-before-replace is available but **off by default**. Enable it deliberately if you want to inspect results before changing a draft. The preview also verifies the original app, window, field, selection range, and selected text before sending a replacement. If these cannot still be verified, it presents a review card instead. Its “Paste sent” message reports a sent keystroke, not proof that another app accepted the edit.

## Privacy and realistic limits

The local 2.0 implementation captures selected text through Accessibility. An app must expose its selection; unsupported capture fails without translating unrelated clipboard contents. This is a version-specific implementation detail, not a guarantee that every Mac app works.

Translation and actions run locally. In the 2.0 preview, optional update checks are separate network activity and do not include selected text. Opt-in history is off by default; enabling it saves originals and results in unencrypted local JSON. Keep it off if you do not want that content retained.

Review important writing for meaning as well as tone. For a first real task, choose a short draft, confirm the target language, translate, and compare the result against the original before sending. If setup or capture fails, use the [setup and troubleshooting guide](easy-write-setup-troubleshooting.md).

---

Editorial fact references, checked 2026-10-23: public repository README and GitHub release listing for 1.x availability and shortcuts; local `README.md`, `SECURITY.md`, `Sources/EasyWrite/Core/Store.swift`, `Runner.swift`, and `Replacer.swift` for explicitly labeled 2.0 behavior. Examples are authored illustrations. Recheck public availability before publication.
