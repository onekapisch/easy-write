# Easy Write 2.0 website redesign

Proposal for review. Not approved for implementation or publication. Evidence checked 2026-10-23. Scope: the existing OneKapisch product URL only. No app redesign, new domain or website changes in this task.

## Direction and audience

Lead with a writing moment, not a product registry: select a sentence, choose its language and tone, review the result without leaving the task.

Primary audience: multilingual Mac users writing email, messages and documents, especially when formality matters. Secondary: privacy-conscious users and developers. This is proposed positioning, not measured audience research.

Recommend a light, product-led story with the Daylight Bar hero. A developer-first layout hides the experience; a dark cinematic page competes with readable copy. Keep Midnight as alternate campaign artwork, not a second hero or theme toggle.

The [current page](https://www.onekapisch.com/products/easy-write/) presents a general workflow, demonstration and registry facts. Requirements defer to the repository. It does not explain the 2.0 Bar, remembered tone, actions or reader improvements. That is a content gap; no conversion data establishes its commercial effect.

## Hero copy and release states

Eyebrow: **Easy Write 2.0 preview**

Headline: **The right words. Right where you write.**

Body: **Translate and rewrite selected text on your Mac. Choose the tone, preview the result, and keep your words on-device.**

Requirement line: **macOS 26+ · Apple Silicon · Apple Intelligence ready**

Trust line: **Free and open source. No account. No API key.**

| State | Primary CTA | Secondary CTA | Visible status beside CTAs |
| --- | --- | --- | --- |
| Now: source preview | View source on GitHub | Watch the 2.0 preview | 2.0 is in development. Latest public release: 1.1.1. No 2.0 download yet. |
| Later: validated public DMG | Download for Mac | View source on GitHub | Show the actual release version, requirements and release notes. |

Today, identify public source as 1.x. The local 2.0 branch is not a verified public build path. Only offer “Build the 2.0 preview” after checking its exact public branch/tag and instructions. Public `main` must not imply 2.0 access.

Switch only after owner-approved publication of a signed, notarized, stapled DMG, clean-Mac installation acceptance and a verified asset URL. Pin the release asset. Remove “preview” from release copy. Automatic-update claims require separate feed and installed-build acceptance. No disabled download button, waitlist or email capture.

## Annotated wireframe and section copy

```text
[Compact OneKapisch header]       Easy Write | How it works | Privacy | CTA

[01 HERO: copy left, Daylight Bar artwork right]
    Headline, body, requirements, state-aware CTAs and status.
    Artwork shows a selected sentence and the actual Bar preview.
    Mobile: copy, CTAs, then a readable close crop. Never tiny desktop UI.

[02 THE WORKFLOW: wide context image + three short steps]
    “Select. Choose. Review.”
    “Select a sentence. Open the Bar with Option + Command + K.
     Choose a language, tone or action. Review, then replace or copy.”
    Menu-bar panel in context establishes where the app lives.
    Supporting line: “One translate shortcut can work in both directions.”

[03 TONE: focused close-up, copy alongside]
    “Say it with the right tone.”
    “Choose formal, informal or natural. With per-app memory enabled,
     Easy Write remembers the tone you choose for each app.”
    Show German Sie / du using reviewed synthetic text.

[04 READER + ACTIONS: two editorial blocks, not a feature wall]
    “Read without replacing.”
    “Translate selected text into your language. Pin the reader,
     compare the original, copy the result or hear it aloud.”
    Reader screenshot, including pin and Speak controls.

    “Make your own shortcuts.”
    “Fix grammar. Shorten a draft. Write a polite reply.
     Save your own instructions and give them a shortcut.”
    Custom-action screenshot. Small note: “Shared actions are reviewed
     before import.” Do not promise a live sharing website yet.

[05 FEEDBACK: user-played HUD film with poster]
    “A little feedback. Right at the top.”
    “Follow progress in the notch HUD, with an undo shortcut when available.”
    “On displays without a notch, feedback sits below the menu bar.”
    Persistent caption: “Actual SwiftUI HUD. Synthetic text, timings
     and backdrop. This illustrates the interface, not processing speed.”

[06 TRUST + FIT: plain-language facts, always visible]
    “Your words stay on your Mac.”
    “Translation and rewriting run on-device. History is off by default.
     Optional update checks and external links still use the network.”
    Compatibility, permission and retention details below.

[07 GET STARTED: repeat the same release-aware CTA]
    “Keep writing in your own flow.”
    Source or download CTA, requirements and exact release status.
    Quiet links: README | Release notes | Report an issue | Security
    OneKapisch attribution and existing legal links close the page.
```

Mention glossary and style notes near Actions. Put language choices in an expandable list, not a numerical claim. Screen Translate remains roadmap work. Remove the facts counter; place related products below the final CTA.

## Art and media rules

Use restrained lavender atmosphere, ample space, native typography and #7C5CFF accents. Preserve dark native app panels inside the light presentation. Use soft shadows, subtle gradients and opaque fallbacks. No stock AI symbols, floating dashboards, endorsement walls or decorative counters.

Use `images/hero-daylight.webp` for the introduction; `images/menu-bar.webp` for menu context;
`images/tones.webp`, `images/reader.webp` and `images/actions.webp` for the feature sections;
and `video/notch-animation.mp4` with `images/notch-poster.webp` for the HUD demonstration.
`social/github-social.jpg` is the share image. The raw UI PNGs are in `raw/`.
The actions image currently shows grammar correction, not the custom-instruction editor;
the adjacent copy can describe customization, but the image must not be labelled an editor.
Preserve the PNG masters and generate responsive derivatives with dimensions and alt text.
No redrawn UI, private text, notifications or usage counts presented as social proof.

Keep `video/notch-native-master.mp4`, the original owned-window recording. Ship the compressed,
60 fps click-to-play MP4 with poster and native controls, no autoplay or third-party embed.
Reserve GIF for GitHub or optional download. The present film demonstrates only HUD animation.
A separate real select/shortcut/replace movie is required before offering a “Watch the workflow”
CTA; do not substitute this staged HUD film or the old 1.x demo. Synthetic footage proves neither
translation speed nor insertion or compatibility. Preserve “Paste sent,” not confirmed delivery.

## Honest trust and compatibility copy

- **Requirements:** “Requires macOS 26 or later, Apple Silicon, and Apple Intelligence enabled with its on-device model ready. Availability depends on Apple's supported languages and regions.” Link Apple guidance without implying newer-OS certification.
- **Permission:** “Accessibility permission lets Easy Write read the selected text and send a replacement. Apps must expose their selection through macOS Accessibility.”
- **Replacement:** “If the original target can no longer be verified, Easy Write shows the result for review instead of replacing it.” Unsupported selection capture may fail; review mode cannot recover text the app could not read.
- **Compatibility:** “App support varies.” The owner reports the physical workflow working. App/version matrix and VoiceOver acceptance remain open. No “every app,” certification badges or unqualified app logos.
- **Retention:** “History is opt-in. When enabled, originals and results are saved locally without encryption. Turning history off deletes that file, not backups.” Link the version-matched security policy for retention limits.
- **Network:** Source builds disable updates by default. Future optional checks expose request metadata, including IP address, but no selected text. External links contact their destinations. Never say “zero network.”
- **Quality:** “AI can make mistakes. Review important text.” No speed claims, time-saved figures, invented testimonials, installation counts or competitor rankings.

## Accessibility, delivery and GitHub

Use semantic headings, real links/buttons, visible focus, keyboard-operable video controls and a skip link. Target WCAG 2.2 AA; test text and control contrast, including purple/white combinations. Describe the silent HUD sequence in text; add captions if speech is added.

Respect `prefers-reduced-motion`: static posters, no reveal transforms or loops. Otherwise allow brief reveals, no scroll locking or parallax. Content works without JavaScript. Test 375px and 200% zoom: readable copy, full CTA labels, 44px touch targets, no horizontal overflow.

Proposed budgets, not measured results: initial compressed transfer <=700KB including a <=250KB hero; product-page incremental JS <=50KB gzip and total first-load JS <=150KB gzip. No font download required. Each below-fold image <=180KB; HUD web video <=6MB, requested only on play. Reserve media aspect ratios. Target mobile LCP <=2.5s, CLS <=0.1 and INP <=200ms; record lab conditions and do not present lab results as field evidence.

Keep the canonical URL. Proposed title: “Easy Write 2.0 preview | Private translation for Mac.” Align description and share artwork; no download metadata or rating schema that implies unavailable proof. Keep release state, demo disclosure and requirements aligned with GitHub. GitHub owns source, issues, notes and eventual DMGs; the site explains the product. Add a README backlink only when approved. Never reuse stale 1.x security claims.

No analytics, pixels, replay, fingerprinting or click telemetry by default. Future telemetry requires separate approval and informed opt-in consent. Host media first-party. GitHub clones, downloads and stars are not installs. Validate comprehension without tracking infrastructure.

## Prioritized implementation and acceptance checklist

All items below are future work after proposal approval, not authorization to implement or publish.

- [ ] **P0: content and state.** Approve narrative and exact copy. Recheck public source, release and feed state. Wire one explicit CTA state across hero, navigation and closing section. Confirm current links never imply public 2.0 availability.
- [ ] **P0: evidence.** Match each feature and screenshot to source. Review synthetic language examples. Keep physical workflow reports distinct from app-matrix, language-quality, VoiceOver, notarization and update acceptance. Record remaining limits beside the relevant claim.
- [ ] **P0: media.** Inventory completed assets, check permissions and private-data leakage, produce responsive exports and static posters. Keep simulation disclosure visible outside playback. Verify no media fabricates successful cross-app delivery.
- [ ] **P1: implementation.** Inspect the website's own AGENTS.md and stack first. Build only the approved product page, reuse its shell, preserve canonical links and legal navigation. Do not introduce a web stack into this native app repository.
- [ ] **P1: page acceptance.** Check 375px, tablet and desktop; 200% zoom; keyboard, screen reader and reduced motion; disabled JavaScript; every CTA, anchor and video control. Run the website repository's build, lint and type checks. Measure transfer and performance against the budgets above.
- [ ] **P1: comprehension.** Ask representative users what it does, who can run it, what is available today, and whether their text is uploaded. Revise any copy that implies a downloadable 2.0, universal app support or measured speed. Do not claim conversion lift.
- [ ] **P0 before publication:** obtain explicit owner approval for the implementation and publication separately. A DMG CTA additionally needs the release gates above. Preview acceptance does not grant deploy, push, release or publishing authority.

## Sources and evidence boundaries

- [Live product page](https://www.onekapisch.com/products/easy-write/): current content structure, source CTA and generic requirements. Text inspection only, not a visual browser audit.
- [Public repository](https://github.com/onekapisch/easy-write) and [latest public release](https://github.com/onekapisch/easy-write/releases/tag/v1.1.1): public 1.x source and release baseline.
- [Apple availability guidance](https://support.apple.com/en-us/121115): language, region and model-readiness caveats. The current page covers newer Apple Intelligence releases; it is not evidence that Easy Write has passed newer-OS acceptance.
- Local [AGENTS.md](../../AGENTS.md), [README.md](../../README.md), [SECURITY.md](../../SECURITY.md)
  and [TODO.md](../../TODO.md): features, privacy, preview status and release gates.
- Local UI: [BarPanel.swift](../../Sources/EasyWrite/UI/BarPanel.swift),
  [MenuPanel.swift](../../Sources/EasyWrite/UI/MenuPanel.swift),
  [ReaderPanel.swift](../../Sources/EasyWrite/UI/ReaderPanel.swift),
  [NotchHUD.swift](../../Sources/EasyWrite/UI/NotchHUD.swift),
  [SettingsWindow.swift](../../Sources/EasyWrite/UI/SettingsWindow.swift) and
  [Theme.swift](../../Sources/EasyWrite/UI/Theme.swift): implemented interfaces, not end-to-end certification.
- Owner brief: physical workflow reported working; specified asset set and native HUD recording.
  The completed asset inventory and capture proof are in `manifest.json`; the backdrop and timings
  remain staged. This is not independent end-to-end acceptance of text replacement.
