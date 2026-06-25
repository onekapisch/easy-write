import AppKit

// Easy Write — system-wide, in-place translator.
// Menu-bar agent (no Dock icon). Entry point.

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)   // menu-bar only, no Dock icon
    app.run()                             // retains `delegate` for the app's lifetime
}
