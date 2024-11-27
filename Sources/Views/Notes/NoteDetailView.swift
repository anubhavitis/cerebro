import MarkdownUI
import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    let onSave: (Note) -> Void
    @State private var editableContent: String
    @State private var isEditing: Bool = false
    @Environment(\.presentationMode) var presentationMode

    func getScreenBounds() -> CGRect {
        return NSScreen.main?.frame ?? .zero
    }

    init(note: Binding<Note>, onSave: @escaping (Note) -> Void) {
        _note = note
        self.onSave = onSave
        _editableContent = State(initialValue: note.wrappedValue.content)
    }

    var body: some View {
        Group {
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

                Divider()

                ScrollView {
                    if isEditing {
                        TextEditor(text: $editableContent)
                            .font(.body)
                            .frame(
                                maxWidth: getScreenBounds().width * 0.5,
                                maxHeight: .infinity,
                                alignment: .topLeading
                            )
                            .background(Color(nsColor: .textBackgroundColor))
                    } else {
                        Markdown(editableContent)
                            .background(Color(nsColor: .textBackgroundColor))
                            .font(.body)
                            .textSelection(.enabled)
                            .markdownTheme(.gitHub)
                            .frame(
                                maxWidth: getScreenBounds().width * 0.5,
                                maxHeight: .infinity,
                                alignment: .topLeading
                            )
                    }
                }
                .padding()
                .background(Color(nsColor: .textBackgroundColor))
            }

            .background(Color(nsColor: .textBackgroundColor))
            .navigationTitle(note.name)

        }
        .onChange(of: note) { newNote in
            editableContent = newNote.content
        }
    }
}
