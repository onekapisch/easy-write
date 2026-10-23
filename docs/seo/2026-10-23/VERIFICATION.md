# Research and local guide verification

Checked 2026-10-23. This records the local content package, not public website publication or a native app release.

## Scope delivered

- 62 candidate query phrases: 13 observed autocomplete suggestions and 49 proposed English/German variants. Eleven public-question references provide qualitative context. No volume, CPC, keyword-difficulty or ranking figures are asserted.
- Competitor fact check against official sources; overlapping tools invalidate a category-exclusivity claim.
- Six complete guides totaling approximately 5,400 source words, plus a hub, internal discovery and technical metadata in the existing website preview.
- Research strategy, topic ownership, calendar, roadmap, audit and GEO notes. Native draft copies are dated research snapshots; future live edits belong in the website's content directory.

## Checks completed

- Native documentation and website diffs pass `git diff --check`.
- Website `pnpm run build`, `pnpm run lint` and `pnpm run type-check` pass.
- Existing Fable release regressions pass: 25/25.
- Product-preview and guide/renderer checks pass: 8/8. Guide checks were observed failing before route integration, then passing. They cover release boundaries, schema, internal discovery, local references, table/prompt rendering, HTML escaping, unsafe-link rejection and private editorial-note removal.
- Bounded artifact verifier passes: 48 indexable routes, 50 HTML documents, 261 files at the recorded build.
- Full `pnpm run release:check` exits 0, including the shared Chromium/WebKit browser suite:
  69 checks and 75 screenshots. Four nonfatal warnings fall under the suite's existing warning policy;
  they are not lint warnings or new guide console errors.
- Playwright Chromium: all six guides checked at 375px and 1440px, with no page overflow, broken loaded images, console errors or unexpected external requests. Exercised hub links, table-of-contents anchors, related-guide navigation and mobile menu. Six prompt blocks remain available with JavaScript disabled.
- Screenshots of the hub, German guide and action guide inspected. Browser evidence lives in the website's `output/playwright/easy-write-seo/` directory and is excluded from Git.
- Independent code/content review found one Read-mode exception; corrected against `Runner.read()`. No remaining blocking issue was reported within that review's scope.
- Direct external-source fetch: 16 guide destinations return 200. DeepL Help Center returns 403 to the audit client, including its current formality article. Its content was independently readable in web research; this fetch restriction is not labeled a confirmed broken link.

## Limits

Bundled SEO Python scripts lack the `requests` dependency. A standard-library direct fetch recovered live HTML/headers, robots and sitemap evidence. The generic finding-verifier only deduplicates structured findings; it does not establish the truth of claims. No PageSpeed/CrUX result is available. Local browser geometry is not a Core Web Vitals field measurement.

No Search Console/Bing account data, actual indexing result, keyword volume, install telemetry, AI citation share, comparative speed/quality benchmark or customer outcome is claimed. Physical Safari/VoiceOver, real native cross-app delivery, native-speaker review, notarization and signed updates remain their own gates. No native source code was changed by this content task.

## Publication

Local review only. No merge, push, website deployment, GitHub release or native distribution was performed. Both repositories require explicit owner approval for publication. Recheck public release state and references at that point.
