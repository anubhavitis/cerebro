import SwiftUI

struct JournalListView: View {
    @ObservedObject var journalViewModel: JournalViewModel
    @Binding var newJournalEntry: String
    let onCommit: () -> Void

    var body: some View {
        List {
            Section("Journal") {
                JournalEntryView(
                    newEntry: $newJournalEntry,
                    onCommit: onCommit
                )

                ForEach(journalViewModel.entries) { entry in
                    JournalEntryRowView(entry: entry)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Journal")
    }
}
