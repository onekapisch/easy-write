import AppKit
import AVFoundation
import SwiftUI

/// Floating card next to the selection for read mode and popup actions.
/// Doesn't steal focus from the app you're reading, so Replace can paste straight back.
@MainActor
final class ReaderPanel {
    static let shared = ReaderPanel()

    enum Header: Equatable {
        case translation(from: String?, to: String)
        case action(String)
    }

    final class Model: ObservableObject {
        @Published var header: Header = .translation(from: nil, to: "English")
        @Published var text = ""
        @Published var original = ""
        @Published var speechCode = "en"
        @Published var canReplace = false
        @Published var pinned = false
        @Published var speaking = false
        @Published var showOriginal = false
    }

    /// Room around the card for its shadow.
    static let margin: CGFloat = 24

    private var panel: NSPanel?
    private let model = Model()
    private var dismissTask: Task<Void, Never>?
    private let speech = AVSpeechSynthesizer()
    private var speechDelegate: SpeechDelegate?
    private var onReplace: (() -> Void)?

    func show(_ text: String, original: String, header: Header, speechCode: String,
              canReplace: Bool, at point: NSPoint, onReplace: @escaping () -> Void) {
        stopSpeaking()
        model.header = header
        model.text = text
        model.original = original
        model.speechCode = speechCode
        model.canReplace = canReplace
        model.pinned = false
        model.showOriginal = false
        self.onReplace = onReplace

        let panel = panel ?? makePanel()
        // A fresh hosting view measures the new text right away. Reusing the old one reported
        // the previous result's size, which is what cut long translations off mid-sentence.
        let host = NSHostingView(rootView: ReaderCard(model: model, panel: self).padding(Self.margin))
        panel.contentView = host
        let size = host.fittingSize
        var origin = NSPoint(x: point.x + 14 - Self.margin, y: point.y - size.height - 10 + Self.margin)
        let screen = NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) } ?? NSScreen.main
        if let vf = screen?.visibleFrame {
            origin.x = min(max(origin.x, vf.minX + 8 - Self.margin), vf.maxX - size.width - 8 + Self.margin)
            origin.y = min(max(origin.y, vf.minY + 8 - Self.margin), vf.maxY - size.height - 8 + Self.margin)
        }
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
        panel.orderFrontRegardless()
        scheduleDismiss()
    }

    func close() {
        dismissTask?.cancel()
        stopSpeaking()
        panel?.orderOut(nil)
    }

    // MARK: Actions from the card

    fileprivate func copy() {
        Runner.shared.replacer.copyForUser(model.text)
        NotchHUD.shared.done("Copied")
        close()
    }

    fileprivate func replace() {
        close()
        onReplace?()
    }

    fileprivate func togglePin() {
        model.pinned.toggle()
        if model.pinned { dismissTask?.cancel() } else { scheduleDismiss() }
    }

    /// Grows or shrinks the card around the original text, keeping its top edge where it is.
    fileprivate func toggleOriginal() {
        model.showOriginal.toggle()
        DispatchQueue.main.async { [weak self] in
            guard let self, let panel = self.panel, let host = panel.contentView else { return }
            host.layoutSubtreeIfNeeded()
            let size = host.fittingSize
            let top = panel.frame.maxY
            panel.setFrame(NSRect(x: panel.frame.minX, y: top - size.height, width: size.width, height: size.height),
                           display: true, animate: !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion)
        }
    }

    fileprivate func toggleSpeak() {
        if model.speaking { stopSpeaking(); return }
        let utterance = AVSpeechUtterance(string: model.text)
        // The user's own regional voice when it matches (en-GB for a British Mac), otherwise the
        // system default voice for the language.
        let current = AVSpeechSynthesisVoice.currentLanguageCode()
        utterance.voice = AVSpeechSynthesisVoice(language: current.hasPrefix(model.speechCode) ? current : model.speechCode)
        let delegate = SpeechDelegate { [weak self] in self?.model.speaking = false }
        speechDelegate = delegate
        speech.delegate = delegate
        model.speaking = true
        dismissTask?.cancel()                       // don't vanish mid-sentence
        speech.speak(utterance)
    }

    private func stopSpeaking() {
        if speech.isSpeaking { speech.stopSpeaking(at: .immediate) }
        model.speaking = false
    }

    private func scheduleDismiss() {
        dismissTask?.cancel()
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 45_000_000_000)
            guard !Task.isCancelled, !self.model.pinned, !self.model.speaking else { return }
            self.close()
        }
    }

    private func makePanel() -> NSPanel {
        let p = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 420, height: 200),
                        styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        p.isFloatingPanel = true
        p.becomesKeyOnlyIfNeeded = true             // buttons work without stealing focus
        p.hidesOnDeactivate = false
        p.level = .floating
        p.isMovableByWindowBackground = true
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.appearance = NSAppearance(named: .darkAqua)
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel = p
        return p
    }
}

private final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let onFinish: () -> Void
    init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish u: AVSpeechUtterance) { DispatchQueue.main.async(execute: onFinish) }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel u: AVSpeechUtterance) { DispatchQueue.main.async(execute: onFinish) }
}

struct ReaderCard: View {
    @ObservedObject var model: ReaderPanel.Model
    let panel: ReaderPanel?

