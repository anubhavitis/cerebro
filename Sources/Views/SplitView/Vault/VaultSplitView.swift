import SwiftUI

struct VaultListView: View {
    @ObservedObject var vaultViewModel: VaultViewModel
    @Binding var selectedNote: Note?

    var body: some View {
        List(selection: $selectedNote) {
            Section("Vault") {
                Button("Load Vault", action: showVaultPicker)
                    .buttonStyle(.borderless)
                    .keyboardShortcut("O", modifiers: .command)
            }

            if !vaultViewModel.notes.isEmpty {
                Section("Notes") {
                    ForEach(vaultViewModel.notes) { note in
                        NavigationLink(value: note) {
                            NoteRowView(note: note)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Vault")
    }

    private func showVaultPicker() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false

        if openPanel.runModal() == .OK {
            vaultViewModel.loadVault(at: openPanel.url!)
        }
    }
}
