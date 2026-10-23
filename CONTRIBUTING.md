# Contributing to Easy Write

Thanks for your interest! Easy Write is a focused native macOS app. Contributions that keep it fast,
private and simple are very welcome.

## Getting set up

```bash
./setup-signing.sh     # once, only if you don't have a Developer ID: a stable identity keeps Accessibility
./build.sh             # compile + bundle + sign → "Easy Write.app"
open "Easy Write.app"
```

Requires macOS 26+ on Apple Silicon with Apple Intelligence enabled. Read
[HOW_IT_WORKS.md](HOW_IT_WORKS.md) for an architecture tour before diving in.

## Checking your change

Three dev tools are built into the binary:

```bash
swift build -c release
./.build/release/EasyWrite --selftest            # text splitting, shared links, migration, search
./.build/release/EasyWrite --snapshots /tmp/ew    # renders every screen to PNG with sample data
./.build/release/EasyWrite --eval                 # scores translation quality (needs Apple Intelligence)
```

- Changing a prompt or a language? Run `--eval` before and after, and include both results in the PR.
- Changing the UI? Attach the relevant `--snapshots` images.
- `--selftest` must pass.

## Good first contributions

- More languages (add to `Core/Languages.swift`, then run `--eval` style checks for it)
- Useful built-in actions (`WriteAction.presets` in `Core/Models.swift`)
- VoiceOver and keyboard-navigation polish
- Translations of the app's own interface

## Guidelines

- **Private by default.** No analytics or telemetry. The only network access is Sparkle's update
  check; don't add more.
- **Keep it native and small.** System frameworks first; the only dependency is Sparkle.
- Match the existing style, and build with `swift build -c release` before opening a PR.
- One focused change per PR, with a clear description of what changes for the user.

## Reporting bugs

Open an issue with your macOS version, whether Apple Intelligence is ready, the app you were typing
in, and steps to reproduce. Easy Write collects no logs by design, so steps to reproduce are gold.
