# German formal and informal translation: Sie, du, and the details that change

For German translation, decide how you address the recipient before translating. Formal **Sie** and informal singular **du** affect pronouns, possessives, and verb forms throughout the message. Replacing one word is not enough. Easy Write offers explicit formal and informal translation choices so you can make that decision while working on your draft.

**Version check, 23 October 2026:** public Easy Write is **1.1.1**, available as source. **2.0 remains an unreleased local preview.** This guide gives public 1.x shortcuts first and identifies preview behavior separately. Verify availability in the [official releases](https://github.com/onekapisch/easy-write/releases); today's public default branch does not provide the 2.0 Bar or its per-app memory.

## What formal and informal actually change

English “you” leaves several German choices unspecified. Are you addressing one person informally, several people informally, or using formal address? Your intended relationship supplies information the English sentence may not contain.

These **illustrative examples are not recorded app outputs or quality benchmarks**:

| Function | Formal address | Informal, one person |
|---|---|---|
| Subject: “Can you help?” | Können Sie helfen? | Kannst du helfen? |
| Dative: “I will send you the file.” | Ich schicke Ihnen die Datei. | Ich schicke dir die Datei. |
| Possessive: “your draft” | Ihr Entwurf | dein Entwurf |

Notice *können* becoming *kannst*, *Ihnen* becoming *dir*, and *Ihr* becoming *dein*. Other cases and noun genders change endings again. A find-and-replace operation on *Sie* will leave many of these relationships wrong.

The dictionary describes [Sie as formal address](https://www.duden.de/rechtschreibung/Sie_Anrede), including address to one or several people, and [du as second-person singular](https://www.duden.de/rechtschreibung/du). Formal address uses capitalized *Sie*, *Ihnen*, and *Ihr* with the appropriate endings. Informal *du* is normally lowercase; Duden notes that letters may also capitalize it. A capital *Du* alone therefore does not make a message formal.

## Do not confuse informal plural ihr with formal Ihr

If “you” means an informal group, the subject is **ihr**, not **du**. [Duden identifies this as second-person plural](https://www.duden.de/rechtschreibung/ihr_Anrede_2_Person). Compare these authored illustrations:

- One person: “Habt ihr Zeit?” would address the wrong number; use “Hast du Zeit?”
- Several people informally: “Habt ihr Zeit?”
- Formal address to one or more people: “Haben Sie Zeit?”

Lowercase *ihr* also has other grammatical uses, so read the whole sentence. Formal possessive *Ihr* in “Ihr Entwurf” and the informal plural subject *ihr* in “ihr habt” are different roles. Easy Write's German informal instruction explicitly favors singular *du*. Do not assume that shortcut handles an informal group correctly; review plural address separately.

## Translate a German email with Easy Write 1.x

The [public repository README](https://github.com/onekapisch/easy-write) documents three register choices:

1. Open Easy Write's menu-bar Preferences and choose German as the target language.
2. Write a short draft that clearly states the request and recipient context.
3. Select the complete passage you want translated.
4. Press **Option–Command–T** for formal translation or **Option–Command–I** for informal translation.
5. Check the greeting, pronouns, verb endings, names, and factual details before sending.

**Option–Command–P** uses plain translation, preserving the source's natural tone. When the recipient relationship is the reason you are translating, the explicit formal or informal command is usually the clearer instruction. Shortcuts can be customized, so check your preferences if those defaults do something else.

For an incoming message you want to understand, public 1.x offers **Option–Command–E** to read the selected passage in English. It does not require changing the sender's text.

## A practical review before sending

Use a small checklist instead of trusting a fluent-looking result:

1. **Recipient:** Is this one person or a group? Does the chosen address match the existing conversation or agreed style?
2. **Consistency:** Does the draft maintain *Sie/Ihnen/Ihr* or *du/dir/dein* throughout, with matching verbs?
3. **Meaning:** Are the sender and recipient still doing the same things? Has a request become a promise?
4. **Details:** Are dates, amounts, product names, attachments, and negations preserved?
5. **Scope:** Did the translation keep your actual message rather than adding reasons, commitments, or claims?

There is no universal etiquette rule that every workplace, age group, or industry follows. An existing exchange, explicit preference, or organizational style guide is more useful than treating “professional” as a synonym for *Sie*. If the choice is unclear, clarify it with the recipient or someone who knows the context.

## What 2.0 adds, and what other tools already do

In the **unreleased local 2.0 preview**, the Bar lets you select a tone, and per-app memory can remember the last language and tone used there. Remembered settings are a convenience: one Mail window can contain both a formal customer email and an informal message to a friend. Check the actual recipient each time. The preview's **Option–Command–T** is two-way translation, not the public 1.x formal command.

Easy Write is not the only tool with register controls. [DeepL documents formal and informal translation](https://support.deepl.com/hc/en-us/articles/4406432804498-Use-the-formality-feature) for its listed Pro platforms. Easy Write's useful proposition is its on-device Mac workflow and explicit choices, rather than an exclusive invention of formality-aware translation.

Try the workflow first on a disposable sentence. For hardware, permissions, or model readiness, follow the [setup guide](easy-write-setup-troubleshooting.md). For selection and read-mode details, use the [Mac translation guide](translate-selected-text-mac.md).

---

Editorial fact references, checked 2026-10-23: public repository README and release listing for 1.x shortcuts; local `README.md`, `Sources/EasyWrite/Core/Models.swift`, `Store.swift`, and `Languages.swift` for the labeled 2.0 preview. Grammar references: Duden entries linked above; competitor feature reference: DeepL Help Center. Examples are authored illustrations and require language review before publication.
