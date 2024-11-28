import SwiftUI

struct ContentView: View {
    @StateObject private var vaultViewModel = VaultViewModel()
    @State private var selectedNote: Note?
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
            VaultListView(vaultViewModel: vaultViewModel, selectedNote: $selectedNote)
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
        .background(Color(nsColor: .textBackgroundColor))
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
    }
}
