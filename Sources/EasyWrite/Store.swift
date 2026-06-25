import Foundation
import SwiftUI

/// Single source of truth for user settings. ObservableObject so SwiftUI prefs bind to it.
@MainActor
final class Store: ObservableObject {
    static let shared = Store()
    private let d = UserDefaults.standard

    /// Set by AppDelegate to re-register hot-keys / rebuild the menu when settings change.
    var onChange: (() -> Void)?

    struct Shortcut: Codable, Equatable { var keyCode: UInt32; var modifiers: UInt32 }

    static let defaultShortcuts: [String: Shortcut] = [
        "formal":   .init(keyCode: 17, modifiers: 2304),  // ⌥⌘T
        "informal": .init(keyCode: 34, modifiers: 2304),  // ⌥⌘I
        "plain":    .init(keyCode: 35, modifiers: 2304),  // ⌥⌘P
        "english":  .init(keyCode: 14, modifiers: 2304),  // ⌥⌘E
    ]

    @Published var targetCode: String { didSet { d.set(targetCode, forKey: "targetLanguageCode"); onChange?() } }
    @Published var previewBeforeReplace: Bool { didSet { d.set(previewBeforeReplace, forKey: "previewBeforeReplace"); onChange?() } }
    @Published var styleGuide: String { didSet { d.set(styleGuide, forKey: "styleGuide") } }
    @Published private var shortcuts: [String: Shortcut] { didSet { saveShortcuts(); onChange?() } }

    private init() {
        targetCode = d.string(forKey: "targetLanguageCode") ?? "de"
        previewBeforeReplace = d.bool(forKey: "previewBeforeReplace")
        styleGuide = d.string(forKey: "styleGuide") ?? ""
        if let data = d.data(forKey: "shortcuts"),
           let decoded = try? JSONDecoder().decode([String: Shortcut].self, from: data) {
            var merged = Store.defaultShortcuts
            for (k, v) in decoded { merged[k] = v }
            shortcuts = merged
        } else {
            shortcuts = Store.defaultShortcuts
        }
    }

    var targetLanguage: Locale.Language { Locale.Language(identifier: targetCode) }

    func shortcut(for action: String) -> Shortcut {
        shortcuts[action] ?? Store.defaultShortcuts[action] ?? .init(keyCode: 17, modifiers: 2304)
    }

    func setShortcut(_ s: Shortcut, for action: String) { shortcuts[action] = s }

    private func saveShortcuts() {
        if let data = try? JSONEncoder().encode(shortcuts) { d.set(data, forKey: "shortcuts") }
    }
}
