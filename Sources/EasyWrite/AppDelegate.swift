import AppKit
import ApplicationServices
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private let replacer = Replacer()
    private let llm = LLMTranslator()
    private let readerPanel = ReaderPanel()
    private var busy = false
    private weak var lastApp: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Store.shared.onChange = { [weak self] in self?.applySettingsChange() }
        setupStatusItem()
        registerHotKeys()
        observeFrontmostApp()
        enableLoginItemOnFirstRun()
        _ = ensureAccessibility(prompt: true)
        llm.prewarm()
    }

    private func applySettingsChange() {
        registerHotKeys()
        rebuildMenu()
    }

    // MARK: Status item / menu
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setIcon(busy: false)
        rebuildMenu()
    }

    private func setIcon(busy: Bool) {
        let symbol = busy ? "ellipsis.bubble" : "character.bubble"
        statusItem.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Easy Write")
    }

    private func flashIcon(_ symbol: String, revertAfter seconds: Double) {
        statusItem.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Easy Write")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self, !self.busy else { return }
            self.setIcon(busy: false)
        }
    }

    private var appVersion: String { (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "" }

    private func shortcutLabel(_ action: String) -> String {
        let sc = Store.shared.shortcut(for: action)
        return KeyDisplay.string(keyCode: sc.keyCode, modifiers: sc.modifiers)
    }

    private func rebuildMenu() {
        let lang = Languages.named(Store.shared.targetCode)
        let menu = NSMenu()

        let header = NSMenuItem(title: "Easy Write \(appVersion)", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        let formalSuffix = lang.formal.map { " (\($0))" } ?? ""
        let informalSuffix = lang.informal.map { " (\($0))" } ?? ""

        addItem(menu, "Formal – \(lang.name)\(formalSuffix)   \(shortcutLabel("formal"))", #selector(menuFormal))
        addItem(menu, "Informal – \(lang.name)\(informalSuffix)   \(shortcutLabel("informal"))", #selector(menuInformal))
        addItem(menu, "Plain – \(lang.name)   \(shortcutLabel("plain"))", #selector(menuPlain))
        addItem(menu, "Read → English   \(shortcutLabel("english"))", #selector(menuEnglish))
        menu.addItem(.separator())

        let langItem = NSMenuItem(title: "Target Language", action: nil, keyEquivalent: "")
        let langMenu = NSMenu()
        for l in Languages.all {
            let item = NSMenuItem(title: l.name, action: #selector(menuPickLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = l.code
            item.state = (l.code == lang.code) ? .on : .off
            langMenu.addItem(item)
        }
        langItem.submenu = langMenu
        menu.addItem(langItem)

        let previewItem = NSMenuItem(title: "Preview before replacing",
                                     action: #selector(togglePreview), keyEquivalent: "")
        previewItem.target = self
        previewItem.state = Store.shared.previewBeforeReplace ? .on : .off
        menu.addItem(previewItem)
        menu.addItem(.separator())

        let prefs = NSMenuItem(title: "Preferences…", action: #selector(menuPreferences), keyEquivalent: ",")
        prefs.target = self
        menu.addItem(prefs)

        let login = NSMenuItem(title: "Launch at Login",
                               action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        login.target = self
        login.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(login)

        addItem(menu, "Accessibility Settings…", #selector(menuAccessibility))
        menu.addItem(.separator())
        addItem(menu, "Quit Easy Write", #selector(menuQuit), key: "q")

        statusItem.menu = menu
    }

    private func addItem(_ menu: NSMenu, _ title: String, _ action: Selector, key: String = "") {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        menu.addItem(item)
    }

    // MARK: Hot-keys (read from Store; re-registered when settings change)
    private func registerHotKeys() {
        HotKeyCenter.shared.unregisterAll()
        register("formal")   { [weak self] in self?.translate(register: .formal) }
        register("informal") { [weak self] in self?.translate(register: .informal) }
        register("plain")    { [weak self] in self?.translate(register: nil) }
        register("english")  { [weak self] in self?.translate(register: nil, toEnglish: true) }
    }

    private func register(_ action: String, _ block: @escaping () -> Void) {
        let sc = Store.shared.shortcut(for: action)
        HotKeyCenter.shared.register(keyCode: sc.keyCode, modifiers: sc.modifiers, action: block)
    }

    private func observeFrontmostApp() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appActivated(_:)),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    @objc private func appActivated(_ note: Notification) {
        if let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           app.bundleIdentifier != Bundle.main.bundleIdentifier {
            lastApp = app
        }
    }

    // MARK: Launch at login
    private func enableLoginItemOnFirstRun() {
        let key = "didInitLoginItem"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        try? SMAppService.mainApp.register()
        UserDefaults.standard.set(true, forKey: key)
    }

    @objc func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            notify("Couldn’t change Launch at Login:\n\(error.localizedDescription)")
        }
        rebuildMenu()
    }

    // MARK: Actions
    @objc func menuFormal()   { translate(register: .formal) }
    @objc func menuInformal() { translate(register: .informal) }
    @objc func menuPlain()    { translate(register: nil) }
    @objc func menuEnglish()  { translate(register: nil, toEnglish: true) }
    @objc func menuPreferences() { PreferencesController.shared.show() }
    @objc func togglePreview() { Store.shared.previewBeforeReplace.toggle() }

    @objc func menuPickLanguage(_ sender: NSMenuItem) {
        guard let code = sender.representedObject as? String else { return }
        Store.shared.targetCode = code
    }

    private func translate(register: LLMTranslator.Register?, toEnglish: Bool = false) {
        guard !busy else { return }
        guard ensureAccessibility(prompt: true) else { return }
        guard llm.isAvailable else {
            notify("Apple Intelligence isn’t available. Enable it in System Settings → "
                   + "Apple Intelligence & Siri, then try again.")
            return
        }

        if NSApp.isActive, let prev = lastApp {
            prev.activate()
            usleep(120_000)
        }

        guard let text = replacer.copySelection(),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            NSSound.beep(); return
        }

        let language = toEnglish ? "English" : Languages.named(Store.shared.targetCode).name
        let style = Store.shared.styleGuide
        // Read mode (→ English) always shows a popup, since you're usually reading
        // non-editable text (web pages, emails, PDFs) where paste-back can't work.
        let usePopup = toEnglish || Store.shared.previewBeforeReplace
        let mouse = NSEvent.mouseLocation

        busy = true
        setIcon(busy: true)
        Task { @MainActor in
            defer { busy = false }
            do {
                let result = try await llm.translate(text, toLanguageNamed: language,
                                                     register: register, styleGuide: style)
                if result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    NSSound.beep(); flashIcon("exclamationmark.bubble", revertAfter: 1.0); return
                }
                if usePopup {
                    if toEnglish {
                        // reading: small popup next to the selection, non-modal
                        readerPanel.show(result, at: mouse)
                    } else {
                        // write-mode preview: confirm dialog with a Replace option
                        presentResult(result, allowReplace: true)
                    }
                    setIcon(busy: false)
                } else {
                    replacer.replaceSelection(with: result)
                    flashIcon("checkmark.bubble", revertAfter: 0.9)
                }
            } catch {
                NSSound.beep(); flashIcon("exclamationmark.bubble", revertAfter: 1.1)
            }
        }
    }

    /// Show the translation in a native dialog. For write modes (allowReplace) the user can
    /// paste it back; for read mode they can read/copy it.
    private func presentResult(_ text: String, allowReplace: Bool) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = allowReplace ? "Translation" : "Translation → English"
        alert.informativeText = text
        if allowReplace {
            alert.addButton(withTitle: "Replace")   // first
            alert.addButton(withTitle: "Copy")      // second
            alert.addButton(withTitle: "Cancel")    // third
        } else {
            alert.addButton(withTitle: "Copy")      // first
            alert.addButton(withTitle: "Done")      // second
        }
        let resp = alert.runModal()
        if allowReplace {
            if resp == .alertFirstButtonReturn {            // Replace
                if let prev = lastApp { prev.activate(); usleep(150_000) }
                replacer.replaceSelection(with: text)
            } else if resp == .alertSecondButtonReturn {    // Copy
                copyToClipboard(text)
            }
        } else if resp == .alertFirstButtonReturn {         // Copy
            copyToClipboard(text)
        }
    }

    private func copyToClipboard(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }

    @objc func menuAccessibility() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func menuQuit() { NSApp.terminate(nil) }

    // MARK: Helpers
    @discardableResult
    private func ensureAccessibility(prompt: Bool) -> Bool {
        let options = ["AXTrustedCheckOptionPrompt": prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private func notify(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Easy Write"
        alert.informativeText = message
        alert.runModal()
    }
}
