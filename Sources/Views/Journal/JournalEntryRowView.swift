import SwiftUI

struct JournalEntryRowView: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.content)
            Text(entry.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
