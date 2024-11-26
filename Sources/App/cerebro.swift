import SwiftUI

@main
struct CerebroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .defaultSize(width: 1200, height: 900)
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

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Activate the app when it launches
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Exit the app when the window is closed
        NSApp.terminate(self)
        return true
    }
}
