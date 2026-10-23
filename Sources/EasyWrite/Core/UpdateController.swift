import Foundation
#if canImport(Sparkle)
import Sparkle
#endif

/// Signed updates through Sparkle. Off until the user agrees: Sparkle asks on the second launch,
/// and the choice lives in Settings → Updates. Checks contact onekapisch.com only, and send no
/// system profile (SUEnableSystemProfiling is false in Info.plist).
@MainActor
final class UpdateController: ObservableObject {
    static let shared = UpdateController()

    /// False in builds without a feed URL and signing key (local development builds).
    @Published private(set) var available = false

    #if canImport(Sparkle)
    private var controller: SPUStandardUpdaterController?
    #endif

    func start() {
        #if canImport(Sparkle)
        let info = Bundle.main.infoDictionary ?? [:]
        guard let key = info["SUPublicEDKey"] as? String, !key.isEmpty,
              let feed = info["SUFeedURL"] as? String, !feed.isEmpty else { return }
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        available = true
        #endif
    }

    func checkNow() {
        #if canImport(Sparkle)
        controller?.checkForUpdates(nil)
        #endif
    }

    var automaticallyChecks: Bool {
        get {
            #if canImport(Sparkle)
            return controller?.updater.automaticallyChecksForUpdates ?? false
            #else
            return false
            #endif
        }
        set {
            #if canImport(Sparkle)
            controller?.updater.automaticallyChecksForUpdates = newValue
            objectWillChange.send()
            #endif
        }
    }

    var lastCheck: Date? {
        #if canImport(Sparkle)
        return controller?.updater.lastUpdateCheckDate
        #else
        return nil
        #endif
    }
}
