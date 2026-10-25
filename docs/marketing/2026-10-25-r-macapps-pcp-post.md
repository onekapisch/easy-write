# r/macapps: proposed PCP post

Draft only. This targets r/macapps, not r/MacOSApps. No Reddit submission authorized here.

## Title

[OS] Easy Write: free, on-device translation and rewriting without switching apps

## Post body

Hi r/macapps, I’m Kapisch, the developer of Easy Write.

**Problem**

I write in two to three languages every day for work. Repeatedly copying a sentence, switching to a translator and pasting the result back was interrupting the writing itself.

So I built Easy Write, a Mac menu-bar app that translates or rewrites selected text in supported apps. You can use a translation shortcut, or open the Bar with **Option–Command–K** to choose a language, tone or writing action and review the result before replacing it.

The part I care about most is choosing how you address someone: **formal “Sie” or informal “du” in German**, for example. You can assign separate shortcuts for formal and informal translation, remember tone preferences per app, and save your own instructions for grammar fixes or shorter drafts.

**Comparison**

DeepL also offers formal/informal translation for supported languages through its Pro plans. Easy Write’s focus is combining those tone choices with selected-text shortcuts and **Apple’s on-device model**, so you can work in your original editor and process the text locally.

It uses Apple Intelligence already available on supported Macs, without a separate AI account or API key. The focus is a keyboard-first writing workflow with local text processing and free, inspectable source.

**Pricing**

**Free ($0) to download and use. MIT licensed and open source.**

[Website and download](https://www.onekapisch.com/products/easy-write/) · [GitHub source](https://github.com/onekapisch/easy-write)

**Requirements and privacy**

Apple Silicon, macOS 26 or later, and Apple Intelligence enabled with its model ready. Accessibility permission is needed for selection and replacement; some text fields aren’t supported.

The 2.0.2 DMG is Developer-ID signed and Apple-notarized. Text processing runs on your Mac. History is local and opt-in; optional update checks and downloads contact the website and GitHub. [App privacy and data handling](https://github.com/onekapisch/easy-write/blob/main/SECURITY.md).

I used AI coding tools during development, and this post was drafted with AI assistance.

If you try it, I’d appreciate feedback on your app and language pair, especially whether selection, preview and replacement behave as expected.

## Review notes outside the post

- The work/language origin story comes from the owner's supplied draft. No extra personal
  anecdotes or measured time savings have been invented.
- Formal/informal shortcut slots exist but are optional; current defaults are Bar, Translate
  and Read. The post says they can be assigned rather than claiming default separate bindings.
- Removed universal app coverage, "no popup", the old ~600-line claim and unsupported
  competitor exclusivity. Current Swift source is substantially larger; a line count is
  unnecessary for the product pitch and is not a security guarantee.
- The [current rules](https://www.reddit.com/r/macapps/about/rules.json) require [OS] in the
  title, ten local karma, promotion frequency limits and main-feed qualification. This
  draft follows Problem/Comparison/Pricing; formatting alone does not establish eligibility.
- The [moderator guidance](https://www.reddit.com/r/macapps/comments/1ryaeex/rmacapps_mods_went_too_far_whats_changing_phase_3/)
  describes trust/transparency paths. If relying on transparency, include the required real
  identity/portfolio, LinkedIn/contact, privacy and Terms of Service information before posting.
  The public About page identifies Kapisch and support contact; a suitable LinkedIn link
  was not verified here. `https://www.onekapisch.com/terms/` returned HTTP 404 on 25 October.
  Do not invent a link or claim this draft meets that path. Other qualifying routes were not established.
- Follow the subreddit's [post-approval instructions](https://www.reddit.com/r/macapps/comments/1smg62t/how_to_gain_post_approval_in_rmacapps_with_read/)
  after reading the rules. This does not authorize an agent to acknowledge rules or send modmail.
- DeepL comparison checked against its [formality documentation](https://support.deepl.com/hc/en-us/articles/4406432804498-Use-the-formality-feature).
- AI disclosure is retained for transparency. The linked Phase 3 guidance dropped it from
  mandatory PCP formatting; do not import r/MacOSApps' different AI-disclosure rule here.
