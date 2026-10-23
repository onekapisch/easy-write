---
title: "Six custom rewrite actions for clearer everyday writing on Mac"
description: "Original prompts for concise updates, polite requests, grammar fixes, and clearer handoffs, with a popup-first review workflow."
reviewed: "2026-10-23"
status: "Editorial draft for local website preview"
---

# Six custom rewrite actions for clearer everyday writing on Mac

A custom rewrite action is a saved instruction applied to selected text. Name one job, explain what must stay unchanged, and specify the output. These six prompts are starting points, not accuracy guarantees. Test each with disposable examples before using replacement mode.

**Availability:** Easy Write's action setup described here belongs to the **local 2.0 preview**. The public project is version 1.1.1 and source-only. No public 2.0 download or update feed is offered by this guide.

## Create an action with review first

In the local preview, open **Settings → Actions**, choose **New action**, and give it a specific name. Paste one instruction below into **Instruction**. Set **Result** to **Show in popup** and leave the shortcut unassigned while testing.

Select a sample in a supported app and inspect the action's Easy Write Bar preview; copy rather than replace while testing. A later assigned shortcut uses the popup setting. Try exceptions, negation, amounts, and deadlines before considering **Replace selection**.

These original instructions run on Apple's on-device model in the local preview. Output can still omit details, misread intent, or introduce unsupported wording.

## 1. Shorten an update without losing its conditions

Use this for repetitive status messages.

```text
Shorten this status update in the same language. Keep every name,
date, amount, blocker, exception, and next step. Preserve uncertainty:
may, might, and expected must not become promises. Do not invent
progress. Return only the revised update in one short paragraph.
```

Test: “We expect to send the draft on Tuesday, unless the supplier has not confirmed the price.” Both the tentative timing and supplier condition must survive.

## 2. Make a request polite without inventing flexibility

Use this for an abrupt request.

```text
Rewrite this request politely in the same language. Keep the request,
deadline, and boundaries unchanged. Do not add apologies, gratitude,
alternative dates, or promises that are absent from the original.
Do not weaken a required deadline. Return only the revised request.
```

Compare “by Friday” with “if possible.” A polite rewrite should preserve the difference between a deadline and an optional request.

## 3. Fix grammar with minimal changes

Use this for minimal correction.

```text
Correct grammar, spelling, and punctuation in the same language.
Make the smallest necessary changes. Keep the author's tone,
names, terminology, numbers, paragraph breaks, and degree of
certainty. Do not add explanations. Return only the corrected text.
```

Include a product name or specialist term. If unfamiliar wording is incorrectly “corrected,” refine your instruction or glossary and test again.

## 4. Turn rough notes into a clear handoff

Use this for factual handoff notes.

```text
Organize these notes into three sections: Current state, Next steps,
and Open questions. Use the same language and short bullet points.
Include only facts explicitly present in the notes. Do not infer
owners, priorities, deadlines, or completed work. Put missing
information under Open questions rather than guessing it.
```

Keep this in popup mode and compare each bullet with the notes. An unassigned task should not acquire an invented owner.

## 5. Explain a confusing sentence before editing it

Use this when you understand the vocabulary but not the sentence's structure.

```text
Explain this sentence in plain English. State its likely meaning,
then identify any ambiguous phrase or unclear pronoun. Distinguish
what the sentence says from an interpretation. Do not add background
facts. Use at most three short bullets. Do not rewrite it as a reply.
```

Keep **Show in popup** selected for explanations. Ask the author to resolve consequential ambiguity; a model's interpretation does not confirm intent.

## 6. Make a German message formal

Use this after choosing formal address for the recipient.

```text
Rewrite this German message using formal Sie address consistently.
Keep the meaning, names, numbers, dates, requests, and commitments.
Adjust pronouns and verb forms as needed. Do not add a greeting,
signature, title, or apology. Return only the revised German message.
```

Check possessives and verbs as well as Sie. A sentence can include a formal pronoun while retaining an inconsistent informal form elsewhere. For unfamiliar German, have a proficient speaker review important correspondence.

## Use a small test set

Run every action against examples containing “cannot,” “not yet,” a named person, €240, and a specific date. Include one sentence that already meets the instruction and one where context is missing. Compare the output line by line. These examples are checks you can perform, not published benchmark results.

Change one instruction at a time. If an action repeatedly changes facts, keep it in popup mode or stop using it for that task. A well-written prompt can improve direction without making a probabilistic model a factual validator.

## Share instructions, not private context

The local preview supports shared-action links and shows the full instruction before import. Imported actions start without a shortcut and in popup mode. Review any received instruction before adding it. Remove client names, private style notes, and example secrets from instructions you intend to share.

Keep a short library of actions you understand. Consistent review matters more than collecting dozens of prompts you have never tried.

## Editorial notes — exclude from published article

- Action model/output options: `Sources/EasyWrite/Core/Models.swift:35`; editor, new-action popup default, and shortcut control: `Sources/EasyWrite/UI/SettingsWindow.swift:264`.
- Execution and transformation prompts: `Sources/EasyWrite/Core/Runner.swift:92` and `Sources/EasyWrite/Core/LLMTranslator.swift:280`.
- Imported-action protections: `Sources/EasyWrite/Core/Models.swift:138` and `SECURITY.md` Shared actions.
- Release boundary: `README.md` preview notice and `docs/launch-handoff.md` sections 2–4. The six prompts have not been model-benchmarked or physically accepted across apps.
- External context: [Apple's generative AI design guidance](https://developer.apple.com/design/human-interface-guidelines/generative-ai) discusses appropriate model choices and transparent processing. No invented user results or measured productivity claims appear here.
