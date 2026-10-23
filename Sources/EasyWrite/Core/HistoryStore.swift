import Foundation

/// Recent results, kept in a JSON file in Application Support on this Mac only.
/// Off switch, retention, and excluded apps are in Settings → History.
@MainActor
final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()
    static let maxEntries = 100

    @Published private(set) var entries: [HistoryEntry] = []

    private let fileURL: URL

    init(directory: URL? = nil) {
        let base = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Easy Write", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent("history.json")
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            entries = decoded
        }
        prune()
    }

    func add(_ entry: HistoryEntry, bundleID: String?) {
        let store = Store.shared
        guard store.historyEnabled else { return }
        if let id = bundleID, store.historyExcluded.contains(id) { return }
        entries.insert(entry, at: 0)
        prune()
    }

    func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func clear() {
        entries.removeAll()
        save()
    }

    /// Drops entries older than the retention window and keeps at most `maxEntries`.
    func prune() {
        let cutoff = Date().addingTimeInterval(-Double(Store.shared.historyDays) * 86_400)
        entries = Array(entries.filter { $0.date >= cutoff }.prefix(Self.maxEntries))
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
