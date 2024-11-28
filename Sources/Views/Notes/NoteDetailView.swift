import MarkdownUI
import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @StateObject private var viewModel: MarkdownLineViewModel

    init(note: Binding<Note>, onSave: @escaping (Note) -> Void) {
        _note = note
        _viewModel = StateObject(
            wrappedValue: MarkdownLineViewModel(note: note.wrappedValue, onSave: onSave))
    }

    func getScreenBounds() -> CGRect {
        return NSScreen.main?.frame ?? .zero
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(viewModel.contentLines.enumerated()), id: \.element.id) {
                    index, line in
                    if line.isEditing {
                        TextEditor(
                            text: Binding(
                                get: { viewModel.contentLines[index].text },
                                set: { viewModel.updateLineContent(at: index, newContent: $0) }
                            )
                        )
                        .font(.body)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color(nsColor: .textBackgroundColor))
                        .onSubmit {
                            viewModel.handleLineSubmit(at: index)
                        }
                    } else {
                        Markdown(line.text)
                            .background(Color(nsColor: .textBackgroundColor))
                            .markdownTheme(.gitHub)
                            .font(.body)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, CGFloat(line.indentationLevel * 20))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.startEditing(at: index)
                            }
                            .padding(.vertical, 2)
                    }
                }
            }
            .padding()
            .frame(maxWidth: getScreenBounds().width * 0.5, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .navigationTitle(note.name)
        .onChange(of: note) { newNote in
            viewModel.updateNote(newNote)
        }
    }
}
