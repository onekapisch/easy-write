import AppKit
import AVFoundation
import ScreenCaptureKit
import SwiftUI

/// Developer-only artwork. Uses production views, throwaway settings and synthetic text.
/// Captures only its own view, not desktop pixels or the clipboard. No model requests.
@MainActor
enum LaunchAssets {
    enum Failure: Error { case bitmap, encoding, writer(String), missingImage }
    private static let canvas = NSSize(width: 1200, height: 900)

    static func run(to path: String) async throws {
        let root = URL(fileURLWithPath: path, isDirectory: true)
        for folder in ["raw", "images", "video", "social", ".capture"] {
            try FileManager.default.createDirectory(at: root.appendingPathComponent(folder), withIntermediateDirectories: true)
        }
        let suite = "com.onekapisch.easywrite.launch.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = Store(defaults: defaults, legacy: nil)
        Store.shared = store
        store.targetCode = "de"; store.homeCode = "en"; store.defaultTone = .informal
        store.appPreferences = ["com.apple.mail": .init(code: "de", tone: .formal, appName: "Mail"),
                                "com.tinyspeck.slackmacgap": .init(code: "de", tone: .informal, appName: "Slack")]
        // Keep the panel at honest fresh-install counts and History Off.
        let historyDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("ew-launch-\(UUID())")
        defer { try? FileManager.default.removeItem(at: historyDirectory) }
        let history = HistoryStore(directory: historyDirectory, store: store, monitor: false)
        let ready = AppState(); ready.simulate(accessibility: true, model: .ready)
        let updates = UpdateController()

        let captured = Runner.Captured(text: "Can you send me your address before Friday?", app: nil,
                                      appName: "Slack", bundleID: "com.tinyspeck.slackmacgap", words: 8,
                                      detected: .init(code: "en", confidence: 0.99), anchor: nil, mouse: .zero)
        let bar = BarModel()
        bar.load(captured, preselect: nil, startPreview: false)
        bar.setSnapshotPreview(.ready("Kannst du mir deine Adresse vor Freitag schicken?"))
        let barImage = try await render(BarView(model: bar, close: {}).padding(32),
                                        to: root.appendingPathComponent("raw/bar.png"))
        let menuImage = try await render(MenuPanelView(store: store, state: ready, history: history, updates: updates)
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10).padding(32),
                                        to: root.appendingPathComponent("raw/menu-bar.png"))
        let reader = ReaderPanel.Model()
        reader.header = .translation(from: "German", to: "English")
        reader.original = "Die Lieferung verzögert sich leider um zwei Tage. Wir melden uns, sobald das Paket versendet wurde."
        reader.text = "Unfortunately, the delivery is delayed by two days. We will let you know as soon as the package has been shipped."
        reader.canReplace = false
        let readerImage = try await render(ReaderCard(model: reader, panel: nil).padding(32),
                                           to: root.appendingPathComponent("raw/reader.png"))
        let actionCapture = Runner.Captured(text: "She are arriving tomorrow.", app: nil, appName: "TextEdit",
                                            bundleID: "com.apple.TextEdit", words: 4,
                                            detected: .init(code: "en", confidence: 0.99), anchor: nil, mouse: .zero)
        let action = BarModel()
        action.load(actionCapture, preselect: .action(store.actions[0].id), startPreview: false)
        action.setSnapshotPreview(.ready("She is arriving tomorrow."))
        let actionImage = try await render(BarView(model: action, close: {}).padding(32),
                                           to: root.appendingPathComponent("raw/actions.png"))

