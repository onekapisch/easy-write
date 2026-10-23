# Easy Write: AI-search readiness

Checked 2026-10-23. Technical/content review, not an AI citation-share study. No numerical platform visibility score is assigned: no measured Google/ChatGPT/Perplexity answer sample or owner reporting was available.

## Findings

| Area | Observed state | Confidence | Action |
|---|---|---|---|
| HTML retrieval | Live product content is readable in the response HTML | Confirmed | Keep guides fully static and linked |
| AI-search access | robots.txt explicitly allows OAI-SearchBot; wildcard permits public crawl | Confirmed at file level | Preserve; CDN and real bot access need separate verification |
| Training control | GPTBot blocked deliberately | Confirmed | Keep policy; training access is not a search prerequisite |
| Google AI eligibility | No noindex/snippet block observed on product page | Confirmed technical observation | Indexing/snippet eligibility still require Google inspection; no inclusion guarantee |
| llms.txt | Live 404 | Confirmed | Optional, not a blocker; avoid ranking claims |
| Entity clarity | Product name, publisher, source and JSON-LD exist | Confirmed | Add clear requirements and factual version boundaries |
| Useful references | Product page has little task teaching | Confirmed | Six sources-backed guides with original prompts/examples |
| Independent outcomes | No verified customer case study or comparative benchmark available | Unknown | Collect consented evidence; do not fabricate it |
| Brand visibility | No systematic independent mention census conducted | Unknown | Track genuine reviews/citations; no inauthentic placements |

## Content implementation principles

Give each guide a concrete opening answer, natural question headings, semantic lists/tables, source links near claims, author identity and an actual review date. Use ordinary useful prose; no magic word-count window, fabricated data, hidden AI instructions or keyword repetition. Put product affiliation beside the byline. Give alternatives credit for overlapping features.

Use Article, CollectionPage, BreadcrumbList and factual SoftwareApplication metadata. Avoid FAQ/HowTo rich-result promises, fabricated aggregate ratings, nonexistent install URLs, and “AI-optimized” schema inventions. Local screenshots support understanding but are synthetic examples, not measured output evidence.

## Platform boundaries

- **Google:** foundational SEO, indexing and snippet eligibility; official documentation says no extra AI-specific technical requirements. See https://developers.google.com/search/docs/appearance/ai-features . Search Console Web reporting includes AI-feature traffic; do not promise a separate Google citation report.
- **ChatGPT search:** retain OAI-SearchBot access. GPTBot concerns training, which the site's policy blocks separately. No attempt was made to change that policy. Official reference: https://developers.openai.com/api/docs/bots . This task does not provide an actual ChatGPT citation measurement.
- **Apple discovery:** Applebot and Applebot-Extended are different controls; do not assume that training permission is required for search. https://support.apple.com/en-us/119829 . Real discovery is unmeasured here.
- **Bing/Copilot and Perplexity:** useful accessible pages and real references are a reasonable foundation; no live citation result was measured, so no readiness or visibility score is presented.

## Five highest-priority changes

1. Add the task guides and discovery paths.
2. State model, OS, source-only release and permission requirements next to the task.
3. Explain source-selection safety, local retention and optional network activity precisely.
4. Preserve truthful metadata and the existing search/training crawler split.
5. Obtain original, consented outcome evidence and measured compatibility before promotional comparisons.
