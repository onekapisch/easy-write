import AppKit

// Easy Write — system-wide, in-place translator.
// Menu-bar agent (no Dock icon). Entry point.

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
    exit(MainActor.assumeIsolated { SelfTest.run() })
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
