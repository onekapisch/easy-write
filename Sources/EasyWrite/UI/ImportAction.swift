import AppKit

/// Handles `easywrite://action?d=…` links and pasted share links. A shared action is someone
/// else's instruction, so it is always shown in full before it is added, never gets a shortcut,
/// and starts in popup mode: it can't replace any text until the user switches it over.
@MainActor
final class ImportController {
    static let shared = ImportController()

    func handle(_ url: URL) {
        guard let action = ActionLink.decode(url) else {
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = "This link isn’t a valid Easy Write action"
            alert.informativeText = "It may be incomplete. Ask the person who shared it to copy the link again."
            alert.runModal()
            return
        }
        confirm(action)
    }

    private func confirm(_ action: WriteAction) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Add “\(action.name)” to Easy Write?"
        alert.informativeText = """
        It runs this instruction on text you select:

        “\(action.instruction)”

        It starts by showing results in a popup, so it never changes your text until you switch it to Replace in Settings → Actions.
        """
        alert.addButton(withTitle: "Add Action")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        var a = action
        if Store.shared.actions.contains(where: { $0.name == a.name }) { a.name += " (shared)" }
        Store.shared.actions.append(a)
        NotchHUD.shared.done("Action added", detail: a.name)
        SettingsController.shared.show(.actions, action: a.id)
    }
}

/// Easy Write runs without a Dock icon, but its windows still need standard editing
/// shortcuts (⌘C, ⌘V, ⌘Z, ⌘A). Those come from the main menu.
enum MainMenu {
    @MainActor static func install() {
        let main = NSMenu()

        let appItem = NSMenuItem()
        let app = NSMenu()
        app.addItem(withTitle: "About Easy Write", action: #selector(AppDelegate.showAbout), keyEquivalent: "")
        app.addItem(.separator())
        app.addItem(withTitle: "Settings…", action: #selector(AppDelegate.showSettings), keyEquivalent: ",")
        app.addItem(.separator())
        app.addItem(withTitle: "Quit Easy Write", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = app
        main.addItem(appItem)

        let editItem = NSMenuItem()
        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redo = edit.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        edit.addItem(.separator())
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = edit
        main.addItem(editItem)

        let windowItem = NSMenuItem()
        let window = NSMenu(title: "Window")
        window.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowItem.submenu = window
        main.addItem(windowItem)

        NSApp.mainMenu = main
    }
}
