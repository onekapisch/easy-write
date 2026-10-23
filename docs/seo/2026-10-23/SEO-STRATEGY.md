# Easy Write: search and AI discovery strategy

Research date: 23 October 2026. Scope: Easy Write on the existing OneKapisch website. This is a researched acquisition hypothesis, not a revenue forecast. Publication is a separate approval and release gate.

## Decision

Build a focused resource collection at `/products/easy-write/guides/`, supported by six substantive guides and links from the product page and Journal. Keep the existing editorial design and static generator. Give every guide a specific job, an answer near the beginning, practical instructions, source links, named authorship, and an accurate version boundary.

Positioning: **Translate and rewrite selected text on your Mac, with the tone you choose and processing that stays on-device. Free and open source. No account or API key.** These are verified product attributes, not exclusive inventions.

The proposed “no such app exists” claim is false. RewriteBar, Reword, PromptK, Ghostwriter and Refine have substantial overlap. RewriteBar even documents Apple Intelligence and German Sie-to-du conversion. We should win through useful teaching, an inspectable implementation, clear setup, and a demonstrably good experience, rather than unsupported novelty claims. See COMPETITOR-ANALYSIS.md.

## Research method and limits

- Reviewed the live product page, robots.txt and sitemap; current local Swift source, README, release notes and security policy; GitHub latest release API and remote tags.
- Queried English and German task, alternative, shortcut, privacy and formality topics online. Retained 12 Google autocomplete seed snapshots, including empty responses. Autocomplete outputs are suggestions, not user logs or frequency estimates. Some results are irrelevant and are excluded from targeting.
- Reviewed independent public questions about Writing Tools invocation, selected-text translation, offline translators and German formality. Developer launch posts demonstrate supply; they are weaker evidence of demand.
- Checked direct vendor documentation for seven close alternatives and Apple. These are attributed vendor claims, not independent comparative tests.
- No Search Console, Bing Webmaster Tools, Keyword Planner or paid keyword-volume account was available. Monthly volume, difficulty, CPC, current ranking, organic traffic, conversion rate, installs and AI citation share are **unknown**. No tools exposed DataForSEO metrics in this session.
- This is a bounded research corpus. It cannot enumerate every query people make. The keyword map separates observed autocomplete, public questions and proposed variants. Proposed variants are hypotheses until impressions or a keyword dataset validate them.

## Audience and jobs

Primary hypothesis: multilingual Apple Silicon Mac users who repeatedly write short messages and want to control register without moving their draft into a separate website. English/German is the initial editorial focus because Easy Write exposes explicit Sie/du controls and the founder can offer concrete product expertise.

Secondary hypotheses: people seeking an offline writing assistant; keyboard-focused users; privacy-conscious users willing to build open-source software; developers seeking reusable text transformations. These are audience hypotheses, not measured customer segments.

Current acquisition friction is substantial: public 1.1.1 is source-only; the local 2.0 preview has no public binary or source release. Content can educate now, but broad consumer promotion should wait for a validated installation path. A guide must never turn a 2.0 screenshot into a promise about the public 1.x release.

## Content and search intent

| Priority | Reader's job | One canonical destination | Why this page earns its place |
|---|---|---|---|
| P0 | Understand Easy Write and requirements | `/products/easy-write/` | Product entity, accurate capabilities, release state and source CTA |
| P0 | Translate highlighted text without repeated copy/paste | `guides/translate-selected-text-mac/` | Editable versus read-only workflows; capture and replacement limits |
| P0 | Keep German address consistent | `guides/german-formal-informal-translation/` | Side-by-side Sie/du examples and review checklist |
| P0 | Decide whether local writing help fits | `guides/offline-ai-writing-mac/` | Honest alternatives, local versus cloud setup and tradeoffs |
| P1 | Access Apple writing features by keyboard | `guides/apple-writing-tools-shortcut/` | Explain the built-in option fairly, then dedicated-app workflow |
| P1 | Repeat a useful editing task | `guides/custom-rewrite-actions/` | Six reusable prompts, expected boundaries and synthetic checks |
| P0 | Get a working first result | `guides/easy-write-setup-troubleshooting/` | Hardware/model/Accessibility prerequisites and recovery paths |

URLs in this table are relative to `/products/easy-write/`. The hub owns broad navigation; individual pages own task intent. Do not create separate thin pages for “Mac”, “MacBook”, “macOS”, each app name, or every “best/free/private” permutation. See SITE-STRUCTURE.md and TOPIC-CLUSTERS.md.

