import AppKit
import SwiftUI

/// The panel under the menu-bar icon. Replaces the 1.x NSMenu.
@MainActor
final class PanelController: NSObject {
    static let shared = PanelController()

    private let popover = NSPopover()
    private weak var button: NSStatusBarButton?

    func attach(to button: NSStatusBarButton) {
        self.button = button
        popover.behavior = .transient
        popover.animates = true
        popover.appearance = NSAppearance(named: .vibrantDark)
        let host = NSHostingController(rootView: MenuPanelView(store: .shared, state: .shared,
                                                               history: .shared, updates: .shared))
        host.sizingOptions = .preferredContentSize
        popover.contentViewController = host
    }

    func toggle() { popover.isShown ? close() : show() }

    func show() {
        guard let button else { return }
        AppState.shared.refresh()
        // Activating lets the popover close on an outside click. Runner hands focus back to the
        // previous app before it copies anything.
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    func close() { if popover.isShown { popover.performClose(nil) } }

    /// Closes the panel, then runs `work` once focus is back where it was.
    func dismiss(then work: @escaping () -> Void) {
        close()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 120_000_000)
            work()
        }
    }
}

struct MenuPanelView: View {
    @ObservedObject var store: Store
    @ObservedObject var state: AppState
    @ObservedObject var history: HistoryStore
    @ObservedObject var updates: UpdateController

    private var target: Lang { Languages.named(store.targetCode) }
    private var home: Lang { Languages.named(store.homeCode) }

