import AppKit
import SwiftUI

/// Small, non-modal floating popup shown next to the selection for read mode (→ English).
/// Doesn't steal focus or block the app you're reading.
@MainActor
final class ReaderPanel {
    private var panel: NSPanel?
    private var dismissTask: Task<Void, Never>?

    func show(_ text: String, at screenPoint: NSPoint) {
        close()
        let hosting = NSHostingController(rootView: ReaderHUDView(
            text: text,
            onCopy: { [weak self] in
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.setString(text, forType: .string)
                self?.close()
            },
            onDone: { [weak self] in self?.close() }
        ))

        let panel = NSPanel(contentViewController: hosting)
        panel.styleMask = [.titled, .closable, .utilityWindow, .nonactivatingPanel]
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = true     // controls work without stealing focus
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.isMovableByWindowBackground = true

        // Position just below-right of the cursor, clamped to the screen.
        let size = panel.frame.size
        var origin = NSPoint(x: screenPoint.x + 14, y: screenPoint.y - size.height - 14)
        let screen = NSScreen.screens.first { $0.frame.contains(screenPoint) } ?? NSScreen.main
        if let vf = screen?.visibleFrame {
            origin.x = min(max(origin.x, vf.minX + 8), vf.maxX - size.width - 8)
            origin.y = min(max(origin.y, vf.minY + 8), vf.maxY - size.height - 8)
        }
        panel.setFrameOrigin(origin)
        self.panel = panel
        panel.orderFrontRegardless()            // show without activating our app

        // Auto-dismiss after a while in case it's left open.
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            self.close()
        }
    }

    func close() {
        dismissTask?.cancel(); dismissTask = nil
        panel?.orderOut(nil)
        panel = nil
    }
}

struct ReaderHUDView: View {
    let text: String
    let onCopy: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "character.bubble.fill").foregroundStyle(.tint)
                Text("English").font(.caption).foregroundStyle(.secondary)
            }
            Text(text)
                .font(.system(size: 14))
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                Button("Copy", action: onCopy)
                Button("Done", action: onDone).keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 320)
    }
}
