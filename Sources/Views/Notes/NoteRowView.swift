import SwiftUI

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading) {
            Text(note.name)
            Text(note.modifiedDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