    var body: some View {
        VStack(spacing: 10) {
            header
            stats
            primary
            languageCard
            tiles
            footer
        }
        .padding(12)
        .frame(width: EW.panelWidth)
        .environment(\.colorScheme, .dark)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 10) {
            AppGlyph(size: 34)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    StatusDot(color: status.color)
                    Text(status.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(EW.text)
                }
                Text("Easy Write \(Self.version) · Apple Intelligence")
                    .font(.system(size: 11.5)).foregroundStyle(EW.accentText)
            }
            .accessibilityElement(children: .combine)
            Spacer()
            Text("Free")
                .font(.system(size: 10.5, weight: .semibold)).foregroundStyle(EW.good)
                .padding(.horizontal, 7).padding(.vertical, 3)
                .background(EW.good.opacity(0.14), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(EW.good.opacity(0.28)))
        }
        .padding(.horizontal, 2).padding(.top, 2)
    }

    private var status: (title: String, color: Color) {
        if !state.accessibility { return ("Needs Accessibility", EW.bad) }
        switch state.model {
        case .preparing:  return ("Preparing Apple Intelligence", EW.warn)
        case .notEnabled: return ("Apple Intelligence is off", EW.warn)
        case .ineligible: return ("This Mac can’t run it", EW.bad)
        case .unknown:    return ("Apple Intelligence unavailable", EW.warn)
        case .ready:      return state.busy ? ("Working…", EW.accent) : ("Ready · On-device", EW.good)
        }
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat(store.stats.swaps, "swaps")
            divider
            stat(store.stats.words, "words")
            divider
            stat(store.stats.languages.count, store.stats.languages.count == 1 ? "language" : "languages")
            divider
            stat(store.stats.apps.count, store.stats.apps.count == 1 ? "app" : "apps")
        }
        .padding(.vertical, 9)
        .ewCard()
    }

    private func stat(_ n: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(n.formatted()).font(.system(size: 15, weight: .semibold)).monospacedDigit().foregroundStyle(EW.text)
                .contentTransition(.numericText())
            Text(label).font(.system(size: 10.5)).foregroundStyle(EW.dim)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var divider: some View { Rectangle().fill(Color.white.opacity(0.07)).frame(width: 1, height: 26) }

    // MARK: Primary card (or the fix for whatever is blocking)

    @ViewBuilder private var primary: some View {
        if !state.accessibility {
            fixCard(title: "Allow Accessibility", detail: "Easy Write can’t read your selection yet.",
                    button: "Allow", tint: EW.bad) { state.requestAccessibility() }
        } else if state.model == .preparing || state.model == .notEnabled || state.model == .unknown {
            fixCard(title: state.model == .notEnabled ? "Turn on Apple Intelligence" : "Apple Intelligence is preparing",
                    detail: state.model == .notEnabled ? "It runs Easy Write, entirely on this Mac."
                                                       : "The model is still downloading. This only happens once.",
                    button: "Open", tint: EW.warn) { state.openAppleIntelligenceSettings() }
        } else {
            Button { PanelController.shared.dismiss { Runner.shared.openBar() } } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").font(.system(size: 17, weight: .semibold))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Open Easy Write Bar").font(.system(size: 13.5, weight: .semibold))
                        Text("Translate or rewrite the selection").font(.system(size: 11)).opacity(0.78)
                    }
                    Spacer()
                    if let s = store.shortcut(for: .bar) { Keycap(text: s.label, onAccent: true) }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 11)
                .background(LinearGradient(colors: [Color(hex: 0x7E60FF), EW.accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color.white.opacity(0.18)))
                .shadow(color: EW.accent.opacity(0.38), radius: 12, y: 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(state.model == .ineligible)
        }
    }

    private func fixCard(title: String, detail: String, button: String, tint: Color, action: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            IconSquare(symbol: tint == EW.bad ? "lock.fill" : "hourglass", tint: tint, size: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(EW.text)
                Text(detail).font(.system(size: 11)).foregroundStyle(EW.dim).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 6)
            Button(button, action: action).buttonStyle(EWButtonStyle(kind: .primary))
        }
        .padding(11)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(tint.opacity(0.3)))
    }

    // MARK: Language card

    private var languageCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Translate into").font(.system(size: 12)).foregroundStyle(EW.dim)
                Spacer()
                LanguageChip(code: $store.targetCode)
            }
            ToneControl(tone: $store.defaultTone, lang: target)
            remembered
        }
        .padding(10)
        .ewCard()
    }

    @ViewBuilder private var remembered: some View {
        let prefs = store.appPreferences.values.sorted { $0.appName < $1.appName }
        if store.rememberPerApp {
            if prefs.isEmpty {
                Text("Pick a tone in the Bar and Easy Write remembers it for that app.")
                    .font(.system(size: 11)).foregroundStyle(EW.dim).fixedSize(horizontal: false, vertical: true)
            } else {
                HStack(spacing: 6) {
                    Text("Remembered").font(.system(size: 11)).foregroundStyle(EW.dim)
                    ForEach(prefs.prefix(2), id: \.appName) { p in
                        Text("\(p.appName) · \(p.tone.title)").font(.system(size: 11)).foregroundStyle(EW.text.opacity(0.85))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 5))
                            .lineLimit(1)
                    }
                    if prefs.count > 2 { Text("+\(prefs.count - 2)").font(.system(size: 11)).foregroundStyle(EW.dim) }
                }
            }
        }
    }

    // MARK: Tiles

    private var tiles: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
            tile("Translate", symbol: "globe", tint: EW.accentText,
                 key: store.shortcut(for: .translate)?.label, line: store.twoWay ? "both directions" : "into \(target.name)") {
                PanelController.shared.dismiss { Runner.shared.translateSmart() }
            }
            tile("Read", symbol: "eye", tint: EW.blue,
                 key: store.shortcut(for: .read)?.label, line: "into \(home.name)") {
                PanelController.shared.dismiss { Runner.shared.read() }
            }
            tile("Actions", symbol: "sparkles", tint: EW.pink, key: nil,
                 line: store.actions.count == 1 ? "1 saved" : "\(store.actions.count) saved") {
                PanelController.shared.dismiss { SettingsController.shared.show(.actions) }
            }
            tile("History", symbol: "clock", tint: EW.good, key: nil, line: historyLine) {
                PanelController.shared.dismiss { SettingsController.shared.show(.history) }
            }
        }
    }

    private var historyLine: String {
        guard store.historyEnabled else { return "Off" }
        guard let last = history.entries.first else { return "Nothing yet" }
        return "Used " + RelativeDateTimeFormatter().localizedString(for: last.date, relativeTo: Date())
    }

    private func tile(_ title: String, symbol: String, tint: Color, key: String?, line: String,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    IconSquare(symbol: symbol, tint: tint)
                    Text(title).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(EW.text)
                }
                HStack(spacing: 5) {
                    if let key { Keycap(text: key, size: 10) }
                    Text(line).font(.system(size: 11)).foregroundStyle(EW.dim).lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .ewCard()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Footer

    private var footer: some View {
        HStack {
            Wordmark()
            Spacer()
            HStack(spacing: 6) {
                if updates.available {
                    IconButton(symbol: "arrow.down.circle", label: "Check for updates") { updates.checkNow() }
                }
                IconButton(symbol: "slider.horizontal.3", label: "Settings") {
                    PanelController.shared.dismiss { SettingsController.shared.show() }
                }
                IconButton(symbol: "power", label: "Quit Easy Write") { NSApp.terminate(nil) }
            }
        }
        .padding(.horizontal, 2).padding(.top, 9)
        .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1) }
    }

    static var version: String { (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "2.0" }
}

/// "DE German ▾" chip that opens a native menu of languages.
struct LanguageChip: View {
    @Binding var code: String

    var body: some View {
        Button {
            let menu = NSMenu()
            for lang in Languages.all {
                let item = NSMenuItem(title: lang.name, action: nil, keyEquivalent: "")
                item.state = lang.code == code ? .on : .off
                item.representedObject = lang.code
                item.target = MenuTarget.shared
                item.action = #selector(MenuTarget.pick(_:))
                menu.addItem(item)
            }
            MenuTarget.shared.onPick = { code = $0 }
            menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        } label: {
            HStack(spacing: 6) {
                LangBadge(code: code)
                Text(Languages.named(code).name).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(EW.text)
                Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold)).foregroundStyle(EW.dim)
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Translate into \(Languages.named(code).name)")
        .accessibilityHint("Opens a list of languages")
    }
}

@MainActor
final class MenuTarget: NSObject {
    static let shared = MenuTarget()
    var onPick: ((String) -> Void)?
    @objc func pick(_ sender: NSMenuItem) {
        if let code = sender.representedObject as? String { onPick?(code) }
    }
}
