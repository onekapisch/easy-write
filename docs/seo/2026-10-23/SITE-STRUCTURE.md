# Easy Write guide architecture

Root: `https://www.onekapisch.com/products/easy-write/`.

| Route suffix | Role | Primary discovery |
|---|---|---|
| `guides/` | Resource collection and task chooser | Product page and Journal |
| `guides/translate-selected-text-mac/` | In-place translation task | Hub; setup and formality siblings |
| `guides/german-formal-informal-translation/` | Register task | Hub; translation sibling |
| `guides/offline-ai-writing-mac/` | Local-processing decision/comparison | Hub; shortcut and setup siblings |
| `guides/apple-writing-tools-shortcut/` | Built-in keyboard access and comparison | Hub; offline and action siblings |
| `guides/custom-rewrite-actions/` | Reusable editing recipes | Hub; translation and setup siblings |
| `guides/easy-write-setup-troubleshooting/` | Requirements, version and failure recovery | Hub; every workflow guide |

Each detail page has product and collection breadcrumbs, a visible author and reviewed date, table of contents, a useful direct answer, explicit release-state notice, source list, product CTA and two related guide links. All important content ships in HTML. Existing site fonts, colors, article layouts, navigation and Reduced Motion behavior are reused. No new framework or API.

Canonical and Open Graph URLs use the final OneKapisch paths, even in the local artifact. Concept builds retain noindex; release artifacts are eligible for indexing only after an approved deployment. New guide URLs enter the sitemap with their actual content date. No artificial hreflang until equivalent German pages exist. The native shared-action utility is a separate route and is not replaced by these guides.
