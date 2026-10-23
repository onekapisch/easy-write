# Easy Write search foundation audit

Scope: single live product page plus site-wide discovery files; local 2.0 preview architecture. Checked 2026-10-23. Overall: a crawlable foundation with a substantial task-content gap. Numeric score withheld because rankings, field performance and account-level discovery data are unavailable.

## Main findings

| Area | Severity | Confidence | Finding and evidence | Fix |
|---|---|---|---|---|
| Crawlability | Pass | Confirmed | Product HTML, robots.txt and sitemap return HTTP 200; no page noindex or X-Robots-Tag observed; canonical matches the product URL | Preserve at approved deployment; check CDN/WAF treatment with owner tools |
| Search crawlers | Pass | Confirmed | robots.txt explicitly allows OAI-SearchBot; wildcard permits other public crawlers; GPTBot is deliberately blocked | Preserve search/training distinction; no reason to enable training for discovery |
| Search intent | Warning | Confirmed | Live title is “Easy Write · OneKapisch”; product page has a brief workflow and no Easy Write guide links | Add focused guides and descriptive title; retain brand and version clarity |
| Requirements | Warning | Confirmed | Live requirements say “macOS. See the repository README.” | State Apple Silicon, macOS 26+, Apple Intelligence/model readiness and Accessibility locally |
| Release clarity | Warning | Confirmed | Local 2.0 UI exceeds public 1.1.1; latest GitHub release API has no binary assets | Distinguish public 1.x and local preview on every guide; no fictitious download CTA |
| Structured data | Pass | Confirmed | One JSON-LD block already exists on live product page | Extend truthfully with Article/BreadcrumbList for guides; no invented ratings or FAQ/HowTo result promises |
| Content freshness | Warning | Confirmed | Live body “Facts verified 2026-08-27”; sitemap uses 2026-09-21 across inspected entries | Update only actually reviewed/changed Easy Write URLs; avoid resetting all site dates |
| Unique value | Warning | Confirmed | Direct competitors advertise local rewriting and formality | Use original examples and product mechanics; remove unsupported “only” claims from proposed marketing |
| Performance | Info | Hypothesis | No reliable PageSpeed/CrUX measurement obtained | Run PSI/field review separately; do not claim CWV pass from screenshots |
| Mobile/readability | Info | Hypothesis | No live 375px measurement in baseline | Verify generated guide artifact at 375px and desktop before approval |
| llms.txt | Info | Confirmed | Live request returns 404 | Optional documentation only; absence is not an indexing issue |

## Opportunities

1. Answer selected-text translation questions with steps, the built-in option and limitations.
2. Make Sie/du a concrete worked example and reference feature, rather than a uniqueness slogan.
3. Use open-source implementation details to explain privacy and setup in ways a generic AI article cannot.

## Environment limitations

Bundled SEO Python scripts were attempted. The execution Python lacks `requests`, so fetch/robots/PSI checks failed before measurement. A standard-library direct fetch recovered HTTP, source, metadata, robots and sitemap evidence, saved in `evidence/live-audit.json`. This is a tooling limitation, not a site failure. No PageSpeed metrics or broken-link results are fabricated. Browser and generated-artifact checks belong to implementation verification.

Search Console/Bing access, indexing status, crawl logs, current query volumes, conversion data, real user outcomes, compatibility matrix, native accessibility acceptance and real translation-quality evaluation remain unknown or outside this audit. A sitemap entry does not prove indexing; a robots allowance does not prove a crawler can pass the CDN.
