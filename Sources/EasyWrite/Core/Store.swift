import Foundation
import SwiftUI

/// Single source of truth for user settings. ObservableObject so SwiftUI views bind to it.
@MainActor
final class Store: ObservableObject {
    /// Replaceable so `--snapshots` can render with sample data without touching real settings.
    static var shared = Store()

    private let d: UserDefaults

    /// Set by AppDelegate to re-register hot-keys when any shortcut changes.
    var onShortcutsChange: (() -> Void)?

    struct Shortcut: Codable, Equatable, Hashable {
        var keyCode: UInt32
        var modifiers: UInt32
        var label: String { KeyDisplay.string(keyCode: keyCode, modifiers: modifiers) }
    }

    /// Global shortcuts that aren't actions. Formal / informal / natural are optional direct
    /// shortcuts; new installs leave them empty and use the Bar or per-app memory instead.
    enum Slot: String, CaseIterable, Identifiable {
        case bar, translate, read, formal, informal, natural
        var id: String { rawValue }
        var title: String {
            switch self {
            case .bar:       "Open Easy Write Bar"
            case .translate: "Translate (both directions)"
            case .read:      "Read in your language"
            case .formal:    "Translate · Formal"
            case .informal:  "Translate · Informal"
            case .natural:   "Translate · Natural"
            }
        }
    }

    static let defaultShortcuts: [Slot: Shortcut] = [
        .bar:       .init(keyCode: 40, modifiers: KeyDisplay.option | KeyDisplay.cmd),  // ⌥⌘K
        .translate: .init(keyCode: 17, modifiers: KeyDisplay.option | KeyDisplay.cmd),  // ⌥⌘T
        .read:      .init(keyCode: 14, modifiers: KeyDisplay.option | KeyDisplay.cmd),  // ⌥⌘E
    ]

    // MARK: Settings
    @Published var targetCode: String { didSet { d.set(targetCode, forKey: K.target) } }
    @Published var homeCode: String { didSet { d.set(homeCode, forKey: K.home) } }
    @Published var defaultTone: Tone { didSet { d.set(defaultTone.rawValue, forKey: K.tone) } }
    @Published var previewBeforeReplace: Bool { didSet { d.set(previewBeforeReplace, forKey: K.preview) } }
    @Published var twoWay: Bool { didSet { d.set(twoWay, forKey: K.twoWay) } }
    @Published var rememberPerApp: Bool { didSet { d.set(rememberPerApp, forKey: K.perApp) } }
    @Published var appPreferences: [String: AppPreference] { didSet { save(appPreferences, K.appPrefs) } }
    @Published var glossary: [GlossaryTerm] { didSet { save(glossary, K.glossary) } }
    @Published var toneNotes: String { didSet { d.set(toneNotes, forKey: K.notes) } }
    @Published var actions: [WriteAction] {
        didSet {
            save(actions, K.actions)
            // Typing in the instruction editor saves on every keystroke; only re-register
            // hot-keys when an action's shortcut (or the set of actions) actually changed.
            if actions.map(\.shortcut) != oldValue.map(\.shortcut) || actions.map(\.id) != oldValue.map(\.id) {
                onShortcutsChange?()
            }
        }
    }
    @Published private(set) var shortcuts: [String: Shortcut] { didSet { save(shortcuts, K.shortcuts); onShortcutsChange?() } }
    @Published var historyEnabled: Bool { didSet { d.set(historyEnabled, forKey: K.historyOn) } }
    @Published var historyDays: Int { didSet { d.set(historyDays, forKey: K.historyDays) } }
    @Published var historyExcluded: [String] { didSet { save(historyExcluded, K.historyExcluded) } }
    @Published var onboardingDone: Bool { didSet { d.set(onboardingDone, forKey: K.onboarding) } }
    @Published private(set) var stats: UsageStats { didSet { save(stats, K.stats) } }

    private enum K {
        static let target = "targetLanguageCode", home = "homeLanguageCode", tone = "defaultTone"
        static let preview = "previewBeforeReplace", twoWay = "twoWay", perApp = "rememberPerApp"
        static let appPrefs = "appPreferences", glossary = "glossary", notes = "toneNotes"
        static let actions = "actions", shortcuts = "shortcutsV2", stats = "stats"
        static let historyOn = "historyEnabled", historyDays = "historyDays"
        static let historyExcluded = "historyExcluded", onboarding = "onboardingDone"
        static let migrated = "migratedFromV1"
    }

    /// Password managers and keychain tools: nothing copied from them is kept in History.
    static let defaultExcludedApps = [
        "com.apple.Passwords", "com.apple.keychainaccess", "com.1password.1password",
        "com.agilebits.onepassword7", "com.bitwarden.desktop", "in.sinew.Enpass-Desktop",
        "com.dashlane.dashlanephonefinal", "com.lastpass.LastPass",
    ]

