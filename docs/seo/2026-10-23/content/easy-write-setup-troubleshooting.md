# Easy Write setup and troubleshooting on Mac

Easy Write needs three things before it can translate a selection: a supported Mac, a ready Apple Intelligence model, and permission to access the selected text. Start by checking which of these is unavailable. Repeatedly changing shortcuts will not solve a model that is still downloading, and reinstalling the app will not make an unsupported text field expose its selection.

**Release status, checked 23 October 2026:** **1.1.1 is the latest public release and is built from source. 2.0 is an unreleased local preview.** A notarized 2.0 download, Homebrew tap, and published update feed are not live. The [official releases listing](https://github.com/onekapisch/easy-write/releases) and [public repository](https://github.com/onekapisch/easy-write) describe the public version; its default branch does not install 2.0 features.

## 1. Check your Mac and installation route

Easy Write requires **Apple Silicon and macOS 26 or later**, with Apple Intelligence enabled. Check your chip and macOS version in Apple menu → About This Mac. An Intel Mac does not meet this app's requirements.

The current public installation route is the source-build procedure in the repository README. Read the current instructions and scripts before running them. This guide does not provide a separate installer, terminal shortcut, or security bypass. If you are waiting for a signed, notarized download, do not treat a locally signed 2.0 candidate as that release.

Building 2.0 requires access to its local preview checkout. The public repository link is for the available 1.x source, not a way to obtain unpublished features.

## 2. If Apple Intelligence is unavailable

Open System Settings → Apple Intelligence & Siri. Easy Write 1.1.1 distinguishes several conditions in its error message:

| Condition | Next step |
|---|---|
| Unsupported device | Check Apple Silicon and macOS requirements. |
| Apple Intelligence turned off | Enable it in System Settings. |
| Model still preparing | Let the model finish downloading; check free storage and network access. |

An enabled switch does not prove the on-device model is ready. The first download can take time. There is no reliable universal waiting period to promise. Follow the status shown by macOS and the app, then retry a short sentence.

Once the model is ready, Easy Write's translation processing runs locally. Initial Apple model downloads and any permitted app updates are separate from processing your selected text. Avoid testing offline operation before setup has finished.

## 3. Grant Accessibility to the app you actually opened

Open System Settings → Privacy & Security → Accessibility and check the Easy Write entry. Accessibility lets the app access selected text and send replacement keystrokes; it is a powerful permission that should be granted to a build you trust. [Apple explains how to allow Accessibility apps](https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/mac).

After changing the permission, reopen the app if macOS requests it, then test a disposable sentence. If you have multiple builds, make sure you are launching the intended copy. A changed identity or different installed app may need its own grant.

The local 2.0 documentation describes an upgrade-specific permission change because the signing identity differs from 1.x. Do not apply preview upgrade instructions blindly to the public version. Keep your settings and version information available when investigating an upgrade problem.

## 4. Test selection before an important document

Type “Please send the draft tomorrow” in a disposable editable note. This is **synthetic practice text, not a benchmark or a promised translation result**. Select the sentence, set your target language, and use the appropriate command.

For **public 1.x**, defaults are:

- **Option–Command–T:** formal translation.
- **Option–Command–I:** informal translation.
- **Option–Command–P:** plain translation preserving natural tone.
- **Option–Command–E:** read the selection in English in a popup.

If a shortcut opens another tool, change its binding in Preferences. Test the new combination in the same simple document before returning to a browser editor or another complex app.

For the **local 2.0 preview**, **Option–Command–K** opens the Bar and **Option–Command–T** is two-way Translate. **Option–Command–E** normally reads into your home language; if the selection already reliably matches home, it switches to your target writing language, with English as a fallback when both settings match. The changed meaning of the T shortcut matters when moving between versions.

## 5. If text cannot be captured or replaced

The local 2.0 implementation requires selected text exposed through macOS Accessibility. A visible highlight is not enough in every app. Unsupported selection capture fails safely; it does not use unrelated clipboard content. Try a plain-text field you control to distinguish an app-specific limitation from a general setup problem.

In 2.0, automatic replacement also checks the source process, window, field, selection range, and original text. Moving focus or editing the passage while generation runs can make replacement unverifiable. A review card is then expected behavior. Keep the source selection stable and inspect the result.

The preview's “Paste sent” status means a keystroke was sent. Verify the actual destination before continuing. Screenshots, scanned PDFs, and video subtitles are outside this selected-text workflow; OCR screen translation is not available yet.

## 6. Choose review and retention settings deliberately

In local 2.0, **preview-before-replace is off by default**. Turn it on if you want to review a draft before replacement. **History is also off by default** and needs explicit consent. Enabling history stores originals and results as unencrypted local JSON, up to 100 entries with configurable 1–30-day retention.

Disabling history deletes its file. Backups or snapshots may retain earlier copies, and timed cleanup cannot run while the app is closed. Optional update checks send no selected text, but ordinary network metadata is visible to the destination. These details are documented in the local security policy and must remain separate from public 1.x feature claims.

If a problem persists, report the app version, macOS version, source-app name, command used, and exact error. Reproduce it with harmless sample text instead of sending private document contents. Use the repository's private security reporting route for vulnerabilities.

---

Editorial fact references, checked 2026-10-23: public README and GitHub release listing for installation, 1.1.1 diagnostics, and 1.x shortcuts; local `AGENTS.md`, `README.md`, `SECURITY.md`, `Sources/EasyWrite/Core/LLMTranslator.swift`, `Store.swift`, `Runner.swift`, `Replacer.swift`, and `HistoryStore.swift` for explicitly labeled 2.0 behavior. Recheck release delivery before publication.
