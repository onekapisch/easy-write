import AppKit
import CoreGraphics

/// Grabs the current selection (synthesised ⌘C), and replaces it (synthesised ⌘V).
/// Requires Accessibility permission to post events to other apps.
@MainActor
final class Replacer {
    private let pasteboard = NSPasteboard.general
    private var saved: [NSPasteboardItem] = []
    // .privateState => our synthetic events ignore physically-held modifier keys
    private let source = CGEventSource(stateID: .privateState)

    /// Copies the current selection and returns it as a string (or nil if nothing copied).
    func copySelection() -> String? {
        saved = snapshot()
        let before = pasteboard.changeCount
        usleep(60_000)              // let the hot-key modifiers release first
        postCmd(virtualKey: 8)      // 8 = C
        var text: String?
        for _ in 0..<60 {           // poll up to ~0.6s
            usleep(10_000)
            if pasteboard.changeCount != before {
                text = pasteboard.string(forType: .string)
                break
            }
        }
        return text
    }

    /// Replaces the current selection with `newText`, then restores the clipboard.
    func replaceSelection(with newText: String) {
        pasteboard.clearContents()
        pasteboard.setString(newText, forType: .string)
        usleep(20_000)
        postCmd(virtualKey: 9)      // 9 = V
        let restore = saved
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self else { return }
            self.pasteboard.clearContents()
            if !restore.isEmpty { self.pasteboard.writeObjects(restore) }
        }
    }

    private func postCmd(virtualKey: CGKeyCode) {
        let down = CGEvent(keyboardEventSource: source, virtualKey: virtualKey, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: source, virtualKey: virtualKey, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    private func snapshot() -> [NSPasteboardItem] {
        var items: [NSPasteboardItem] = []
        for item in pasteboard.pasteboardItems ?? [] {
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) { copy.setData(data, forType: type) }
            }
            items.append(copy)
        }
        return items
    }
}
