# Easy Write competitor fact check

Checked 2026-10-23 against official vendor documentation. Competitor capabilities below are vendor claims, not behavior tested in this task. Pricing intentionally omitted from public comparison copy to reduce drift.

## Verdict

“No such app exists”, “the only private Mac writing tool”, and “other translators cannot choose Sie/du” are not supportable. Even the combination of Apple Intelligence, selected-text replacement, custom prompts and formality overlaps other products. Easy Write can have a distinctive implementation without inventing a new product category.

| Tool | Relevant overlap | Important distinction or unknown | Primary evidence |
|---|---|---|---|
| RewriteBar | Selected text, replacement, custom actions, Apple Intelligence and other local providers; explicit Sie-to-du example | Paid license/trial and multiple providers. Account-free status not established; actual behavior not tested | https://rewritebar.com/ ; https://rewritebar.com/docs/core-features/create-commands ; https://rewritebar.com/blog/2025/how-to-setup-apple-intelligence |
| Reword | In-place tone pill, custom instruction and Apple's local model | Website build supports replacement; App Store build has different sandbox limits. Optional vendor cloud; account requirement unclear | https://reword.in/ |
| PromptK | Shortcut-based transformations, custom prompts, Apple Intelligence, auto-replace; advertises no account | Local or cloud chosen per shortcut; free shortcut allowance and paid unlock. App's broad OS support is not Apple-model eligibility | https://promptk.app/index.html |
| Ghostwriter | Free open-source Apple Intelligence rewrites; formal/casual/translation; proofreading in place | Primary focus includes autocomplete with a separate downloaded model. Persistent custom rewrite library not established | https://ghostwriter.mshl.me/ |
| Refine (refine.sh) | Offline grammar, custom instructions, rewrite/translate Floating Editor, shortcuts | Downloaded model; per-task local/cloud choice. Floating Editor output should not be assumed to auto-replace every selection | https://refine.sh/ ; https://refine.sh/features ; https://refine.sh/guides/how-refine-works |
| Apple Writing Tools | Selected-text rewriting, proofreading, tone and freeform changes in supported apps | Built into Apple Intelligence. Do not describe every Apple Intelligence feature as entirely offline. UI varies by macOS version | https://support.apple.com/guide/mac-help/writing-tools-write-improve-summarize-mchldcd6c260/mac ; https://www.apple.com/privacy/features/ |
| DeepL | Translation, formal/informal controls including German | Its formality docs specify Pro. Do not infer inferior quality or mandatory account for all free translation from that fact | https://support.deepl.com/hc/en-us/articles/4406432804498-Use-the-formality-feature |

Do not confuse Refine at refine.sh with the separate getrefine.app product. Likewise, Text Lens is primarily OCR extraction, not the closest rewriting competitor.

## Claims we can use

- Free and MIT licensed; native Swift Mac utility.
- Translation and rewriting use Apple's on-device model; no account/API key in Easy Write.
- Formal/informal/natural controls and selected-text workflow.
- In the local 2.0 preview: preview Bar, custom actions, per-app preferences, glossary, opt-in local history, and source-target checks before replacement.

These are product facts to verify against the version being offered. None establishes exclusivity or comparative quality superiority.

## Claims requiring evidence before use

- “Faster”, “most accurate”, “best”, “works in every app”, “native-level German”, “never changes meaning”, and measured time saved.
- Fully validated app compatibility, VoiceOver acceptance and signed update delivery.
- Customer outcomes, testimonials, installs or retention. The developer's workflow observations and synthetic UI renders are not customer research.

## Positioning options

Recommended: lead with multilingual messages and deliberate formality, supported by a simple selected-text workflow and local processing. This is narrow enough to demonstrate.

Alternative: lead with privacy-first open-source writing actions. This is credible but faces a crowded set of local AI utilities and has weaker differentiation until the interaction is demonstrated.

Avoid positioning as a full Grammarly replacement: continuous checking, plagiarism tools and team editing workflows are different jobs. Avoid treating a local model as automatically higher quality than cloud translation.

## Comparative validation to commission

Use identical synthetic short messages across tools; record OS/app versions, model selection, cold/warm state, setup steps, replacement success and meaning/register checks. Publish raw methodology and failures. Request permission for any real customer examples. Until then, all comparison tables describe documented features, not a tested ranking.