        for night in [false, true] {
            _ = try await render(LaunchHero(image: barImage, night: night), size: canvas,
                                 to: root.appendingPathComponent("images/hero-\(night ? "midnight" : "daylight").png"))
        }
        _ = try await render(MenuArtwork(image: menuImage), size: canvas,
                             to: root.appendingPathComponent("images/menu-bar.png"))
        _ = try await render(FeatureArtwork(title: "Formal when it matters.\nInformal when it fits.",
                                            subtitle: "Sie or du. Choose the tone, not just the language.",
                                            image: barImage, key: "⌥⌘K", foot: "A language and tone for each app."), size: canvas,
                             to: root.appendingPathComponent("images/tones.png"))
        _ = try await render(FeatureArtwork(title: "Read it.\nWithout the detour.",
                                            subtitle: "A translation you can copy, hear, or keep in view.",
                                            image: readerImage, key: "⌥⌘E", foot: "Read in your language."), size: canvas,
                             to: root.appendingPathComponent("images/reader.png"))
        _ = try await render(FeatureArtwork(title: "A better sentence.\nOne shortcut away.",
                                            subtitle: "Fix grammar, make it shorter, or run your own instruction.",
                                            image: actionImage, key: "⌥⌘G", foot: "Built-in actions. Or one you write yourself."), size: canvas,
                             to: root.appendingPathComponent("images/actions.png"))
        _ = try await render(SocialArtwork(image: barImage), size: NSSize(width: 640, height: 320),
                             to: root.appendingPathComponent("social/github-social.png"))
        try await recordNotch(to: root)
        print("Native launch assets exported to \(root.path)")
    }

    private static func host<V: View>(_ view: V, size: NSSize?) -> (NSHostingView<V>, NSWindow) {
        let host = NSHostingView(rootView: view)
        let fitting = size ?? host.fittingSize
        host.frame = NSRect(origin: .zero, size: fitting)
        let w = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        w.isOpaque = false; w.backgroundColor = .clear; w.hasShadow = false
        w.appearance = NSAppearance(named: .darkAqua)
        w.contentView = host
        w.setFrameOrigin(NSPoint(x: -30_000, y: -30_000))
        w.orderFrontRegardless()
        return (host, w)
    }

    private static func bitmap(_ view: NSView) throws -> NSBitmapImageRep {
        view.layoutSubtreeIfNeeded()
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(view.bounds.width * 2),
                                         pixelsHigh: Int(view.bounds.height * 2), bitsPerSample: 8,
                                         samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { throw Failure.bitmap }
        rep.size = view.bounds.size
        view.cacheDisplay(in: view.bounds, to: rep)
        return rep
    }

    private static func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
        guard let png = rep.representation(using: .png, properties: [:]) else { throw Failure.encoding }
        try png.write(to: url, options: .atomic)
    }

    private static func render<V: View>(_ view: V, size: NSSize? = nil, to url: URL) async throws -> NSImage {
        let (view, window) = host(view, size: size)
        defer { window.orderOut(nil) }
        try await Task.sleep(nanoseconds: 250_000_000)
        let rep = try bitmap(view)
        try writePNG(rep, to: url)
        let image = NSImage(size: view.bounds.size); image.addRepresentation(rep)
        return image
    }

    private static func recordNotch(to root: URL) async throws {
        guard CGPreflightScreenCaptureAccess() else {
            throw Failure.writer("Window capture permission is not available. No permission was requested.")
        }
        let model = NotchHUD.Model()
        model.hasNotch = true; model.notchWidth = 185; model.topInset = 37
        model.phase = .working(title: "German", detail: "Informal")
        let (view, window) = host(NotchStage(model: model), size: NSSize(width: 720, height: 420))
        // WindowServer capture preserves SwiftUI presentation frames that cacheDisplay omits.
        // Capture is restricted to this window and uses existing permission, never a prompt.
        window.center(); window.orderFrontRegardless()
        defer { window.orderOut(nil) }
        try await Task.sleep(nanoseconds: 400_000_000)
        let available = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)
        guard let ownWindow = available.windows.first(where: { $0.windowID == CGWindowID(window.windowNumber) }) else {
            throw Failure.writer("Owned demo window was not found")
        }
        let filter = SCContentFilter(desktopIndependentWindow: ownWindow)
        let configuration = SCStreamConfiguration()
        configuration.width = 1440; configuration.height = 840
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 60)
        configuration.showsCursor = false; configuration.capturesAudio = false
        configuration.ignoreShadowsSingleWindow = true
        let stream = SCStream(filter: filter, configuration: configuration, delegate: nil)
        let destination = root.appendingPathComponent(".capture/notch-native.mp4")
        if FileManager.default.fileExists(atPath: destination.path) { try FileManager.default.removeItem(at: destination) }
        let recording = SCRecordingOutputConfiguration()
        recording.outputURL = destination; recording.outputFileType = .mp4; recording.videoCodecType = .h264
        let sink = LaunchRecordingSink()
        let output = SCRecordingOutput(configuration: recording, delegate: sink)
        try stream.addRecordingOutput(output)
        try await stream.startCapture()
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            withAnimation(NotchHUD.animation) { model.expanded = true }
            try await Task.sleep(nanoseconds: 2_200_000_000)
            model.phase = .done(title: "Paste sent", detail: "8 words", keycap: "⌘Z", hint: "to undo")
            try await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(NotchHUD.animation) { model.expanded = false }
            try await Task.sleep(nanoseconds: 2_300_000_000)
            try await stream.stopCapture()
        } catch {
            try? await stream.stopCapture()
            throw error
        }
        let deadline = Date().addingTimeInterval(5)
        while !sink.finished && Date() < deadline { try await Task.sleep(nanoseconds: 30_000_000) }
        guard sink.finished, sink.failure == nil else { throw Failure.writer(sink.failure ?? "Recording finalization timed out") }
        _ = view // retained through the complete recording
        print("Captured the owned native HUD window; no desktop capture.")
    }
}

