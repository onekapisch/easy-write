import AppKit

// Easy Write — system-wide, in-place translator.
// Menu-bar agent (no Dock icon). Entry point.

// Isolated, synthetic launch artwork. Never starts the app delegate or reads a selection.
if let i = CommandLine.arguments.firstIndex(of: "--launch-assets") {
    let args = CommandLine.arguments
    guard args.count > i + 1 else { fputs("Expected an output directory\n", stderr); exit(2) }
    _ = MainActor.assumeIsolated { NSApplication.shared.setActivationPolicy(.accessory) }
    Task { @MainActor in
        do { try await LaunchAssets.run(to: args[i + 1]); exit(0) }
        catch { fputs("Asset export failed: \(error)\n", stderr); exit(1) }
    }
    // SwiftUI's display-link updates need AppKit's event loop for animation capture.
    NSApplication.shared.run()
}

// Dev tool: `EasyWrite --eval` scores translation quality offline instead of launching the app.
// See Eval.swift. Kept in the shipped binary on purpose so contributors can verify that a
// language or prompt change actually helps, rather than eyeballing a handful of sentences.
if CommandLine.arguments.contains("--eval") {
    Task { @MainActor in
        await Eval.run()
        exit(0)
    }
    RunLoop.main.run()
}

// Dev tool: `EasyWrite --selftest` checks text splitting, shared links, migration and search.
if CommandLine.arguments.contains("--selftest") {
    Task { @MainActor in exit(await SelfTest.run()) }
    RunLoop.main.run()
}

if CommandLine.arguments.contains("--smoketest") {
    Task { @MainActor in exit(await SmokeTest.run()) }
    RunLoop.main.run()
}

// Dev tool: `EasyWrite --snapshots <dir>` renders every UI surface with sample data to PNGs.
if let i = CommandLine.arguments.firstIndex(of: "--snapshots") {
    let args = CommandLine.arguments
    let dir = args.count > i + 1 ? args[i + 1] : FileManager.default.currentDirectoryPath + "/snapshots"
    _ = MainActor.assumeIsolated {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
    Task { @MainActor in
        await Snapshots.run(to: dir)
        exit(0)
    }
    RunLoop.main.run()
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)   // menu-bar only, no Dock icon
    app.run()                             // retains `delegate` for the app's lifetime
}
