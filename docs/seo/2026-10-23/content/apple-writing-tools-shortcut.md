---
title: "How to rewrite selected text on Mac: Writing Tools and shortcuts"
description: "Use Apple's Writing Tools or a dedicated Mac app to rewrite a selection, review the result, and keep the details that matter."
reviewed: "2026-10-23"
status: "Editorial draft for local website preview"
---

# How to rewrite selected text on Mac: Writing Tools and shortcuts

To rewrite selected text on a supported Mac, select your draft, open Apple's Writing Tools from the available contextual menu, and choose a rewrite or proofreading option. If you prefer a dedicated keyboard workflow, Easy Write's local 2.0 preview provides a selection Bar and configurable action shortcuts. In either case, review the rewritten text before sending it.

**Availability:** The Easy Write instructions here refer to the **local 2.0 preview**. The public Easy Write project remains version 1.1.1 and source-only. These instructions are not an announcement of a public 2.0 installer or update feed.

## First try the Mac's built-in option

Apple documents Writing Tools in many places where you write, including third-party apps and websites. On supported configurations, the workflow is:

1. Select a sentence or paragraph in your draft.
2. Control-click the selection and look for **Writing Tools** or **Show Writing Tools**.
3. Choose **Rewrite**, **Proofread**, or a tone such as **Friendly**, **Professional**, or **Concise**, where offered.
4. If available, use **Describe a change** for a specific request.
5. Review the proposed text and finish using the controls shown in your version.

The exact menu, controls, and entry points can vary by macOS version, app integration, language, region, and enabled Apple features. Current Apple documentation also distinguishes Writing Tools from newer Siri writing experiences. Follow the [official Writing Tools guide](https://support.apple.com/guide/mac-help/writing-tools-write-improve-summarize-mchldcd6c260/mac) for the software you are using.

An effective first instruction is narrow: “Make this more concise without removing the deadline.” It is easier to assess than “Make this better.” The instruction asks for a behavior; it does not guarantee that the output obeys it.

## Assign a shortcut to an existing Writing Tools menu command

If your app exposes **Show Writing Tools** in its menu bar, you can try a macOS App Shortcut:

1. Find the command in that app's menus and note its exact title in your interface language.
2. Open **System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts** and add an entry for that app.
3. Enter the exact menu command, including punctuation. For an ambiguous nested command, Apple documents using its menu path separated by `->`.
4. Choose an unused key combination, save it, and test it on a selected sentence in that app.

This binds an existing menu command; it does not add Writing Tools to unsupported fields or guarantee that one binding works everywhere. An app without the command cannot gain it this way. [Apple's App Shortcuts instructions](https://support.apple.com/guide/mac-help/create-keyboard-shortcuts-for-apps-mchlp2271/mac) explain menu-title matching and shortcut conflicts.

## Decide whether a keyboard action adds value

You may be comfortable opening system controls whenever needed. A dedicated action becomes useful when you repeatedly request the same edit, want to select a translation register, or prefer a consistent place for your own instructions.

For example, “make this shorter” and “translate this into German using Sie” are different tasks. The second needs a target language and relationship to the recipient. Do not infer formality from how polished the output looks. Check the actual address and verb forms.

Apple's system tools and dedicated apps overlap. A separate app should earn its place through a workflow you prefer, not through a claim that macOS cannot rewrite text.

## Use the Easy Write Bar in the local 2.0 preview

The preview requires macOS 26 or later, Apple Silicon, and Apple Intelligence enabled and ready. Accessibility permission allows Easy Write to read supported selections and attempt a verified replacement. It cannot capture every field in every app.

With the local preview running:

1. Open a disposable document and type a short sample.
2. Select the exact text you want to change.
3. Press **Option–Command–K** to open the Easy Write Bar using its default binding.
4. Choose an action or translation, or type a one-time instruction.
5. Wait for the preview and compare it with your original.
6. Replace only when the result is appropriate and the original destination remains valid.

The Bar is designed to keep the source app frontmost while showing controls near the selection when position information is available. If that app does not report bounds, the panel can appear near the pointer instead. Treat the preview as an editing aid, not proof that an email or message has been delivered.

## Configure shortcuts around your work

The local preview's default bindings include **Option–Command–T** for translation, **Option–Command–E** for Read mode, and **Option–Command–G** for the built-in grammar action. Translation can reverse direction when selected text is confidently identified as already being in the target language. Short or ambiguous text may not trigger that reversal.

Open **Settings → Shortcuts** to inspect or change bindings. Actions can also receive their own shortcut. Check the same keys in the app where you write; a system or app command may already use them. Start with one action you can remember instead of assigning every possible edit a key.

For an unfamiliar custom action, choose **Show in popup** before adding a shortcut. This keeps the result available for inspection while you learn how the instruction behaves.

## If a menu or shortcut is unavailable

If Apple's controls are missing, check the Mac's compatibility, installed software, Apple Intelligence state, and language/region requirements. Try a simple editable text field in another supported app to distinguish a configuration issue from that particular context. See [Apple's availability and requirements](https://support.apple.com/en-us/121115).

For Easy Write's local preview, check that it is running, Accessibility is enabled, and its model status is ready. Reselect a short sample without switching windows during processing. If a source field does not expose selected text through Accessibility, do not expect repeated shortcuts to fix that incompatibility. A changed or unverifiable replacement destination is intended to produce a review result instead.

## Review meaning before style

Before accepting a rewrite, compare names, amounts, dates, links, negation, and promises. “We may deliver Friday” must not become “We will deliver Friday.” Read the full sentence around the selection too: an individually fluent replacement can still clash with the surrounding paragraph.

Keep the original until the edit is checked. The most useful shortcut is one that reduces repeated steps while leaving you in control of what you say.

## Editorial notes — exclude from published article

- Native behavior: `README.md` sections Requirements and Usage; `Sources/EasyWrite/Core/Store.swift:21`, `Sources/EasyWrite/Core/Runner.swift:64`, and `Sources/EasyWrite/UI/BarPanel.swift`.
- Capture/replacement boundary: `SECURITY.md` Data flow and Permissions; `HOW_IT_WORKS.md` sections 2–4; implementation in `Sources/EasyWrite/Core/Replacer.swift` and `Sources/EasyWrite/Core/LanguageDetector.swift`.
- Action popup option: `Sources/EasyWrite/Core/Models.swift:36` and `Sources/EasyWrite/UI/SettingsWindow.swift:336`.
- Release status: `docs/launch-handoff.md` sections 2–4. Cross-app physical shortcut behavior still needs acceptance; no performance claim is made here.