    /// `legacy` is where 1.x kept its settings; the self-test passes a throwaway domain instead.
    init(defaults: UserDefaults = .standard,
         legacy: UserDefaults? = UserDefaults(suiteName: "com.easywrite.translator")) {
        d = defaults
        Self.migrateFromV1IfNeeded(into: defaults, from: legacy)

        targetCode = d.string(forKey: K.target) ?? "de"
        homeCode = d.string(forKey: K.home) ?? Self.systemLanguageCode()
        defaultTone = d.string(forKey: K.tone).flatMap(Tone.init) ?? .natural
        previewBeforeReplace = d.bool(forKey: K.preview)
        twoWay = d.object(forKey: K.twoWay) as? Bool ?? true
        rememberPerApp = d.object(forKey: K.perApp) as? Bool ?? true
        appPreferences = Self.load(d, K.appPrefs) ?? [:]
        glossary = Self.load(d, K.glossary) ?? []
        toneNotes = d.string(forKey: K.notes) ?? ""
        actions = Self.load(d, K.actions) ?? WriteAction.presets
        shortcuts = Self.load(d, K.shortcuts)
            ?? Dictionary(uniqueKeysWithValues: Self.defaultShortcuts.map { ($0.key.rawValue, $0.value) })
        historyEnabled = d.object(forKey: K.historyOn) as? Bool ?? true
        historyDays = d.object(forKey: K.historyDays) as? Int ?? 7
        historyExcluded = Self.load(d, K.historyExcluded) ?? Self.defaultExcludedApps
        onboardingDone = d.bool(forKey: K.onboarding)
        stats = Self.load(d, K.stats) ?? UsageStats()
    }

    // MARK: Shortcuts
    func shortcut(for slot: Slot) -> Shortcut? { shortcuts[slot.rawValue] }

    func setShortcut(_ s: Shortcut?, for slot: Slot) { shortcuts[slot.rawValue] = s }

    func setShortcut(_ s: Shortcut?, forAction id: UUID) {
        guard let i = actions.firstIndex(where: { $0.id == id }) else { return }
        actions[i].shortcut = s
    }

    /// Every assigned shortcut with what it does, used to warn about duplicates.
    var allAssignedShortcuts: [(Shortcut, String)] {
        Slot.allCases.compactMap { slot in shortcut(for: slot).map { ($0, slot.title) } }
            + actions.compactMap { a in a.shortcut.map { ($0, a.name) } }
    }

    func duplicateLabels() -> Set<String> {
        var seen: [Shortcut: Int] = [:]
        for (s, _) in allAssignedShortcuts { seen[s, default: 0] += 1 }
        return Set(seen.filter { $0.value > 1 }.map { $0.key.label })
    }

    // MARK: Per-app memory
    func preference(for bundleID: String?) -> AppPreference? {
        guard rememberPerApp, let id = bundleID else { return nil }
        return appPreferences[id]
    }

    func remember(code: String, tone: Tone, for bundleID: String?, appName: String) {
        guard rememberPerApp, let id = bundleID, id != Bundle.main.bundleIdentifier else { return }
        appPreferences[id] = AppPreference(code: code, tone: tone, appName: appName)
    }

    // MARK: Stats
    func recordUse(words: Int, language: String?, app bundleID: String?, replaced: Bool) {
        var s = stats
        if replaced { s.swaps += 1 }
        s.words += words
        if let language { s.languages.insert(language) }
        if let bundleID { s.apps.insert(bundleID) }
        stats = s
    }

    func resetStats() { stats = UsageStats() }

    // MARK: Persistence helpers
    private func save<T: Encodable>(_ value: T, _ key: String) {
        if let data = try? JSONEncoder().encode(value) { d.set(data, forKey: key) }
    }

    private static func load<T: Decodable>(_ d: UserDefaults, _ key: String) -> T? {
        guard let data = d.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// The Mac's preferred language if Easy Write supports it, otherwise English.
    static func systemLanguageCode() -> String {
        for id in Locale.preferredLanguages {
            let code = Locale(identifier: id).language.languageCode?.identifier ?? ""
            if Languages.all.contains(where: { $0.code == code }) { return code }
        }
        return "en"
    }

    /// 1.x stored its settings under the old bundle ID (com.easywrite.translator). Copy them
    /// across once. Old default shortcuts are not carried over: ⌥⌘T becomes the two-way
    /// translate key, and ⌥⌘I clashes with Chrome's developer tools. Shortcuts the user had
    /// changed themselves are kept in the matching optional slot.
    private static func migrateFromV1IfNeeded(into d: UserDefaults, from legacy: UserDefaults?) {
        guard !d.bool(forKey: K.migrated) else { return }
        d.set(true, forKey: K.migrated)
        guard let old = legacy,
              old.object(forKey: "targetLanguageCode") != nil || old.object(forKey: "shortcuts") != nil
        else { return }

        if let v = old.string(forKey: "targetLanguageCode") { d.set(v, forKey: K.target) }
        if old.object(forKey: "previewBeforeReplace") != nil {
            d.set(old.bool(forKey: "previewBeforeReplace"), forKey: K.preview)
        }
        if let v = old.string(forKey: "styleGuide"), !v.isEmpty { d.set(v, forKey: K.notes) }
        // "didInitLoginItem" is deliberately not copied: the login item belongs to the old app,
        // so the new one has to register itself on first launch.

        var map = Dictionary(uniqueKeysWithValues: defaultShortcuts.map { ($0.key.rawValue, $0.value) })
        if let data = old.data(forKey: "shortcuts"),
           let v1 = try? JSONDecoder().decode([String: Shortcut].self, from: data) {
            let v1Defaults: [String: Shortcut] = [
                "formal":   .init(keyCode: 17, modifiers: 2304),
                "informal": .init(keyCode: 34, modifiers: 2304),
                "plain":    .init(keyCode: 35, modifiers: 2304),
            ]
            if let read = v1["english"], !map.values.contains(read) { map[Slot.read.rawValue] = read }
            for (key, slot) in [("formal", Slot.formal), ("informal", .informal), ("plain", .natural)] {
                if let s = v1[key], s != v1Defaults[key], !map.values.contains(s) { map[slot.rawValue] = s }
            }
        }
        if let data = try? JSONEncoder().encode(map) { d.set(data, forKey: K.shortcuts) }
    }
}
