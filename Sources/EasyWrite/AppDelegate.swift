import AppKit
import ApplicationServices
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        MainMenu.install()
        setupStatusItem()
        Store.shared.onShortcutsChange = { [weak self] in self?.registerHotKeys() }
        registerHotKeys()
        observeFrontmostApp()
        enableLoginItemOnFirstRun()
        AppState.shared.startMonitoring()
        UpdateController.shared.start()
        LLMTranslator.shared.prewarm()

        if !Store.shared.onboardingDone || !AXIsProcessTrusted() {
            WelcomeController.shared.show()
        }
    }

    /// `easywrite://action?d=…` from a shared action page.
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { ImportController.shared.handle(url) }
    }

    /// Opening the app again (Finder, Spotlight, Launchpad) shows the panel.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { PanelController.shared.show() }
        return true
    }

    // MARK: Status item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "character.bubble", accessibilityDescription: "Easy Write")
        button.target = self
        button.action = #selector(togglePanel)
        PanelController.shared.attach(to: button)
    }

    @objc private func togglePanel() { PanelController.shared.toggle() }
    @objc func showSettings() { SettingsController.shared.show() }
    @objc func showAbout() { SettingsController.shared.show(.about) }

    // MARK: Hot-keys

    func registerHotKeys() {
        let center = HotKeyCenter.shared
        center.unregisterAll()
        let store = Store.shared
        let runner = Runner.shared
        let slots: [(Store.Slot, () -> Void)] = [
            (.bar,       { runner.openBar() }),
            (.translate, { runner.translateSmart() }),
            (.read,      { runner.read() }),
            (.formal,    { runner.translate(tone: .formal) }),
            (.informal,  { runner.translate(tone: .informal) }),
            (.natural,   { runner.translate(tone: .natural) }),
        ]
        for (slot, run) in slots {
            if let s = store.shortcut(for: slot) { center.register(keyCode: s.keyCode, modifiers: s.modifiers, action: run) }
        }
        for action in store.actions {
            guard let s = action.shortcut else { continue }
            let id = action.id
            center.register(keyCode: s.keyCode, modifiers: s.modifiers) {
                if let a = Store.shared.actions.first(where: { $0.id == id }) { runner.run(a) }
            }
        }
    }

    // MARK: Frontmost app

    private func observeFrontmostApp() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appActivated(_:)),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
        if let front = NSWorkspace.shared.frontmostApplication, front.bundleIdentifier != Bundle.main.bundleIdentifier {
            Runner.shared.lastApp = front
        }
    }

    @objc private func appActivated(_ note: Notification) {
        if let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           app.bundleIdentifier != Bundle.main.bundleIdentifier {
            Runner.shared.lastApp = app
        }
    }

    // MARK: Launch at login

    private func enableLoginItemOnFirstRun() {
        let key = "didInitLoginItem"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        try? SMAppService.mainApp.register()
        UserDefaults.standard.set(true, forKey: key)
    }
}
