import SwiftUI

struct NoteDetailView: View {
    let note: Note
    let onSave: (Note) -> Void
    @State private var editableContent: String
    @State private var isEditing: Bool = false
    @Environment(\.presentationMode) var presentationMode

    func getScreenBounds() -> CGRect {
        return NSScreen.main?.frame ?? .zero
    }

    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        _editableContent = State(initialValue: note.content)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Toggle(isOn: $isEditing) {
                    Text(isEditing ? "Edit" : "Preview")
                }
                .toggleStyle(.switch)
                .padding()

                Spacer()

                if isEditing {
                    Button("Save") {
                        let updatedNote = Note(
                            id: note.id,
                            name: note.name,
                            path: note.path,
                            content: editableContent,
                            modifiedDate: Date()
                        )
                        onSave(updatedNote)
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .padding()
                }
            }
            .background(Color(NSColor.windowBackgroundColor))

            // Divider
            Divider()

            // Content area
            if isEditing {
                TextEditor(text: $editableContent)
                    .font(.body)
                    .padding()
                    .frame(
                        maxWidth: getScreenBounds().width * 0.5, maxHeight: .infinity,
                        alignment: .leading
                    )
                    .padding(.leading, 25)
                    .background(Color(nsColor: .textBackgroundColor))
            } else {
                MarkdownView(content: editableContent)
                    .frame(maxWidth: getScreenBounds().width * 0.5, maxHeight: .infinity)
                    .padding(.leading, 25)
                    .background(Color(nsColor: .textBackgroundColor))
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
        .navigationTitle(note.name)
    }
}
