# Release-safety implementation plan

**Goal:** Fix clipboard, replacement and history blockers without publishing 2.0.
**Architecture:** Preserve the native app. Add narrow injectable system boundaries, reject
unverifiable paste targets, and make history an explicit, revocable choice.
**Stack:** SwiftPM, AppKit, Foundation Models, Combine.

- [x] Add isolated regression checks reproducing clipboard loss and implicit history consent.
- [x] Track pasteboard ownership and snapshot newer copies immediately before a temporary paste.
- [x] Capture the AX window, element, range and selected text. Recheck before delivery; otherwise
      show a copyable reader result. Do not claim a synthetic paste was confirmed.
- [x] Turn history off by default and migrate implicit enablement to off. Clear on disable,
      restrict file permissions, and prune while running and after wake.
- [x] Give streaming an actual deadline; test cancellation with a simulated stalled producer.
- [x] Budget instructions and glossary before chunking; reject oversized settings clearly.
- [x] Correct pre-release download claims and document website/release acceptance tasks.
- [x] Run release build, isolated regression suite, snapshots, real model smoke checks and
      independent code review. Leave external publishing and permission-gated acceptance explicit.
