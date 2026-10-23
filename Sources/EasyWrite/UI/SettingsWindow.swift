import AppKit
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

enum SettingsPage: String, CaseIterable, Identifiable {
    case general, languages, actions, shortcuts, glossary, history, updates, about, studio
    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:   "General"
        case .languages: "Languages"
        case .actions:   "Actions"
        case .shortcuts: "Shortcuts"
        case .glossary:  "Glossary"
        case .history:   "History & Privacy"
        case .updates:   "Updates"
        case .about:     "About"
        case .studio:    "Studio"
        }
    }

    /// Short label for the sidebar, which doesn't widen to fit longer titles.
    var sidebarTitle: String { self == .history ? "History" : title }

    var symbol: String {
        switch self {
        case .general:   "gearshape"
        case .languages: "globe"
        case .actions:   "sparkles"
        case .shortcuts: "keyboard"
        case .glossary:  "character.book.closed"
        case .history:   "clock.arrow.circlepath"
        case .updates:   "arrow.down.circle"
        case .about:     "info.circle"
        case .studio:    "sun.horizon"
        }
    }
}

final class SettingsNav: ObservableObject {
    @Published var page: SettingsPage? = .general
    @Published var actionID: UUID?
}

@MainActor
final class SettingsController {
    static let shared = SettingsController()
    let nav = SettingsNav()
    private var window: NSWindow?

