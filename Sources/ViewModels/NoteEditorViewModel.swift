import Foundation

@MainActor
class NoteEditorViewModel: ObservableObject {
    @Published var editableContent: String
    private var note: Note
    private let autosaveDelay = 0.5
    private var autosaveTask: Task<Void, Never>?
    private let onNoteUpdate: (Note) -> Void

    init(note: Note, onNoteUpdate: @escaping (Note) -> Void) {
        self.note = note
        self.editableContent = note.content
        self.onNoteUpdate = onNoteUpdate
    }

    func updateNote(_ newNote: Note) {
        note = newNote
        editableContent = newNote.content
    }

    func handleContentChange() {
        autosaveTask?.cancel()

        autosaveTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: UInt64(autosaveDelay * 1_000_000_000))

                guard !Task.isCancelled else { return }

                let updatedNote = Note(
                    id: note.id,
                    name: note.name,
                    path: note.path,
                    content: editableContent,
                    modifiedDate: Date()
                )

                onNoteUpdate(updatedNote)

            } catch is CancellationError {
                return  // Ignore cancellation
            } catch {
                print("Other error occurred: \(error)")
            }
        }
    }

    func cleanup() {
        autosaveTask?.cancel()
        autosaveTask = nil
    }
}
