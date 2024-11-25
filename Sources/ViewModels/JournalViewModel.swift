import Foundation
import Combine

@MainActor
class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var errorMessage: String?

    private let journalURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        journalURL = documentsDirectory.appendingPathComponent("Journal.json")
        loadJournal()
    }

    func addEntry(_ content: String) {
        Task {
            let newEntry = JournalEntry(content: content)
            await MainActor.run {
                entries.insert(newEntry, at: 0)
            }
            await saveJournal()
        }
    }

    private func loadJournal() {
        Task {
            guard FileManager.default.fileExists(atPath: journalURL.path) else { return }

            do {
                let data = try Data(contentsOf: journalURL)
                let loadedEntries = try decoder.decode([JournalEntry].self, from: data)
                await MainActor.run {
                    self.entries = loadedEntries
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load journal: \(error.localizedDescription)"
                }
            }
        }
    }

    private func saveJournal() async {
        do {
            let data = try encoder.encode(entries)
            try data.write(to: journalURL)
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to save journal: \(error.localizedDescription)"
            }
        }
    }
}