private final class LaunchRecordingSink: NSObject, SCRecordingOutputDelegate {
    private let lock = NSLock()
    private var done = false
    private var errorText: String?
    var finished: Bool { lock.lock(); defer { lock.unlock() }; return done }
    var failure: String? { lock.lock(); defer { lock.unlock() }; return errorText }
    func recordingOutputDidStartRecording(_ recordingOutput: SCRecordingOutput) {}
    func recordingOutputDidFinishRecording(_ recordingOutput: SCRecordingOutput) {
        lock.lock(); done = true; lock.unlock()
    }
    func recordingOutput(_ recordingOutput: SCRecordingOutput, didFailWithError error: Error) {
        lock.lock(); errorText = error.localizedDescription; done = true; lock.unlock()
    }
}

private struct LaunchBackdrop: View {
    var night = false
    var body: some View {
        ZStack {
            Color(hex: night ? 0x100E17 : 0xF6F4F9)
            RadialGradient(colors: [Color(hex: night ? 0x32244D : 0xD4C9F0), .clear],
                           center: .bottom, startRadius: 0, endRadius: 900)
        }
    }
}

private struct LaunchBrand: View {
    var night = false
    var body: some View {
        HStack(spacing: 10) {
            AppGlyph(size: 34)
            Text("Easy Write 2.0").font(.system(size: 20, weight: .semibold)).tracking(-0.5)
            Spacer()
            Text("Free & open source for Mac").font(.system(size: 14)).foregroundStyle(night ? Color(hex: 0xAAA0BB) : Color(hex: 0x726B81))
        }.foregroundStyle(night ? .white : Color(hex: 0x24212E))
    }
}

/// Fade only the transparent shadow padding, avoiding a rectangular crop edge on the artwork.
private struct LaunchScreenshot: View {
    let image: NSImage
    var body: some View {
        Image(nsImage: image).resizable().scaledToFit()
            .mask {
                LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .white, location: 0.035),
                                       .init(color: .white, location: 0.965), .init(color: .clear, location: 1)],
                               startPoint: .leading, endPoint: .trailing)
                .mask {
                    LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .white, location: 0.05),
                                           .init(color: .white, location: 0.95), .init(color: .clear, location: 1)],
                                   startPoint: .top, endPoint: .bottom)
                }
            }
    }
}

private struct LaunchHero: View {
    let image: NSImage
    var night = false
    var body: some View {
        ZStack {
            LaunchBackdrop(night: night)
            LaunchBrand(night: night).frame(width: 1092, height: 34).position(x: 600, y: 55)
            Text("Better words. Same place.").font(.system(size: 72, weight: .semibold)).tracking(-3.7)
                .foregroundStyle(night ? Color.white : Color(hex: 0x24212E)).position(x: 600, y: 160)
            Text("Translate and rewrite selected text, right where you’re writing.")
                .font(.system(size: 21)).foregroundStyle(night ? Color(hex: 0xAAA0BB) : Color(hex: 0x726B81)).position(x: 600, y: 226)
            LaunchScreenshot(image: image).frame(width: 1040, height: 640).position(x: 600, y: 560)
            HStack {
                Text("Your writing stays on your Mac.")
                Spacer()
                Text("⌥⌘K  Meet the new Easy Write Bar")
            }.font(.system(size: 13)).foregroundStyle(night ? Color(hex: 0xAAA0BB) : Color(hex: 0x726B81))
                .frame(width: 930, height: 20).position(x: 600, y: 872)
        }.frame(width: 1200, height: 900)
    }
}

