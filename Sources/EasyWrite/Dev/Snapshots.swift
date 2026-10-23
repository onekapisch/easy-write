import AppKit
import SwiftUI

/// Dev tool: `EasyWrite --snapshots <dir>` renders every surface with sample data to PNGs, so
/// UI changes can be reviewed without clicking through the app. Uses a throwaway settings
/// domain and a temporary history folder; real settings and history are never touched.
@MainActor
enum Snapshots {
    static func run(to dir: String) async {
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        let suite = "com.onekapisch.easywrite.snapshots"
        UserDefaults.standard.removePersistentDomain(forName: suite)
        let store = Store(defaults: UserDefaults(suiteName: suite)!, legacy: nil)
        Store.shared = store
        store.targetCode = "de"
        store.homeCode = "en"
        store.defaultTone = .informal
        store.historyEnabled = true // synthetic sample data only
        store.appPreferences = [
            "com.apple.mail": .init(code: "de", tone: .formal, appName: "Mail"),
            "com.tinyspeck.slackmacgap": .init(code: "de", tone: .informal, appName: "Slack"),
        ]
        store.glossary = [GlossaryTerm(source: "E-Mail", target: "Mail"), GlossaryTerm(source: "Kunde", target: "Klient")]
        store.toneNotes = "Keep it short. I’m a product designer writing to colleagues."
        for i in 0..<212 {
            store.recordUse(words: 23, language: ["de", "fr", "es", "ja"][i % 4], app: "app\(i % 9)", replaced: true)
        }

        let history = HistoryStore(directory: FileManager.default.temporaryDirectory
            .appendingPathComponent("easywrite-snapshots-\(UUID().uuidString)"))
        history.add(HistoryEntry(date: Date().addingTimeInterval(-130), kind: .translate, label: "German · Informal",
                                 appName: "Slack", source: "Can you send me your address before Friday?",
                                 result: "Kannst du mir deine Adresse vor Freitag schicken?"), bundleID: "com.tinyspeck.slackmacgap")
        history.add(HistoryEntry(date: Date().addingTimeInterval(-3_600), kind: .action, label: "Fix grammar",
                                 appName: "Mail", source: "Thank you for you're quick reply, I will looking at it tomorow.",
                                 result: "Thank you for your quick reply. I will look at it tomorrow."), bundleID: "com.apple.mail")

        let ready = AppState(); ready.simulate(accessibility: true, model: .ready)
        let noAccess = AppState(); noAccess.simulate(accessibility: false, model: .ready)
        let preparing = AppState(); preparing.simulate(accessibility: true, model: .preparing)
        let updates = UpdateController()

        // A · Panel, in all three header states
        for (name, state) in [("a-panel-ready", ready), ("a-panel-needs-access", noAccess), ("a-panel-preparing", preparing)] {
            await shoot(Wallpaper { Popover { MenuPanelView(store: store, state: state, history: history, updates: updates) } },
                        name, dir)
        }

        // B · Bar, with a finished preview
        let sample = Runner.Captured(text: "Can you send me your address before Friday?", app: nil, appName: "Slack",
                                     bundleID: "com.tinyspeck.slackmacgap", words: 8,
                                     detected: .init(code: "en", confidence: 0.99), anchor: nil, mouse: .zero)
        let bar = BarModel()
        bar.load(sample, preselect: nil, startPreview: false)
        bar.setSnapshotPreview(.ready("Kannst du mir deine Adresse vor Freitag schicken?"))
        await shoot(Wallpaper { BarView(model: bar, close: {}) }, "b-bar", dir)
        bar.query = "fr inf"
        bar.setSnapshotPreview(.streaming("Peux-tu m’envoyer ton adresse"))
        await shoot(Wallpaper { BarView(model: bar, close: {}) }, "b-bar-search", dir)

        // C · Notch HUD
        let phases: [(String, NotchHUD.Phase)] = [
            ("c-hud-working", .working(title: "German", detail: "Informal")),
            ("c-hud-done", .done(title: "Replaced", detail: "8 words", keycap: "⌘Z", hint: "to undo")),
            ("c-hud-problem", .problem(message: "Select some text first", keycap: nil, hint: nil)),
        ]
        for (name, phase) in phases {
            let m = NotchHUD.Model()
            m.hasNotch = true; m.notchWidth = 185; m.topInset = 37; m.expanded = true; m.phase = phase
            await shoot(ScreenTop { HUDView(model: m) }, name, dir)
        }
        let flat = NotchHUD.Model()
        flat.hasNotch = false; flat.notchWidth = 120; flat.topInset = 30; flat.expanded = true
        flat.phase = .done(title: "Replaced", detail: "8 words", keycap: "⌘Z", hint: "to undo")
        await shoot(ScreenTop(notch: false) { HUDView(model: flat) }, "c-hud-external-display", dir)

        // D · Reader card
        let reader = ReaderPanel.Model()
        reader.header = .translation(from: "German", to: "English")
        reader.text = "Unfortunately, the delivery is delayed by two days. We will let you know as soon as the package has been shipped."
        reader.original = "Die Lieferung verzögert sich leider um zwei Tage. Wir melden uns, sobald das Paket versendet wurde."
        reader.canReplace = false
        await shoot(Wallpaper { ReaderCard(model: reader, panel: nil) }, "d-reader", dir)
        reader.header = .action("Reply politely")
        reader.text = "Thanks so much for the update! Two days is no problem at all. I’ll keep an eye out for the shipping note."
        reader.canReplace = true
        reader.showOriginal = true
        await shoot(Wallpaper { ReaderCard(model: reader, panel: nil) }, "d-reader-action", dir)
        // The case that used to be cut off mid-sentence: a long result on read-only text.
        reader.header = .translation(from: "German", to: "English")
        reader.text = "Model S and Model X built before 2021 receive a clear answer right from the beginning: they do not have a mobile phone key, therefore the app cannot unlock them on approach. Owners of these cars can use the key fob or the key card instead, and the app still works for climate, charging and location. For cars built after 2021, the phone key is set up in the app under Locks, and it takes about two minutes."
        reader.original = "Model S und Model X, die vor 2021 gebaut wurden, bekommen gleich zu Beginn eine klare Antwort: Sie haben keinen Handyschlüssel."
        reader.canReplace = false
        reader.showOriginal = false
        await shoot(Wallpaper { ReaderCard(model: reader, panel: nil) }, "d-reader-long", dir)

        // E · Welcome
        await shoot(WelcomeView(state: noAccess, store: store, close: {}), "e-welcome-access", dir, dark: true)
        await shoot(WelcomeView(state: preparing, store: store, close: {}), "e-welcome-model", dir, dark: true)
        await shoot(WelcomeView(state: ready, store: store, close: {}), "e-welcome-practice", dir, dark: true)

        // F · Settings, every page
        for page in SettingsPage.allCases {
            let nav = SettingsNav()
            nav.page = page
            if page == .actions { nav.actionID = store.actions[2].id }
            await shoot(SettingsView(nav: nav, store: store, history: history, updates: updates, recorder: .shared),
                        "f-settings-\(page.rawValue)", dir, dark: false, size: NSSize(width: 820, height: 560))
        }

        let studioNav = SettingsNav()
        studioNav.page = .studio
        await shoot(SettingsView(nav: studioNav, store: store, history: history, updates: updates, recorder: .shared),
                    "f-settings-studio-dark", dir, dark: true, size: NSSize(width: 820, height: 560))

        print("Snapshots written to \(dir)")
    }