## What makes the content defensible

Explain the mechanics we own: how selected text becomes a model request, what formal/informal settings ask for, why Accessibility is needed, and what happens when the source field changes. Show actual native UI with synthetic text. Clearly identify a staged film as staged. Do not call it a measured speed demonstration.

Use original short examples and reusable instructions. Describe potential benefits as use cases: fewer manual transfers, deliberate tone choice, repeatable edits. Do not write “users save 40%”, customer quotations, adoption counts, conversion uplift or translation-quality superiority without evidence. The current code documents controls; it does not prove outcomes for other people.

## GEO: what we will actually do

Google says standard SEO remains relevant to AI Overviews and AI Mode; there are no special technical requirements or AI schema. [Google's canonical guidance](https://developers.google.com/search/docs/appearance/ai-features).

Our implementation should therefore provide indexable static HTML, clear internal links, factual answer passages, primary references, an identifiable author, truthful Article/BreadcrumbList markup, descriptive titles and a mobile reading experience. Preserve the distinction between search retrieval and model training: the current robots policy allows OAI-SearchBot while blocking GPTBot. Do not unblock training crawlers to chase discovery. Search eligibility is not a guarantee of inclusion or a verified WAF allowance.

An llms.txt file is optional documentation, not a ranking mechanism. There is no evidence here that adding it would improve discovery, and its absence is not a technical SEO failure. Do not manufacture FAQ/HowTo rich-result promises, citation scores or a universal “ideal AI passage length”. Do not seek fake community mentions or create Wikipedia pages for marketing.

## Measurement and decision gates

Use Search Console's Web performance report filtered to the Easy Write prefix: indexed pages, queries, non-brand impressions/clicks, country/device and page. AI-feature traffic is included in Web reporting; do not promise a dedicated Google citation dashboard. Inspect Bing's available AI reporting separately after account access is established. Neither impressions nor AI citations equal installs.

The app and existing Easy Write preview have no telemetry. Preserve this. GitHub clones, stars and release asset downloads are distribution proxies, not installed or active users. Do not silently add tracking or an account funnel. An optional user survey or a separately consented aggregate install measurement design would be a future product decision.

Targets are operational, not traffic forecasts:

1. At approval: seven useful new routes, accurate metadata and version labels, no broken local links, no horizontal overflow at 375px, visible product and Journal discovery paths.
2. At day 14 after publication: inspect all seven URLs in Search Console and fix actionable discovery/indexing problems. Indexing itself is not promised.
3. At day 28: establish a query/page baseline and separate branded from non-brand traffic. Expand only where there is observed intent or a concrete support need.
4. At day 56: improve pages with impressions but weak engagement using query evidence and usability feedback; avoid reacting to tiny samples as proof.
5. At day 90: choose whether to expand German, add tested comparisons, or consolidate pages. No arbitrary domain-authority target or fabricated revenue projection.

## Commercial logic

Easy Write is free and MIT licensed today. A million-dollar revenue outcome is not a justified forecast for a free utility with no measured acquisition funnel. Strong search distribution can create product adoption and evidence of the studio's engineering, but any paid upgrade, service offer or sponsorship would require a separate business decision and must preserve the existing free license commitments.

The sequence is: dependable public installation → helpful task content → observed discovery → user evidence → expansion. Paid acquisition before an installable release and a defensible measurement plan would be premature.

## Evidence register

- Live product: https://www.onekapisch.com/products/easy-write/
- Product source: https://github.com/onekapisch/easy-write
- Latest release checked through GitHub API: v1.1.1, published 2026-07-14, zero binary assets.
- Google AI requirements: https://developers.google.com/search/docs/appearance/ai-features
- Apple Writing Tools: https://support.apple.com/guide/mac-help/writing-tools-write-improve-summarize-mchldcd6c260/mac
- Apple availability: https://support.apple.com/en-us/121115
- DeepL formality: https://support.deepl.com/hc/en-us/articles/4406432804498-Use-the-formality-feature
- Grammarly online requirement: https://support.grammarly.com/hc/en-us/articles/115000091011-Can-I-use-Grammarly-offline
- Public question corpus and competitor URLs: KEYWORD-RESEARCH.md and COMPETITOR-ANALYSIS.md.
- Raw observations: `evidence/autocomplete.json`, `evidence/live-audit.json`.

Recheck vendor features and public release state immediately before publication. Research does not certify future OS compatibility or release readiness.