private struct MenuArtwork: View {
    let image: NSImage
    var body: some View {
        ZStack(alignment: .topLeading) {
            LaunchBackdrop()
            LaunchBrand().padding(.horizontal, 54).padding(.top, 38)
            VStack(alignment: .leading, spacing: 25) {
                Text("Always there.\nOut of your way.").font(.system(size: 65, weight: .semibold)).tracking(-3).lineSpacing(-4)
                Text("Your language, your tone, your shortcuts.\nA click from the menu bar.")
                    .font(.system(size: 22)).foregroundStyle(Color(hex: 0x726B81)).lineSpacing(6)
                Text("Ready when you need it.").font(.system(size: 15)).foregroundStyle(Color(hex: 0x726B81)).padding(.top, 60)
            }.foregroundStyle(Color(hex: 0x24212E)).offset(x: 70, y: 250)
            HStack(spacing: 18) {
                Image(systemName: "wifi"); Image(systemName: "character.bubble").foregroundStyle(EW.accent)
                Text("Fri 9:41")
            }.font(.system(size: 15)).foregroundStyle(Color(hex: 0x514A60))
                .padding(.horizontal, 25).frame(width: 400, height: 37, alignment: .trailing)
                .background(.white.opacity(0.4)).clipShape(RoundedRectangle(cornerRadius: 9))
                .offset(x: 670, y: 126)
            LaunchScreenshot(image: image).frame(width: 500, height: 700).offset(x: 615, y: 157)
            Text("Menu-bar panel · Sample settings, History Off")
                .font(.system(size: 13)).foregroundStyle(Color(hex: 0x82768F)).offset(x: 70, y: 858)
        }.frame(width: 1200, height: 900)
    }
}

private struct FeatureArtwork: View {
    let title: String
    let subtitle: String
    let image: NSImage
    let key: String
    let foot: String
    var body: some View {
        ZStack {
            LaunchBackdrop()
            LaunchBrand().frame(width: 1092, height: 34).position(x: 600, y: 55)
            Text(title).font(.system(size: 61, weight: .semibold)).tracking(-2.8)
                .multilineTextAlignment(.center).foregroundStyle(Color(hex: 0x24212E)).position(x: 600, y: 205)
            Text(subtitle).font(.system(size: 21)).foregroundStyle(Color(hex: 0x726B81)).position(x: 600, y: 310)
            LaunchScreenshot(image: image).frame(width: 1010, height: 500).position(x: 600, y: 593)
            HStack(spacing: 14) {
                Keycap(text: key, size: 15).environment(\.colorScheme, .dark)
                Text(foot).font(.system(size: 15)).foregroundStyle(Color(hex: 0x726B81))
            }.position(x: 600, y: 865)
        }.frame(width: 1200, height: 900)
    }
}

private struct SocialArtwork: View {
    let image: NSImage
    var body: some View {
        ZStack {
            LaunchBackdrop()
            HStack(spacing: 8) { AppGlyph(size: 24); Text("Easy Write 2.0").font(.system(size: 14, weight: .semibold)); Spacer(); Text("Free & open source").font(.system(size: 11)) }
                .foregroundStyle(Color(hex: 0x514A60)).frame(width: 588, height: 24).position(x: 320, y: 32)
            Text("Better words.\nSame place.").font(.system(size: 36, weight: .semibold)).tracking(-1.6)
                .foregroundStyle(Color(hex: 0x24212E)).frame(width: 235, alignment: .leading).position(x: 145, y: 155)
            Text("Translate and rewrite.\nPrivately on your Mac.").font(.system(size: 14)).foregroundStyle(Color(hex: 0x726B81))
                .frame(width: 230, alignment: .leading).position(x: 143, y: 245)
            LaunchScreenshot(image: image).frame(width: 370, height: 250).position(x: 445, y: 187)
        }.frame(width: 640, height: 320).clipped()
    }
}

private struct NotchStage: View {
    @ObservedObject var model: NotchHUD.Model
    var body: some View {
        ZStack(alignment: .top) {
            LaunchBackdrop()
            HStack(spacing: 15) {
                Image(systemName: "apple.logo"); Text("TextEdit").fontWeight(.semibold)
                Text("File"); Text("Edit"); Text("View"); Spacer(); Text("Fri 9:41")
            }.font(.system(size: 12)).foregroundStyle(Color(hex: 0x514A60))
                .padding(.horizontal, 18).frame(height: 37).background(.white.opacity(0.3))
            UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10).fill(.black)
                .frame(width: 185, height: 37)
            VStack(spacing: 16) {
                AppGlyph(size: 38)
                Text("A little feedback.\nRight in your flow.").font(.system(size: 39, weight: .semibold)).tracking(-1.8).multilineTextAlignment(.center)
                Text("The native Easy Write notch animation").font(.system(size: 15)).foregroundStyle(Color(hex: 0x726B81))
            }.foregroundStyle(Color(hex: 0x24212E)).offset(y: 138)
            Text("Native SwiftUI capture · Staged backdrop and timings").font(.system(size: 10)).foregroundStyle(Color(hex: 0x82768F)).offset(y: 390)
            HUDView(model: model)
        }.frame(width: 720, height: 420)
    }
}
