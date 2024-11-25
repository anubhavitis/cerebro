import SwiftUI

struct ContentView: View {
    @StateObject private var vaultViewModel = VaultViewModel()
    @StateObject private var journalViewModel = JournalViewModel()
    @State private var selectedNote: Note?
    @State private var newJournalEntry = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Vault")) {
                    ForEach(vaultViewModel.notes) { note in
                        NavigationLink(
                            destination: NoteDetailView(
                                note: note,
                                onSave: vaultViewModel.saveNote),
                            tag: note,
                            selection: $selectedNote
                        ) {
                            NoteRowView(note: note)
                        }
                    }
                }

                Section(header: Text("Journal")) {
                    JournalEntryView(
                        newEntry: $newJournalEntry,
                        onCommit: commitJournalEntry)

                    ForEach(journalViewModel.entries) { entry in
                        JournalEntryRowView(entry: entry)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 250)

            Text("Select a note or start a journal entry")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Load Vault", action: showVaultPicker)
            }
        }
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK")))
        }
        .onChange(of: vaultViewModel.errorMessage) { message in
            if let message = message {
                errorMessage = message
                showingError = true
                vaultViewModel.errorMessage = nil
            }
        }
        .onChange(of: journalViewModel.errorMessage) { message in
            if let message = message {
                errorMessage = message
                showingError = true
                journalViewModel.errorMessage = nil
            }
        }
    }

    private func showVaultPicker() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false

        if openPanel.runModal() == .OK {
            vaultViewModel.loadVault(at: openPanel.url!)
        }
    }

    private func commitJournalEntry() {
        guard !newJournalEntry.isEmpty else { return }
        journalViewModel.addEntry(newJournalEntry)
        newJournalEntry = ""
    }
}
