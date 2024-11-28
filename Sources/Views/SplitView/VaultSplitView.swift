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

            Section("Notes") {
                ForEach(vaultViewModel.notes) { note in
                    NavigationLink(value: note) {
                        NoteRowView(note: note)
                    }
                }
            }

        }
        .listStyle(.sidebar)
        .navigationTitle("Vault")
        .onAppear(perform: loadDefaultVault)
    }

    private func loadDefaultVault() {
        if vaultViewModel.notes.isEmpty {
            if let vaultURL = getVaultURL() {
                vaultViewModel.loadVault(at: vaultURL)
            }
        }
    }

    private func getVaultURL() -> URL? {
        if let savedPath = UserDefaults.standard.string(forKey: "VaultPath") {
            return URL(fileURLWithPath: savedPath)
        }

        return nil
    }

    private func showVaultPicker() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false

        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                UserDefaults.standard.set(url.path, forKey: "VaultPath")
                vaultViewModel.loadVault(at: url)
            }
        }
    }
}
