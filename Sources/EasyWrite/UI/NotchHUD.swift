import AppKit
import SwiftUI

/// Progress and results shown where the eyes already are: a black pill that grows out of the
/// MacBook notch, or a floating pill under the menu bar on displays without one.
@MainActor
final class NotchHUD {
    static let shared = NotchHUD()

    enum Phase: Equatable {
        case working(title: String, detail: String?)
        case done(title: String, detail: String?, keycap: String?, hint: String?)
        case problem(message: String, keycap: String?, hint: String?)
    }

    final class Model: ObservableObject {
        @Published var phase: Phase = .working(title: "", detail: nil)
        @Published var expanded = false
        var hasNotch = true
        var notchWidth: CGFloat = 190
        var topInset: CGFloat = 32
    }

    static let contentHeight: CGFloat = 40
    static let expandedWidth: CGFloat = 370

    private var panel: NSPanel?
    private let model = Model()
    private var hideTask: Task<Void, Never>?

    func working(_ title: String, detail: String? = nil) {
        show(.working(title: title, detail: detail), hideAfter: nil)
    }

    func done(_ title: String, detail: String? = nil, keycap: String? = nil, hint: String? = nil) {
        show(.done(title: title, detail: detail, keycap: keycap, hint: hint), hideAfter: 1.8)
        announce([title, detail].compactMap { $0 }.joined(separator: ", "))
    }

    func problem(_ message: String, keycap: String? = nil, hint: String? = nil) {
        show(.problem(message: message, keycap: keycap, hint: hint), hideAfter: 3.2)
        announce(message)
    }

    func hide() {
        hideTask?.cancel()
        guard panel?.isVisible == true else { return }
        withAnimation(Self.animation) { model.expanded = false }
        hideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 380_000_000)
            guard !Task.isCancelled else { return }
            self.panel?.orderOut(nil)
        }
    }

    // MARK: Private

    private static var animation: Animation {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(response: 0.36, dampingFraction: 0.8)
    }

    private func show(_ phase: Phase, hideAfter: Double?) {
        hideTask?.cancel()
        let wasVisible = panel?.isVisible == true && model.expanded
        let panel = panel ?? makePanel()
        if !wasVisible { position(panel) }
        model.phase = phase
        panel.orderFrontRegardless()
        if !wasVisible {
            model.expanded = false
            DispatchQueue.main.async { withAnimation(Self.animation) { self.model.expanded = true } }
        }
        if let seconds = hideAfter {
            hideTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                guard !Task.isCancelled else { return }
                self.hide()
            }
        }
    }

    private func makePanel() -> NSPanel {
        let p = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.ignoresMouseEvents = true
        p.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 1)
        p.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        p.appearance = NSAppearance(named: .darkAqua)
        p.contentView = NSHostingView(rootView: HUDView(model: model))
        panel = p
        return p
    }

    /// Sits flush against the top of the screen the mouse is on, centred on the notch.
    private func position(_ panel: NSPanel) {
        let mouse = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(mouse, $0.frame, false) }) ?? NSScreen.main
        else { return }
        let inset = screen.safeAreaInsets.top
        model.hasNotch = inset > 0
        if model.hasNotch, let l = screen.auxiliaryTopLeftArea, let r = screen.auxiliaryTopRightArea {
            model.notchWidth = screen.frame.width - l.width - r.width
            model.topInset = inset
        } else {
            model.notchWidth = 120
            model.topInset = NSStatusBar.system.thickness + 6
        }
        let width = Self.expandedWidth + 60                 // room for the shadow
        let height = model.topInset + Self.contentHeight + 40
        panel.setFrame(NSRect(x: screen.frame.midX - width / 2, y: screen.frame.maxY - height,
                              width: width, height: height), display: false)
    }

    private func announce(_ text: String) {
        NSAccessibility.post(element: NSApp as Any, notification: .announcementRequested,
                             userInfo: [.announcement: text,
                                        .priority: NSAccessibilityPriorityLevel.high.rawValue])
    }
}

/// The pill itself. Collapsed it matches the notch exactly, so expanding reads as the notch
/// itself growing.
struct HUDView: View {
    @ObservedObject var model: NotchHUD.Model

    var body: some View {
        let expanded = model.expanded
        let width = expanded ? NotchHUD.expandedWidth : model.notchWidth
        let height: CGFloat = model.hasNotch
            ? (expanded ? model.topInset + NotchHUD.contentHeight : model.topInset)
            : (expanded ? NotchHUD.contentHeight + 6 : 8)
        let shape = model.hasNotch
            ? AnyShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20, style: .continuous))
            : AnyShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                shape.fill(Color.black.opacity(model.hasNotch ? 1 : 0.92))
                HUDContent(phase: model.phase)
                    .padding(.horizontal, 16)
                    .padding(.bottom, model.hasNotch ? 10 : 9)
                    .opacity(expanded ? 1 : 0)
                    .scaleEffect(expanded ? 1 : 0.9, anchor: .top)
            }
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(expanded ? 0.35 : 0), radius: 14, y: 8)
            .padding(.top, model.hasNotch ? 0 : NSStatusBar.system.thickness + 4)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct HUDContent: View {
    let phase: NotchHUD.Phase

    var body: some View {
        HStack(spacing: 10) {
            switch phase {
            case .working(let title, let detail):
                AppGlyph(size: 20)
                titleLine(title, detail)
                Spacer(minLength: 8)
                Shimmer()
            case .done(let title, let detail, let keycap, let hint):
                badge("checkmark", fill: EW.good, ink: Color(hex: 0x04140C))
                titleLine(title, detail)
                Spacer(minLength: 8)
                trailing(keycap, hint)
            case .problem(let message, let keycap, let hint):
                badge("exclamationmark", fill: EW.warn, ink: Color(hex: 0x1E1400))
                Text(message).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 8)
                trailing(keycap, hint)
            }
        }
        .frame(height: 22)
    }

    private func titleLine(_ title: String, _ detail: String?) -> some View {
        HStack(spacing: 5) {
            Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
            if let detail { Text("· \(detail)").font(.system(size: 12)).foregroundStyle(EW.dim) }
        }
        .lineLimit(1)
    }

    private func badge(_ symbol: String, fill: Color, ink: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 10, weight: .heavy))
            .foregroundStyle(ink)
            .frame(width: 18, height: 18)
            .background(fill, in: Circle())
            .accessibilityHidden(true)
    }

    @ViewBuilder private func trailing(_ keycap: String?, _ hint: String?) -> some View {
        HStack(spacing: 6) {
            if let keycap { Keycap(text: keycap, size: 10.5) }
            if let hint { Text(hint).font(.system(size: 11.5)).foregroundStyle(Color(hex: 0xA9A5BC)) }
        }
        .lineLimit(1)
    }
}