    func show(_ page: SettingsPage? = nil, action: UUID? = nil) {
        if let page { nav.page = page }
        if let action { nav.actionID = action }
        if window == nil {
            let host = NSHostingController(rootView: SettingsView(nav: nav, store: .shared, history: .shared,
                                                                  updates: .shared, recorder: .shared))
            let w = NSWindow(contentViewController: host)
            w.title = "Easy Write Settings"
            w.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
            w.toolbarStyle = .unified
            w.isReleasedWhenClosed = false
            w.setContentSize(NSSize(width: 820, height: 560))
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

/// Records the next key combination. Global hot-keys are paused while recording, so pressing
/// a combination that's already in use assigns it instead of running it.
@MainActor
final class ShortcutRecorder: ObservableObject {
    static let shared = ShortcutRecorder()
    @Published private(set) var recordingID: String?
    private var monitor: Any?
    private var onRecord: ((Store.Shortcut) -> Void)?

    func toggle(_ id: String, onRecord: @escaping (Store.Shortcut) -> Void) {
        if recordingID == id { stop(); return }
        stop()
        recordingID = id
        self.onRecord = onRecord
        HotKeyCenter.shared.unregisterAll()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if event.keyCode == 53 { self.stop(); return nil }            // Esc cancels
            let mods = KeyDisplay.carbonModifiers(from: event.modifierFlags)
            guard mods & (KeyDisplay.cmd | KeyDisplay.option | KeyDisplay.control) != 0 else { NSSound.beep(); return nil }
            self.onRecord?(.init(keyCode: UInt32(event.keyCode), modifiers: mods))
            self.stop()
            return nil
        }
    }

    func stop() {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
        let wasRecording = recordingID != nil
        recordingID = nil
        onRecord = nil
        if wasRecording { Store.shared.onShortcutsChange?() }             // re-register hot-keys
    }
}

struct ShortcutField: View {
    let id: String
    let value: Store.Shortcut?
    var optional = true
    let set: (Store.Shortcut?) -> Void
    @ObservedObject var recorder: ShortcutRecorder = .shared

    var body: some View {
        HStack(spacing: 6) {
            Button {
                recorder.toggle(id) { set($0) }
            } label: {
                Text(recorder.recordingID == id ? "Press keys…" : value?.label ?? "Record shortcut")
                    .monospacedDigit()
                    .frame(minWidth: 120)
            }
            .help(recorder.recordingID == id ? "Press a key combination, or Esc to cancel" : "Click, then press a new key combination")
            if optional, value != nil {
                Button { set(nil) } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove shortcut")
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var nav: SettingsNav
    @ObservedObject var store: Store
    @ObservedObject var history: HistoryStore
    @ObservedObject var updates: UpdateController
    @ObservedObject var recorder: ShortcutRecorder

    var body: some View {
        NavigationSplitView {
            List(SettingsPage.allCases, selection: $nav.page) { page in
                Label(page.sidebarTitle, systemImage: page.symbol).tag(page)
            }
            .navigationSplitViewColumnWidth(215)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            Group {
                switch nav.page ?? .general {
                case .general:   GeneralPage(store: store)
                case .languages: LanguagesPage(store: store)
                case .actions:   ActionsPage(store: store, nav: nav)
                case .shortcuts: ShortcutsPage(store: store)
                case .glossary:  GlossaryPage(store: store)
                case .history:   HistoryPage(store: store, history: history)
                case .updates:   UpdatesPage(updates: updates)
                case .about:     AboutPage()
                case .studio:    StudioSettingsView()
                }
            }
            .navigationTitle((nav.page ?? .general).title)
        }
        .frame(minWidth: 820, minHeight: 560)
        .tint(EW.accent)                                    // toggles, pickers and selection in Easy Write violet
        .onDisappear { recorder.stop() }
    }
}

// MARK: - General

private struct GeneralPage: View {
    @ObservedObject var store: Store
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var loginError: String?

    var body: some View {
        Form {
            Section {
                Toggle("Open at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, on in setLogin(on) }
                if let loginError { Text(loginError).font(.caption).foregroundStyle(.red) }
                Toggle(isOn: $store.previewBeforeReplace) {
                    Text("Preview before replacing")
                    Text("Shortcuts open the Bar with the result ready, instead of replacing right away.")
                }
            }
            Section("Translate") {
                Toggle(isOn: $store.twoWay) {
                    Text("Translate both directions")
                    Text("If the text is already in \(Languages.named(store.targetCode).name), \(store.shortcut(for: .translate)?.label ?? "Translate") turns it into \(Languages.named(store.homeCode).name) instead.")
                }
                Toggle(isOn: $store.rememberPerApp) {
                    Text("Remember the tone for each app")
                    Text("The language and tone you pick in the Bar become the default for that app.")
                }
                if store.rememberPerApp && !store.appPreferences.isEmpty {
                    ForEach(store.appPreferences.sorted { $0.value.appName < $1.value.appName }, id: \.key) { id, pref in
                        LabeledContent(pref.appName) {
                            HStack {
                                Text("\(Languages.named(pref.code).name) · \(pref.tone.title)").foregroundStyle(.secondary)
                                Button { store.appPreferences[id] = nil } label: { Image(systemName: "minus.circle") }
                                    .buttonStyle(.borderless)
                                    .accessibilityLabel("Forget \(pref.appName)")
                            }
                        }
                    }
                }
            }
            Section {
                Button("Show the welcome window") { WelcomeController.shared.show() }
                Button("Reset the counters in the panel") { store.resetStats() }
            }
        }
        .formStyle(.grouped)
    }

    private func setLogin(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            loginError = nil
        } catch {
            loginError = "Couldn’t change this: \(error.localizedDescription)"
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

// MARK: - Languages

private struct LanguagesPage: View {
    @ObservedObject var store: Store

    var body: some View {
        Form {
            Section("Translate into") {
                Picker("Language", selection: $store.targetCode) {
                    ForEach(Languages.all) { Text($0.name).tag($0.code) }
                }
                Picker("Tone", selection: $store.defaultTone) {
                    ForEach(Tone.allCases) { t in
                        let p = t.pronoun(in: Languages.named(store.targetCode))
                        Text(p.map { "\(t.title) (\($0))" } ?? t.title).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                Text("Natural keeps the tone of the text you selected. Formal and Informal set it, for example Sie or du in German.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Your language") {
                Picker("Your language", selection: $store.homeCode) {
                    ForEach(Languages.all) { Text($0.name).tag($0.code) }
                }
                Text("Read mode translates into this language, and two-way translate turns text back into it.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Actions

private struct ActionsPage: View {
    @ObservedObject var store: Store
    @ObservedObject var nav: SettingsNav
    @State private var importText = ""
    @State private var importError: String?
    @State private var copiedID: UUID?

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                List(selection: $nav.actionID) {
                    ForEach(store.actions) { a in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(a.name).fontWeight(.medium)
                                Spacer()
                                if let s = a.shortcut { Text(s.label).font(.caption).foregroundStyle(.secondary).monospacedDigit() }
                            }
                            Text(a.output == .replace ? "In place" : "Popup").font(.caption).foregroundStyle(.secondary)
                        }
                        .tag(a.id)
                        .padding(.vertical, 2)
                    }
                    .onMove { store.actions.move(fromOffsets: $0, toOffset: $1) }
                }
                Divider()
                HStack(spacing: 4) {
                    Button { addAction() } label: { Image(systemName: "plus") }.accessibilityLabel("New action")
                    Button { deleteSelected() } label: { Image(systemName: "minus") }
                        .disabled(nav.actionID == nil).accessibilityLabel("Delete action")
                    Spacer()
                    Menu("More") {
                        Button("Restore the built-in actions") { restorePresets() }
                    }
                    .menuStyle(.borderlessButton).fixedSize()
                }
                .buttonStyle(.borderless)
                .padding(8)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add a shared action").font(.caption).foregroundStyle(.secondary)
                    HStack {
                        TextField("Paste a link", text: $importText).textFieldStyle(.roundedBorder)
                        Button("Add") { importLink() }.disabled(importText.isEmpty)
                    }
                    if let importError { Text(importError).font(.caption).foregroundStyle(.red) }
                }
                .padding(.horizontal, 8).padding(.bottom, 10)
            }
            .frame(width: 250)
            Divider()
            editor.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { if nav.actionID == nil { nav.actionID = store.actions.first?.id } }
    }

    @ViewBuilder private var editor: some View {
        if let id = nav.actionID, let i = store.actions.firstIndex(where: { $0.id == id }) {
            Form {
                Section {
                    TextField("Name", text: $store.actions[i].name)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Instruction")
                        TextEditor(text: $store.actions[i].instruction)
                            .font(.body)
                            .frame(minHeight: 110)
                            .scrollContentBackground(.hidden)
                            .padding(6)
                            .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color(nsColor: .separatorColor)))
                        Text("Written like you’d ask a person. It runs on the text you select, on this Mac.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Picker("Result", selection: $store.actions[i].output) {
                        ForEach(WriteAction.Output.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    LabeledContent("Shortcut") {
                        ShortcutField(id: "action-\(id)", value: store.actions[i].shortcut) { store.setShortcut($0, forAction: id) }
                    }
                }
                Section {
                    HStack {
                        Button { share(store.actions[i]) } label: { Label("Share action", systemImage: "link") }
                        if copiedID == id { Text("Link copied").font(.caption).foregroundStyle(.secondary) }
                    }
                    Text("Copies a link to a page on onekapisch.com that shows this action, with a button to add it to Easy Write. The action travels inside the link; nothing is uploaded.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
        } else {
            ContentUnavailableView("No action selected", systemImage: "sparkles",
                                   description: Text("Pick one on the left, or add a new one."))
        }
    }

    private func addAction() {
        let a = WriteAction(name: "New action", instruction: "Describe what to do with the selected text.",
                            output: .popup, shortcut: nil)
        store.actions.append(a)
        nav.actionID = a.id
    }

    private func deleteSelected() {
        guard let id = nav.actionID, let i = store.actions.firstIndex(where: { $0.id == id }) else { return }
        store.actions.remove(at: i)
        nav.actionID = store.actions.indices.contains(i) ? store.actions[i].id : store.actions.last?.id
    }

    private func restorePresets() {
        let names = Set(store.actions.map(\.name))
        let used = Set(store.allAssignedShortcuts.map(\.0))
        for var p in WriteAction.presets where !names.contains(p.name) {
            if let s = p.shortcut, used.contains(s) { p.shortcut = nil }
            store.actions.append(p)
        }
    }

    private func share(_ a: WriteAction) {
        guard let url = ActionLink.shareURL(for: a) else { return }
        Runner.shared.replacer.copyForUser(url.absoluteString)
        copiedID = a.id
    }

    private func importLink() {
        guard let url = URL(string: importText.trimmingCharacters(in: .whitespacesAndNewlines)),
              ActionLink.decode(url) != nil else {
            importError = "That isn’t an Easy Write action link."
            return
        }
        importError = nil
        importText = ""
        ImportController.shared.handle(url)
    }
}

// MARK: - Shortcuts

private struct ShortcutsPage: View {
    @ObservedObject var store: Store

    var body: some View {
        Form {
            Section("Easy Write") {
                ForEach(Store.Slot.allCases) { slot in
                    LabeledContent(slot.title) {
                        ShortcutField(id: "slot-\(slot.rawValue)", value: store.shortcut(for: slot),
                                      optional: true) { store.setShortcut($0, for: slot) }
                    }
                }
            }
            Section("Actions") {
                ForEach(store.actions) { a in
                    LabeledContent(a.name) {
                        ShortcutField(id: "action-\(a.id)", value: a.shortcut) { store.setShortcut($0, forAction: a.id) }
                    }
                }
            }
            let dupes = store.duplicateLabels()
            if !dupes.isEmpty {
                Section {
                    Label("\(dupes.sorted().joined(separator: ", ")) is used more than once. Only one of them will work.",
                          systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }
            Section {
                Text("Shortcuts work in every app. Pick combinations other apps don’t use: ⌥⌘I, for example, opens the developer tools in Chrome.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Glossary

private struct GlossaryPage: View {
    @ObservedObject var store: Store

    var body: some View {
        Form {
            Section {
                ForEach($store.glossary) { $term in
                    HStack {
                        TextField("Word", text: $term.source).labelsHidden()
                        Image(systemName: "arrow.right").foregroundStyle(.secondary)
                        TextField("Always write", text: $term.target).labelsHidden()
                        Button { store.glossary.removeAll { $0.id == term.id } } label: { Image(systemName: "minus.circle") }
                            .buttonStyle(.borderless).accessibilityLabel("Remove term")
                    }
                }
                Button { store.glossary.append(GlossaryTerm(source: "", target: "")) } label: {
                    Label("Add term", systemImage: "plus")
                }
            } header: {
                Text("Terms")
            } footer: {
                Text("Easy Write uses these exact words in every translation and action. Good for product names, job titles, and words you spell your own way, like E-Mail → Mail.")
            }
            Section {
                TextEditor(text: $store.toneNotes)
                    .frame(minHeight: 110)
                    .font(.body)
            } header: {
                Text("Style notes")
            } footer: {
                Text("Anything else about how you write, e.g. “Keep it short. I’m a software engineer writing to colleagues.”")
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - History & Privacy

private struct HistoryPage: View {
    @ObservedObject var store: Store
    @ObservedObject var history: HistoryStore
    @State private var search = ""

    private var filtered: [HistoryEntry] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return history.entries }
        return history.entries.filter {
            $0.source.lowercased().contains(q) || $0.result.lowercased().contains(q)
                || $0.label.lowercased().contains(q) || $0.appName.lowercased().contains(q)
        }
    }

    var body: some View {
        Form {
            Section {
                Toggle("Save originals and results on this Mac", isOn: $store.historyEnabled)
                Picker("Keep for", selection: $store.historyDays) {
                    Text("1 day").tag(1); Text("7 days").tag(7); Text("30 days").tag(30)
                }
                .onChange(of: store.historyDays) { _, _ in history.prune() }
                .disabled(!store.historyEnabled)
                Text("Off by default. Enabling this stores original text and results as local, unencrypted history. Turning it off deletes that history. At most \(HistoryStore.maxEntries) results.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Never keep text from") {
                ForEach(store.historyExcluded, id: \.self) { id in
                    HStack {
                        Text(Self.appName(id) ?? id).foregroundStyle(Self.appName(id) == nil ? .secondary : .primary)
                        Spacer()
                        Button { store.historyExcluded.removeAll { $0 == id } } label: { Image(systemName: "minus.circle") }
                            .buttonStyle(.borderless).accessibilityLabel("Remove")
                    }
                }
                Button { addExcludedApp() } label: { Label("Add app", systemImage: "plus") }
            }
            Section {
                if filtered.isEmpty {
                    Text(history.entries.isEmpty ? "Nothing yet." : "No matches.").foregroundStyle(.secondary)
                }
                ForEach(filtered) { e in HistoryRow(entry: e, history: history) }
            } header: {
                HStack {
                    Text("Recent")
                    Spacer()
                    TextField("Search", text: $search).textFieldStyle(.roundedBorder).frame(width: 180)
                    Button("Clear all") { history.clear() }.disabled(history.entries.isEmpty)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func addExcludedApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.prompt = "Exclude"
        guard panel.runModal() == .OK, let url = panel.url, let id = Bundle(url: url)?.bundleIdentifier,
              !store.historyExcluded.contains(id) else { return }
        store.historyExcluded.append(id)
    }

    static func appName(_ bundleID: String) -> String? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        return FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: "")
    }
}

private struct HistoryRow: View {
    let entry: HistoryEntry
    @ObservedObject var history: HistoryStore

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.label).fontWeight(.medium)
                Text("· \(entry.appName) · \(entry.date.formatted(.relative(presentation: .named)))")
                    .foregroundStyle(.secondary)
                Spacer()
                Button { Runner.shared.replacer.copyForUser(entry.result) } label: { Image(systemName: "doc.on.doc") }
                    .buttonStyle(.borderless).help("Copy result").accessibilityLabel("Copy result")
                Button { history.remove(entry.id) } label: { Image(systemName: "trash") }
                    .buttonStyle(.borderless).help("Delete").accessibilityLabel("Delete")
            }
            .font(.callout)
            Text(entry.source).font(.callout).foregroundStyle(.secondary).lineLimit(2)
            Text(entry.result).lineLimit(3).textSelection(.enabled)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Updates

private struct UpdatesPage: View {
    @ObservedObject var updates: UpdateController

    var body: some View {
        Form {
            Section {
                if updates.available {
                    Toggle("Check for updates automatically", isOn: Binding(
                        get: { updates.automaticallyChecks }, set: { updates.automaticallyChecks = $0 }))
                    LabeledContent("Last checked") {
                        Text(updates.lastCheck?.formatted(date: .abbreviated, time: .shortened) ?? "Never")
                    }
                    Button("Check now") { updates.checkNow() }
                } else {
                    Text("This source build does not check for updates. Pull the latest code and run build.sh. Signed downloads are being prepared for the 2.0 release.")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Privacy") {
                Text("Optional update checks contact onekapisch.com without your text. Opening a Studio or support link visits that website in your browser. Translation and rewriting stay on your Mac.")
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - About

private struct AboutPage: View {
    var body: some View {
        VStack(spacing: 14) {
            AppGlyph(size: 72)
            Text("Easy Write").font(.system(size: 24, weight: .bold))
            Text("Version \(MenuPanelView.version)").foregroundStyle(.secondary)
            Text("Translate and rewrite text anywhere on your Mac, 100% on-device.")
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                Link("onekapisch.com", destination: URL(string: "https://www.onekapisch.com/products/easy-write/")!)
                Link("Source on GitHub", destination: URL(string: "https://github.com/onekapisch/easy-write")!)
            }
            Text("Support: support@onekapisch.com").textSelection(.enabled).foregroundStyle(.secondary)
            Text("Free and open source under the MIT License. Made by OneKapisch in Germany.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