    /// Renders a view in an off-screen window at 2x and writes a PNG.
    private static func shoot<V: View>(_ view: V, _ name: String, _ dir: String,
                                       dark: Bool = true, size: NSSize? = nil) async {
        let host = NSHostingView(rootView: view.environment(\.colorScheme, dark ? .dark : .light))
        let fitting = size ?? host.fittingSize
        host.frame = NSRect(origin: .zero, size: fitting)
        let window = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        window.contentView = host
        window.setFrameOrigin(NSPoint(x: -30_000, y: -30_000))
        window.orderFrontRegardless()
        try? await Task.sleep(nanoseconds: 450_000_000)            // let SwiftUI lay out and settle
        host.layoutSubtreeIfNeeded()

        let w = Int(fitting.width * 2), h = Int(fitting.height * 2)
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8,
                                         samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return }
        rep.size = fitting
        host.cacheDisplay(in: host.bounds, to: rep)
        if let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
        }
        window.orderOut(nil)
    }
}

/// The macOS-style wallpaper the promo uses, so surfaces are judged against a real backdrop.
private struct Wallpaper<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(36)
            .background {
                ZStack {
                    LinearGradient(colors: [Color(hex: 0x7E74F1), Color(hex: 0x5B8DEF), Color(hex: 0x59C2E8)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    RadialGradient(colors: [Color(hex: 0xFFC48A), .clear], center: .topLeading, startRadius: 0, endRadius: 420)
                    RadialGradient(colors: [Color(hex: 0xC6A5FF), .clear], center: .topTrailing, startRadius: 0, endRadius: 380)
                    RadialGradient(colors: [Color(hex: 0xFF9ED8), .clear], center: .bottomLeading, startRadius: 0, endRadius: 360)
                }
            }
    }
}

/// Stands in for NSPopover's dark background, which only exists on screen.
private struct Popover<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .background(Color(hex: 0x23222A, opacity: 0.97), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.white.opacity(0.1)))
            .shadow(color: .black.opacity(0.35), radius: 20, y: 10)
    }
}

/// The top strip of a MacBook screen: wallpaper, menu bar and (optionally) the notch.
private struct ScreenTop<Content: View>: View {
    var notch = true
    @ViewBuilder var content: Content
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [Color(hex: 0x7E74F1), Color(hex: 0x5B8DEF), Color(hex: 0x59C2E8)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Color(hex: 0xFFC48A), .clear], center: .topLeading, startRadius: 0, endRadius: 300)
            HStack(spacing: 16) {
                Image(systemName: "apple.logo")
                Text("Slack").fontWeight(.bold)
                Text("File"); Text("Edit"); Text("View")
                Spacer()
                Text("Fri 9:41")
            }
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.92))
            .padding(.horizontal, 16)
            .frame(height: notch ? 37 : 26)
            .background(.white.opacity(0.12))
            if notch {
                UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10).fill(.black)
                    .frame(width: 185, height: 37)
            }
            content
        }
        .frame(width: 720, height: 150)
    }
}
