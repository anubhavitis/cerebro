import Combine
import Foundation

@MainActor
class VaultViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var errorMessage: String?

    private let fileManager = FileManager.default

    func loadVault(at url: URL) {
        Task {
            do {
                let loadedNotes = try await loadNotesFromDisk(at: url)
                await MainActor.run {
                    self.notes = loadedNotes.sorted { $0.modifiedDate > $1.modifiedDate }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load vault: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadNotesFromDisk(at url: URL) async throws -> [Note] {
        let resourceKeys: [URLResourceKey] = [.contentModificationDateKey, .isRegularFileKey]
        guard
            let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: resourceKeys
            )
        else {
            throw URLError(.cannotOpenFile)
        }

        var loadedNotes: [Note] = []

        while let fileURL = enumerator.nextObject() as? URL {
            guard fileURL.pathExtension.lowercased() == "md" else { continue }

            let content = try String(contentsOf: fileURL)
            let attributes = try fileURL.resourceValues(forKeys: Set(resourceKeys))

            let note = Note(
                name: fileURL.deletingPathExtension().lastPathComponent,
                path: fileURL,
                content: content,
                modifiedDate: attributes.contentModificationDate ?? Date()
            )

            loadedNotes.append(note)
        }

        return loadedNotes
    }

    func saveNote(_ note: Note) {
        Task {
            do {
                try await saveNoteToDisk(note)
                await MainActor.run {
                    if let index = notes.firstIndex(where: { $0.id == note.id }) {
                        notes[index] = note
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to save note: \(error.localizedDescription)"
                }
            }
        }
    }

    private func saveNoteToDisk(_ note: Note) async throws {
        try note.content.write(to: note.path, atomically: true, encoding: .utf8)
    }
}
