import AppKit
import SwiftUI

@MainActor
final class WelcomeController {
    static let shared = WelcomeController()
    static let windowID = NSUserInterfaceItemIdentifier("welcome")

    private var window: NSWindow?

    func show() {
        if window == nil {
            let host = NSHostingController(rootView: WelcomeView(state: .shared, store: .shared) { [weak self] in
                self?.window?.close()
            })
            let w = NSWindow(contentViewController: host)
            w.identifier = Self.windowID
            w.title = "Welcome to Easy Write"
            w.styleMask = [.titled, .closable, .fullSizeContentView]
            w.titlebarAppearsTransparent = true
            w.appearance = NSAppearance(named: .darkAqua)
            w.backgroundColor = NSColor(Color(hex: 0x1C1B22))
            w.isReleasedWhenClosed = false
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

struct WelcomeView: View {
    @ObservedObject var state: AppState
    @ObservedObject var store: Store
    var close: () -> Void

    @State private var practiced = false
    @State private var visited: Step?

    enum Step: Int, CaseIterable { case access = 1, model, practice }

    private var current: Step {
        if let visited { return visited }
        if !state.accessibility { return .access }
        if state.model != .ready { return .model }
        return .practice
    }

    var body: some View {
        HStack(spacing: 0) {
            steps
                .frame(width: 210)
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.white.opacity(0.02))
            Rectangle().fill(Color.white.opacity(0.06)).frame(width: 1)
            content
                .padding(.horizontal, 26).padding(.vertical, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 680, height: 440)
        .padding(.top, 20)                                  // clear the transparent title bar
        .background(Color(hex: 0x1C1B22))
        .environment(\.colorScheme, .dark)
        .onReceive(NotificationCenter.default.publisher(for: Runner.didReplace)) { _ in
            if NSApp.keyWindow?.identifier == WelcomeController.windowID { practiced = true }
        }
    }

    // MARK: Steps column

    private var steps: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                AppGlyph(size: 30)
                Wordmark(size: 15)
            }
            .padding(.horizontal, 10).padding(.bottom, 14).padding(.top, 6)
            stepRow(.access, "Accessibility", done: state.accessibility,
                    note: state.accessibility ? "Allowed" : "Needed to read your selection")
            stepRow(.model, "Apple Intelligence", done: state.model == .ready, note: modelNote)
            stepRow(.practice, "Try a swap", done: practiced, note: practiced ? "Done" : "Waiting for you")
        }
        .padding(14)
    }

    private var modelNote: String {
        switch state.model {
        case .ready:      "Ready on this Mac"
        case .preparing:  "Still downloading"
        case .notEnabled: "Turned off"
        case .ineligible: "Not supported here"
        case .unknown:    "Not available yet"
        }
    }

