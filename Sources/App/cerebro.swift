import SwiftUI

@main
struct ObsidianNotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Load Vault") {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("LoadVault"),
                        object: nil
                    )
                }
                .keyboardShortcut("O", modifiers: .command)
            }
        }
    }

    init() {
        NSApplication.shared.setActivationPolicy(.regular)
    }
}
