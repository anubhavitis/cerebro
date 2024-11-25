import SwiftUI

struct JournalEntryView: View {
    @Binding var newEntry: String
    let onCommit: () -> Void

    var body: some View {
        TextField(
            "New Journal Entry",
            text: $newEntry,
            onCommit: onCommit)
    }
}
