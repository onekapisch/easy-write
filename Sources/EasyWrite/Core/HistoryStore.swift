import AppKit
import Combine

/// Recent results, kept in a JSON file in Application Support on this Mac only.
/// Off switch, retention, and excluded apps are in Settings → History.
@MainActor
final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()
    static let maxEntries = 100

    @Published private(set) var entries: [HistoryEntry] = []

    private let fileURL: URL
    private let store: Store
    private let clock: () -> Date
    private var subscriptions: Set<AnyCancellable> = []
    private var timer: Timer?

    init(directory: URL? = nil, store: Store? = nil, clock: @escaping () -> Date = Date.init,
         monitor: Bool = true) {
        self.store = store ?? Store.shared
        self.clock = clock
        let base = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Easy Write", isDirectory: true)
        fileURL = base.appendingPathComponent("history.json")
        if self.store.historyEnabled, let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            entries = decoded
        }
        prune()
        if !entries.isEmpty { save() } // tighten permissions on history created by older builds
        self.store.$historyEnabled.dropFirst().sink { [weak self] enabled in
            if !enabled { self?.clear() }
        }.store(in: &subscriptions)
        self.store.$historyDays.dropFirst().sink { [weak self] days in
            self?.prune(days: days)
        }.store(in: &subscriptions)
        if monitor {
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.prune() }
            }
            NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
                .sink { [weak self] _ in Task { @MainActor in self?.prune() } }
                .store(in: &subscriptions)
        }
    }

    deinit { timer?.invalidate() }

    func add(_ entry: HistoryEntry, bundleID: String?) {
        guard store.historyEnabled else { return }
        guard let id = bundleID, !store.historyExcluded.contains(id) else { return }
        entries.insert(entry, at: 0)
        prune()
        save()
    }

    func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func clear() {
        entries.removeAll()
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) { try FileManager.default.removeItem(at: fileURL) }
        } catch {
            NotchHUD.shared.problem("Could not delete history. Check folder permissions.")
        }
    }

    /// Drops entries older than the retention window and keeps at most `maxEntries`.
    func prune() {
        prune(days: store.historyDays)
    }

    private func prune(days: Int) {
        guard store.historyEnabled else { clear(); return }
        let cutoff = clock().addingTimeInterval(-Double(min(30, max(1, days))) * 86_400)
        let kept = Array(entries.filter { $0.date >= cutoff }.prefix(Self.maxEntries))
        if kept != entries { entries = kept; save() }
    }

    private func save() {
        guard !entries.isEmpty else { clear(); return }
        do {
            let dir = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true,
                                                   attributes: [.posixPermissions: 0o700])
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: dir.path)
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
        } catch {
            NotchHUD.shared.problem("Could not save history. Check folder permissions.")
        }
    }
}
