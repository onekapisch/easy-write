# Search-intent research and keyword evidence

Research snapshot: 2026-10-23. Target: English-speaking Mac users initially, with German formality as a specific task and German-language expansion as a hypothesis. This is an intent map, not a search-volume report. `keyword-map.csv` is the working query-to-page inventory.

## What the evidence does and does not show

Google autocomplete was requested for 12 seed strings through the public suggestions endpoint, with English or German interface language and no signed-in account. No geographic-location parameter or representative search-user sample was available. Suggestions can vary by time, locale, location and personalization. They are not exact counts of actual searches. An empty response does not mean zero demand. Some irrelevant suggestions were excluded from the keyword map; raw responses remain in `evidence/autocomplete.json`.

Independent forum questions provide actual words people used to express a need. They do not tell us Google keyword frequency, current product defects or total addressable market. Several Writing Tools threads began in 2024; they support enduring keyboard-access intent, not a claim that today's macOS still has every reported limitation. Developer posts are useful competitor discovery but are not independent validation of demand.

Every proposed phrase in the CSV is explicitly labeled. Do not describe proposed variants as measured searches. All volume, CPC and difficulty fields are blank because no verified dataset was available. The priority reflects product fit, reader utility and availability constraints, not a fabricated market score.

## Observed autocomplete worth targeting

| Returned phrase | Seed | Appropriate owner |
|---|---|---|
| offline translator mac | offline translator mac | Offline writing guide, translation section |
| offline translator macos | offline translator mac | Same page, no duplicate MacOS article |
| offline translator macbook | offline translator mac | Same page; hardware requirements visible |
| offline translator app mac | offline translator mac | Same page |
| best offline translator for mac | offline translator mac | Explain tradeoffs; do not invent a tested winner |
| free offline translator for mac | offline translator mac | Explain free source and current build requirement |
| how to use apple translate offline | offline translator mac | Adjacent intent; Apple Translate is not Easy Write's Foundation Models engine |
| apple intelligence writing tools shortcut | apple intelligence writing tools shortcut | Writing Tools guide |
| apple intelligence writing tools shortcut mac | apple intelligence writing tools shortcut | Same guide |
| macos translate selected text | translate selected text mac | Selected-text guide |
| mac translate selected text | translate selected text mac | Same guide |
| deepl alternative macos | deepl alternative mac | Offline guide; compare documented tradeoffs |
| deepl alternative mac | deepl alternative mac | Same guide |

Examples excluded from targeting: “offline translator machine”, “what software does apple use”, generic “how to select text on mac”, and “text edit shortcuts mac”. These may be legitimate queries, but their intent is too ambiguous or unrelated to justify a new Easy Write page.

## Public-question evidence register

| ID | Observed title / expressed need | Source | Interpretation |
|---|---|---|---|
| Q1 | Quickly translate text using Spotlight? | https://www.reddit.com/r/MacOS/comments/yy1sdr/quickly_translate_text_using_spotlight/ | Wants fewer steps to translate a short passage |
| Q2 | To tell macOS to always translate selected text from English, and not from some another language | https://apple.stackexchange.com/questions/478278/to-tell-macos-to-always-translate-selected-text-from-english-and-not-from-some | Language detection can conflict with reader intent |
| Q3 | Have any plans been announced for an Offline Mode for DeepL? | https://www.reddit.com/r/languagelearning/comments/xc5uf6/ | Willingness to trade features/quality for offline access; anecdotal |
| Q4 | In search of an offline translator app | https://www.reddit.com/r/degoogle/comments/1j17mgz/ | Explicit local-processing requirement |
| Q5 | Google translate Alternative | https://www.reddit.com/r/degoogle/comments/1uh4771/google_translate_alternative/ | Offline/in-app translation need in the discussion |
| Q6 | how accurate is deepl for testing my sentence formation? | https://www.reddit.com/r/German/comments/zhiy4h/ | Register and language-learning concerns; no Easy Write quality evidence |
| Q7 | What is the du form of - Müssen Sie die Werte kennen ? | https://www.reddit.com/r/German/comments/15a6cin/ | Specific formality confusion and longer-email consistency |
| Q8 | Apple please add a keyboard shortcut for writing tools | https://www.reddit.com/r/MacOS/comments/1gw225x/apple_please_add_a_keyboard_shortcut_for_writing/ | Repeated desire for keyboard invocation; older thread |
| Q9 | Faster way to pull up writing tools | https://www.reddit.com/r/MacOSBeta/comments/1ek9hra/faster_way_to_pull_up_writing_tools/ | Fewer menu interactions; older thread |
| Q10 | Apple Intelligence Writing Tools in Google Docs and other Unsupported Software | https://www.reddit.com/r/MacOS/comments/1geb67j/apple_intelligence_writing_tools_in_google_docs/ | App-context compatibility need; comments are not technical proof |
| Q11 | No more “Writing Tools” in MacOS 27? | https://www.reddit.com/r/MacOS/comments/1witt8t/no_more_writing_tools_in_macos_27/ | Recent discovery/entry-point confusion; verify Apple docs before explaining behavior |

No forum is cited as authority for Apple's API, release requirements, competitor privacy or German grammar. Public guides instead reference primary product documentation and Duden where needed.

## Candidate clusters

1. **Selected-text translation:** translate selected text Mac; translate highlighted text Mac shortcut; translate text without copy paste Mac; translate read-only text Mac. Highest product fit. Public 1.x can serve this task today.
2. **Offline writing/translation:** offline translator Mac; private AI writing assistant Mac; offline Grammarly alternative Mac; DeepL alternative Mac without API key. Competitive and broad: answer decisions honestly, link to narrower tasks, and disclose source-build friction.
3. **German register:** German translation formal informal; translate English to German Sie or du; change German email from Sie to du. Excellent product demonstration; search volume unknown. Do not promise native-level results.
4. **Writing Tools shortcuts:** Apple Intelligence Writing Tools shortcut Mac; rewrite selected text Mac keyboard shortcut; Writing Tools alternative Mac. Answer built-in capabilities fairly; distinguish OS versions.
5. **Reusable editing:** custom rewrite actions Mac; shorten email without changing meaning; grammar shortcut Mac; polite request rewrite. Content is useful because it provides original prompts and checks. Most action functionality is 2.0 preview, which limits immediate activation.
6. **Setup/support:** Easy Write requirements; Apple Intelligence model still preparing; Mac translator Accessibility permission; Easy Write shortcut not working. Lower apparent category reach but high usefulness and fewer misleading download visits.

## How to validate next

After approved publication, filter Search Console to `/products/easy-write/`, export 28/90-day queries and pages, and record country/device plus branded versus non-brand. Check whether Google associates the intended guide with each task; do not split pages because a synonym appears. Use impression/click data to edit page titles and examples only when there is enough context to interpret it.

For quantitative demand, run a region-specific English/German Keyword Planner or reputable keyword-tool export for this exact candidate list. Record database, country, language, period, matching method and date. Low-volume niche terms can be grouped or hidden by tools; do not interpret missing values as zero. Search Console impressions are site exposure, not total market search volume.

For AI visibility, maintain a small reproducible prompt set with provider, model, web-search setting, country, date, full answer and cited URLs. An occasional citation is an observation, not stable market share. Do not infer traffic or installs from it.
