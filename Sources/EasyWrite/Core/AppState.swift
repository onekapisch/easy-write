import AppKit
import ApplicationServices

/// Live state the UI reflects: permissions, model readiness, and whether a job is running.
/// Polled cheaply so the panel and the welcome window update the moment something changes
/// in System Settings, without the user having to reopen anything.
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    enum ModelStatus: Equatable {
        case ready, preparing, notEnabled, ineligible, unknown

        init(_ reason: LLMTranslator.Unavailable?) {
            switch reason {
            case .none:              self = .ready
            case .modelNotReady:     self = .preparing
            case .notEnabled:        self = .notEnabled
            case .deviceNotEligible: self = .ineligible
            case .other:             self = .unknown
            }
        }
    }

    @Published private(set) var accessibility = AXIsProcessTrusted()
    @Published private(set) var model = ModelStatus(LLMTranslator.shared.unavailableReason)
    @Published var busy = false

    var isReady: Bool { accessibility && model == .ready }

    private var timer: Timer?

    func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            Task { @MainActor in AppState.shared.refresh() }
        }
    }

    func refresh() {
        let ax = AXIsProcessTrusted()
        if ax != accessibility { accessibility = ax }
        let m = ModelStatus(LLMTranslator.shared.unavailableReason)
        if m != model { model = m }
    }

    /// Fixed state for `--snapshots`, so each surface can be rendered in every state.
    func simulate(accessibility: Bool, model: ModelStatus) {
        timer?.invalidate()
        self.accessibility = accessibility
        self.model = model
    }

    /// Asks macOS to show its Accessibility prompt, and opens the right Settings pane.
    func requestAccessibility() {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        Self.open("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    }

    func openAppleIntelligenceSettings() {
        Self.open("x-apple.systempreferences:com.apple.Siri-Settings.extension")
    }

    private static func open(_ s: String) {
        if let url = URL(string: s) { NSWorkspace.shared.open(url) }
    }
}
