import SwiftDown
import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @StateObject private var viewModel: NoteEditorViewModel

    init(note: Binding<Note>, onSave: @escaping (Note) -> Void) {
        _note = note
        _viewModel = StateObject(
            wrappedValue: NoteEditorViewModel(
                note: note.wrappedValue,
                onNoteUpdate: { updatedNote in
                    onSave(updatedNote)
                }
            ))
    }

    func getScreenBounds() -> CGRect {
        return NSScreen.main?.frame ?? .zero
    }

    var body: some View {
        SwiftDownEditor(text: $viewModel.editableContent)
            .font(.body)
            .background(Color(nsColor: .textBackgroundColor))
            .frame(maxWidth: getScreenBounds().width * 0.5, maxHeight: .infinity)
            .onChange(of: note) { newNote in
                viewModel.updateNote(newNote)
            }
            .onChange(of: viewModel.editableContent) { _ in
                viewModel.handleContentChange()
            }
            .navigationTitle(note.name)
    }
}
