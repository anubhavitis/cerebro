import Inject
import SwiftUI

struct ContentView: View {
    @ObserveInjection var inject
    @StateObject private var vaultViewModel = VaultViewModel()
    @StateObject private var journalViewModel = JournalViewModel()
    @State private var selectedNote: Note?
    @State private var selectedCategory: String?
    @State private var newJournalEntry = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var selectedSidebarItem: SidebarItem = .vault

    enum SidebarItem {
        case vault
        case journal
        case settings
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { selectedSidebarItem = .journal }) {
                        Image(systemName: "book")
                            .font(.title2)
                            .foregroundColor(
                                selectedSidebarItem == .journal ? .accentColor : .primary)
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    Button(action: { selectedSidebarItem = .vault }) {
                        Image(systemName: "folder")
                            .font(.title2)
                            .foregroundColor(
                                selectedSidebarItem == .vault ? .accentColor : .primary)
                    }
                    .buttonStyle(.borderless)

                    Spacer()
                }
                .padding()

                // Content below buttons
                Group {
                    switch selectedSidebarItem {
                    case .vault:
                        VaultListView(vaultViewModel: vaultViewModel, selectedNote: $selectedNote)
                    case .journal:
                        JournalListView(
                            journalViewModel: journalViewModel, newJournalEntry: $newJournalEntry,
                            onCommit: commitJournalEntry)
                    default:
                        VaultListView(vaultViewModel: vaultViewModel, selectedNote: $selectedNote)

                    }
                }
            }
        } detail: {
            // Detail View
            if let selectedNote = selectedNote {  // Unwrap the optional
                NoteDetailView(
                    note: Binding(  // Create a non-optional binding
                        get: { selectedNote },
                        set: { self.selectedNote = $0 }
                    ),
                    onSave: { note in
                        vaultViewModel.saveNote(note)
                    }
                )
            } else {
                Text("Select a note or start a journal entry")
                    .foregroundColor(.secondary)
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
        .enableInjection()
    }

    private func commitJournalEntry() {
        guard !newJournalEntry.isEmpty else { return }
        journalViewModel.addEntry(newJournalEntry)
        newJournalEntry = ""
    }
}
