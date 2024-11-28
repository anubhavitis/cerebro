import Foundation
import SwiftUI

struct LineContent: Identifiable {
    let id = UUID()
    var text: String
    var isEditing: Bool
    var indentationLevel: Int

    init(text: String, isEditing: Bool = false) {
        self.text = text
        self.isEditing = isEditing
        self.indentationLevel = text.prefix(while: { $0 == " " }).count / 2
    }
}

@MainActor  // Mark the whole class as running on the main actor
class MarkdownLineViewModel: ObservableObject {
    @Published var contentLines: [LineContent] = []
    @Published var editingLineIndex: Int?
    private var saveTask: Task<Void, Never>?
    private let onSave: (Note) -> Void
    private var note: Note

    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        self.contentLines = note.content
            .components(separatedBy: .newlines)
            .map { LineContent(text: $0) }
    }

    func updateNote(_ newNote: Note) {
        note = newNote
        contentLines = newNote.content
            .components(separatedBy: .newlines)
            .map { LineContent(text: $0) }
    }

    func startEditing(at index: Int) {
        if let editingIndex = editingLineIndex {
            contentLines[editingIndex].isEditing = false
        }
        contentLines[index].isEditing = true
        editingLineIndex = index
    }

    func handleLineSubmit(at index: Int) {
        let currentLine = contentLines[index]
        contentLines[index].isEditing = false

        let newLineContent = determineNewLineContent(afterLine: currentLine, atIndex: index)
        contentLines.insert(LineContent(text: newLineContent, isEditing: true), at: index + 1)
        editingLineIndex = index + 1

        autoSave()
    }

    func updateLineContent(at index: Int, newContent: String) {
        contentLines[index].text = newContent
        autoSave()
    }

    private func determineNewLineContent(afterLine line: LineContent, atIndex index: Int) -> String
    {
        let trimmedLine = line.text.trimmingCharacters(in: .whitespaces)
        let indentation = String(repeating: "  ", count: line.indentationLevel)

        // Handle bullet points
        if trimmedLine.starts(with: "- ") || trimmedLine.starts(with: "* ") {
            let bulletType = trimmedLine.hasPrefix("- ") ? "- " : "* "

            if trimmedLine == "- " || trimmedLine == "* " {
                if line.indentationLevel > 0 {
                    return String(repeating: "  ", count: line.indentationLevel - 1) + bulletType
                }
                return ""
            }

            return indentation + bulletType
        }

        // Handle numbered lists
        if let numberMatch = trimmedLine.range(of: #"^\d+\. "#, options: .regularExpression) {
            let number = Int(trimmedLine[..<numberMatch.upperBound].filter { $0.isNumber }) ?? 0

            if trimmedLine == "\(number). " {
                if line.indentationLevel > 0 {
                    return String(repeating: "  ", count: line.indentationLevel - 1)
                        + "\(number + 1). "
                }
                return ""
            }

            return indentation + "\(number + 1). "
        }

        // Handle code blocks
        if trimmedLine.starts(with: "```") {
            return indentation + "```"
        }

        return indentation
    }

    private func autoSave() {
        // Cancel existing task
        saveTask?.cancel()

        // Create new task
        saveTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                try await Task.sleep(nanoseconds: 500_000_000)

                // Check if task was cancelled
                try Task.checkCancellation()

                let updatedContent = self.contentLines
                    .map { $0.text }
                    .joined(separator: "\n")

                let updatedNote = Note(
                    id: self.note.id,
                    name: self.note.name,
                    path: self.note.path,
                    content: updatedContent,
                    modifiedDate: Date()
                )

                self.onSave(updatedNote)
            } catch {
                // Handle cancellation or other errors
                if error is CancellationError {
                    // Task was cancelled, do nothing
                    return
                }
                // Handle other errors if needed
            }
        }
    }
}
