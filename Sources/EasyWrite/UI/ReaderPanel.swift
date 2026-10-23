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
        panel.contentView?.layoutSubtreeIfNeeded()
        let size = panel.contentView?.fittingSize ?? NSSize(width: 360, height: 200)
        var origin = NSPoint(x: point.x + 14, y: point.y - size.height - 14)
        let screen = NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) } ?? NSScreen.main
        if let vf = screen?.visibleFrame {
            origin.x = min(max(origin.x, vf.minX + 8), vf.maxX - size.width - 8)
            origin.y = min(max(origin.y, vf.minY + 8), vf.maxY - size.height - 8)
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
        let p = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 360, height: 200),
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
        let host = NSHostingView(rootView: ReaderCard(model: model, panel: self).padding(24))
        host.sizingOptions = [.intrinsicContentSize]
        p.contentView = host
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

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            header
            ScrollView {
                Text(model.text)
                    .font(.system(size: 14.5))
                    .foregroundStyle(Color(hex: 0xF3F1FA))
                    .lineSpacing(2)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxHeight: 300)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Button { panel?.copy() } label: { Label("Copy", systemImage: "doc.on.doc") }
                Button { panel?.toggleSpeak() } label: {
                    Label(model.speaking ? "Stop" : "Speak", systemImage: model.speaking ? "stop.fill" : "speaker.wave.2")
                }
                Button { panel?.replace() } label: { Label("Replace", systemImage: "arrow.turn.down.left") }
                    .disabled(!model.canReplace)
                if !model.canReplace {
                    Text("This text is read-only").font(.system(size: 10.5)).foregroundStyle(EW.faint)
                }
            }
            .buttonStyle(EWButtonStyle())
            .labelStyle(.titleAndIcon)

            if !model.original.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Button { withAnimation(.easeOut(duration: 0.15)) { model.showOriginal.toggle() } } label: {
                        HStack(spacing: 4) {
                            Text(model.showOriginal ? "Hide original" : "Show original")
                            Image(systemName: "chevron.right").rotationEffect(.degrees(model.showOriginal ? 90 : 0))
                        }
                        .font(.system(size: 11.5)).foregroundStyle(EW.dim)
                    }
                    .buttonStyle(.plain)
                    if model.showOriginal {
                        Text(model.original).font(.system(size: 12.5)).foregroundStyle(EW.dim)
                            .textSelection(.enabled).lineLimit(8)
                    }
                }
                .padding(.top, 9)
                .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1) }
            }
        }
        .padding(12)
        .frame(width: 360)
        .ewGlass()
    }

    private var header: some View {
        HStack(spacing: 7) {
            switch model.header {
            case .translation(let from, let to):
                if let from { chip(from); Text("→").foregroundStyle(EW.dim) }
                chip(to)
                if from != nil { Text("detected").font(.system(size: 10)).foregroundStyle(EW.faint) }
            case .action(let name):
                IconSquare(symbol: "sparkles", tint: EW.pink, size: 20)
                Text(name).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(EW.text)
            }
            Spacer()
            IconButton(symbol: model.pinned ? "pin.fill" : "pin", label: model.pinned ? "Unpin" : "Pin") { panel?.togglePin() }
            IconButton(symbol: "xmark", label: "Close") { panel?.close() }
        }
        .font(.system(size: 11.5))
        .foregroundStyle(EW.dim)
    }

    private func chip(_ s: String) -> some View {
        Text(s).font(.system(size: 11.5, weight: .semibold)).foregroundStyle(EW.text)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
