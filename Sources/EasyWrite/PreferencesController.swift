import AppKit
import SwiftUI

/// Captures the next key combo for a given action (shortcut recorder).
@MainActor
final class Recorder: ObservableObject {
    @Published var recordingAction: String?
    private var monitor: Any?
    private let store: Store

    init(store: Store) { self.store = store }

    func toggle(_ action: String) {
        if recordingAction == action { stop(); return }
        stop()
        recordingAction = action
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if event.keyCode == 53 { self.stop(); return nil }            // Esc cancels
            let mods = KeyDisplay.carbonModifiers(from: event.modifierFlags)
            guard mods != 0 else { return nil }                           // require a modifier
            self.store.setShortcut(.init(keyCode: UInt32(event.keyCode), modifiers: mods), for: action)
            self.stop()
            return nil
        }
    }

    func stop() {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
        recordingAction = nil
    }
}

@MainActor
final class PreferencesController {
    static let shared = PreferencesController()
    private var window: NSWindow?
    private lazy var recorder = Recorder(store: Store.shared)

    func show() {
        if let w = window {
            NSApp.activate(ignoringOtherApps: true)
            w.makeKeyAndOrderFront(nil)
            return
        }
        let view = PreferencesView(store: Store.shared, recorder: recorder)
        let hosting = NSHostingController(rootView: view)
        let w = NSWindow(contentViewController: hosting)
        w.title = "Easy Write Preferences"
        w.styleMask = [.titled, .closable]
        w.isReleasedWhenClosed = false
        window = w
        NSApp.activate(ignoringOtherApps: true)
        w.center()
        w.makeKeyAndOrderFront(nil)
    }
}

struct PreferencesView: View {
    @ObservedObject var store: Store
    @ObservedObject var recorder: Recorder

    private let actions: [(key: String, title: String)] = [
        ("formal", "Formal"), ("informal", "Informal"),
        ("plain", "Plain"), ("english", "Read → English"),
    ]

    var body: some View {
        Form {
            Section("Behaviour") {
                Picker("Target language", selection: $store.targetCode) {
                    ForEach(Languages.all) { Text($0.name).tag($0.code) }
                }
                Toggle("Preview before replacing", isOn: $store.previewBeforeReplace)
            }

            Section("Style & glossary") {
                Text("Applied to every translation so it sounds like you — preferred terms, tone, who you are. E.g. “Use ‘Mail’ not ‘E-Mail’. Keep it concise. I’m a software engineer.”")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $store.styleGuide)
                    .font(.body)
                    .frame(minHeight: 110)
            }

            Section("Shortcuts") {
                ForEach(actions, id: \.key) { action in
                    HStack {
                        Text(action.title)
                        Spacer()
                        let sc = store.shortcut(for: action.key)
                        Button(recorder.recordingAction == action.key
                               ? "Press keys…  (Esc to cancel)"
                               : KeyDisplay.string(keyCode: sc.keyCode, modifiers: sc.modifiers)) {
                            recorder.toggle(action.key)
                        }
                        .frame(minWidth: 170)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 560)
        .onDisappear { recorder.stop() }
    }
}