    private func stepRow(_ step: Step, _ title: String, done: Bool, note: String) -> some View {
        Button { visited = step } label: {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle().fill(done ? EW.good : step == current ? EW.accent : Color.white.opacity(0.1))
                    if done {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .heavy)).foregroundStyle(Color(hex: 0x04140C))
                    } else {
                        Text("\(step.rawValue)").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    }
                }
                .frame(width: 20, height: 20)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(EW.text)
                    Text(note).font(.system(size: 11)).foregroundStyle(EW.dim)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10).padding(.vertical, 9)
            .background {
                if step == current {
                    RoundedRectangle(cornerRadius: 9, style: .continuous).fill(EW.accent.opacity(0.18))
                        .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).strokeBorder(EW.accent.opacity(0.4)))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(done ? "done" : note)")
    }

    // MARK: Step content

    @ViewBuilder private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("STEP \(current.rawValue) OF 3").font(.system(size: 10.5, weight: .semibold)).tracking(0.8)
                .foregroundStyle(EW.accentText)
            switch current {
            case .access:   access
            case .model:    model
            case .practice: practice
            }
            Spacer(minLength: 0)
            footer
        }
    }

    private var access: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("Allow Accessibility")
            para("Easy Write copies the text you select and pastes the result back. macOS asks you to allow that once, in Privacy & Security → Accessibility.")
            if state.accessibility {
                statusLine("Allowed. You’re set.", color: EW.good)
            } else {
                Button("Open Accessibility Settings") { state.requestAccessibility() }
                    .buttonStyle(EWButtonStyle(kind: .primary))
                para("Already see Easy Write in the list from an older version? Remove it with the minus button, then add it again. This version is signed differently, so macOS treats it as a new app.")
                    .font(.system(size: 12))
                statusLine("Waiting for permission", color: EW.warn, pulsing: true)
            }
        }
    }

    private var model: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("Apple Intelligence")
            para("Easy Write uses the language model built into macOS. It runs on this Mac, so nothing you write is uploaded.")
            switch state.model {
            case .ready:
                statusLine("Ready on this Mac.", color: EW.good)
            case .preparing:
                para("It’s turned on and still downloading its model. This happens once and can take a while. It needs free storage and a network connection.")
                statusLine("Downloading", color: EW.warn, pulsing: true)
            case .notEnabled:
                Button("Open Apple Intelligence Settings") { state.openAppleIntelligenceSettings() }
                    .buttonStyle(EWButtonStyle(kind: .primary))
                statusLine("Turned off", color: EW.warn)
            case .ineligible:
                para("This Mac can’t run Apple Intelligence. It needs Apple Silicon (M1 or newer) and macOS 26.")
                statusLine("Not supported", color: EW.bad)
            case .unknown:
                Button("Open Apple Intelligence Settings") { state.openAppleIntelligenceSettings() }
                    .buttonStyle(EWButtonStyle(kind: .primary))
                statusLine("Not available yet", color: EW.warn)
            }
        }
    }

    private var practice: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("Try your first swap")
            let key = store.shortcut(for: .translate)?.label ?? "⌥⌘T"
            para("The sentence below is already selected. Press \(key), and Easy Write replaces it right here.")
            PracticeField(text: "Hey! Text me when you land.", selecting: "Text me when you land.")
                .frame(height: 64)
                .background(Color(hex: 0x121117), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Color.white.opacity(0.08)))
            HStack(spacing: 10) {
                Text("Into").font(.system(size: 12)).foregroundStyle(EW.dim)
                LanguageChip(code: $store.targetCode)
                ToneControl(tone: $store.defaultTone, lang: Languages.named(store.targetCode)).frame(width: 260)
            }
            if practiced {
                statusLine("That’s it. Select text anywhere and press \(key).", color: EW.good)
            }
        }
    }

    private var footer: some View {
        HStack {
            Button("Skip for now") { finish() }.buttonStyle(.plain).foregroundStyle(EW.dim).font(.system(size: 12))
            Spacer()
            if current == .practice {
                Button(practiced ? "Finish" : "Finish without trying") { finish() }
                    .buttonStyle(EWButtonStyle(kind: practiced ? .primary : .ghost))
            } else {
                Button("Next") { visited = Step(rawValue: current.rawValue + 1) }
                    .buttonStyle(EWButtonStyle(kind: .ghost))
            }
        }
        .padding(.top, 14)
        .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1) }
    }

    private func finish() {
        store.onboardingDone = true
        close()
        if practiced { DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { PanelController.shared.show() } }
    }

    // MARK: Text helpers

    private func title(_ s: String) -> some View {
        Text(s).font(.system(size: 21, weight: .bold)).foregroundStyle(EW.text)
    }

    private func para(_ s: String) -> some View {
        Text(s).font(.system(size: 13)).foregroundStyle(Color(hex: 0xA9A5BC)).lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func statusLine(_ s: String, color: Color, pulsing: Bool = false) -> some View {
        HStack(spacing: 8) {
            StatusDot(color: color).opacity(pulsing ? 0.9 : 1)
            Text(s).font(.system(size: 12.5, weight: .medium)).foregroundStyle(EW.text)
        }
    }
}

/// A real NSTextView, so the synthesised ⌘C / ⌘V of a normal swap work on it exactly as they
/// would in any other app.
struct PracticeField: NSViewRepresentable {
    let text: String
    let selecting: String

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = false
        let tv = scroll.documentView as! NSTextView
        tv.string = text
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = NSColor(Color(hex: 0xE9E7F2))
        tv.drawsBackground = false
        tv.isRichText = false
        tv.allowsUndo = true
        tv.textContainerInset = NSSize(width: 12, height: 12)
        tv.insertionPointColor = NSColor(EW.accent)
        tv.selectedTextAttributes = [.backgroundColor: NSColor(Color(hex: 0x5082FF, opacity: 0.45))]
        tv.setAccessibilityLabel("Practice text")
        DispatchQueue.main.async {
            if let r = text.range(of: selecting) { tv.setSelectedRange(NSRange(r, in: text)) }
            tv.window?.makeFirstResponder(tv)
        }
        return scroll
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {}
}