    static let width: CGFloat = 384
    private static let inset: CGFloat = 16
    private static let maxTextHeight: CGFloat = 300
    private static let font = NSFont.systemFont(ofSize: 15)
    private static let lineSpacing: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, Self.inset).padding(.top, 13).padding(.bottom, 11)
            result
                .padding(.horizontal, Self.inset)
            if model.showOriginal {
                original
                    .padding(.horizontal, Self.inset).padding(.top, 12)
                    .transition(.opacity)
            }
            footer
                .padding(.top, 14)
        }
        .frame(width: Self.width)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(hex: 0x19181F, opacity: 0.97))
        )
        // One thin brand line along the top edge: the card's only flourish.
        .overlay(alignment: .top) {
            LinearGradient(colors: [EW.accent.opacity(0), EW.accent.opacity(0.9), EW.pink.opacity(0.75), EW.pink.opacity(0)],
                           startPoint: .leading, endPoint: .trailing)
                .frame(height: 1.5)
                .padding(.horizontal, 26)
        }
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.white.opacity(0.08)))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.5), radius: 24, y: 12)
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityTitle)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 9) {
            AppGlyph(size: 20)
            switch model.header {
            case .translation(let from, let to):
                HStack(spacing: 6) {
                    if let from {
                        Text(from).foregroundStyle(EW.dim)
                        Image(systemName: "arrow.right").font(.system(size: 9, weight: .bold)).foregroundStyle(EW.faint)
                    }
                    Text(to).foregroundStyle(EW.text).fontWeight(.semibold)
                }
                .font(.system(size: 12.5))
                .lineLimit(1)
            case .action(let name):
                Text(name).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(EW.text).lineLimit(1)
            }
            Spacer(minLength: 8)
            HStack(spacing: 2) {
                HeaderButton(symbol: model.pinned ? "pin.fill" : "pin", label: model.pinned ? "Unpin" : "Keep on screen",
                             active: model.pinned) { panel?.togglePin() }
                HeaderButton(symbol: "xmark", label: "Close") { panel?.close() }
            }
        }
    }

    // MARK: Result

    /// Measured, not guessed: short results sit at their natural height, long ones scroll
    /// inside the card instead of being cut off.
    @ViewBuilder private var result: some View {
        let height = Self.textHeight(model.text, width: Self.width - Self.inset * 2)
        let textView = Text(model.text)
            .font(.system(size: 15))
            .lineSpacing(Self.lineSpacing)
            .foregroundStyle(Color(hex: 0xF4F2FA))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        if height > Self.maxTextHeight {
            ScrollView { textView }.frame(height: Self.maxTextHeight)
        } else {
            textView
        }
    }

    static func textHeight(_ s: String, width: CGFloat) -> CGFloat {
        let p = NSMutableParagraphStyle()
        p.lineSpacing = lineSpacing
        let r = (s as NSString).boundingRect(with: NSSize(width: width, height: .greatestFiniteMagnitude),
                                             options: [.usesLineFragmentOrigin, .usesFontLeading],
                                             attributes: [.font: font, .paragraphStyle: p])
        return ceil(r.height) + 4
    }

    private var original: some View {
        HStack(alignment: .top, spacing: 10) {
            Capsule().fill(EW.accent.opacity(0.7)).frame(width: 2)
            Text(model.original)
                .font(.system(size: 13))
                .lineSpacing(2)
                .foregroundStyle(EW.dim)
                .textSelection(.enabled)
                .lineLimit(8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Original: \(model.original)")
    }

    // MARK: Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)
            HStack(spacing: 6) {
                CardButton(title: "Copy", symbol: "doc.on.doc", primary: true) { panel?.copy() }
                CardButton(title: model.speaking ? "Stop" : "Speak",
                           symbol: model.speaking ? "stop.fill" : "speaker.wave.2.fill") { panel?.toggleSpeak() }
                if model.canReplace {
                    CardButton(title: "Replace", symbol: "arrow.turn.down.left") { panel?.replace() }
                }
                Spacer(minLength: 8)
                if !model.original.isEmpty {
                    Button { panel?.toggleOriginal() } label: {
                        HStack(spacing: 4) {
                            Text(model.showOriginal ? "Hide original" : "Original")
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .rotationEffect(.degrees(model.showOriginal ? 180 : 0))
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(EW.dim)
                        .fixedSize()
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(model.showOriginal ? "Hide original text" : "Show original text")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }

    private var accessibilityTitle: String {
        switch model.header {
        case .translation(let from, let to): "Translation\(from.map { " from \($0)" } ?? "") into \(to)"
        case .action(let name): name
        }
    }
}

/// Compact pill: one line, never wraps, sized to its label.
private struct CardButton: View {
    let title: String
    let symbol: String
    var primary = false
    let action: () -> Void
    @State private var hover = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol).font(.system(size: 11, weight: .semibold))
                Text(title).font(.system(size: 12, weight: .semibold))
            }
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(primary ? Color.white : EW.text)
            .padding(.horizontal, 11).padding(.vertical, 6)
            .background(
                Capsule().fill(primary ? AnyShapeStyle(LinearGradient(colors: [Color(hex: 0x8A6BFF), EW.accentDeep],
                                                                       startPoint: .top, endPoint: .bottom))
                                       : AnyShapeStyle(Color.white.opacity(hover ? 0.12 : 0.07)))
            )
            .overlay(Capsule().strokeBorder(Color.white.opacity(primary ? 0.18 : 0.06)))
            .shadow(color: primary ? EW.accent.opacity(0.4) : .clear, radius: 6, y: 2)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
        .accessibilityLabel(title)
    }
}

/// Small icon-only control for the card header.
private struct HeaderButton: View {
    let symbol: String
    let label: String
    var active = false
    let action: () -> Void
    @State private var hover = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(active ? EW.accentText : EW.dim)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.white.opacity(hover || active ? 0.09 : 0)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
        .help(label)
        .accessibilityLabel(label)
    }
}
