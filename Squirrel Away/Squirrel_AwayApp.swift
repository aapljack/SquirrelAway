import SwiftUI

@main
struct Squirrel_AwayApp: App {
    @StateObject private var appHider = AppHider()
    
    init() {
        Settings.shared.syncLaunchAtLoginState()
        
        // Debug: check if our menu bar icon loads
        if let img = NSImage(named: "MenuBarIcon") {
            print("✅ MenuBarIcon loaded, size: \(img.size)")
        } else {
            print("❌ MenuBarIcon NOT found in assets")
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            Button("Settings…") {
                openSettings()
            }
            .keyboardShortcut(",")
            
            Divider()
            
            Button("Quit Squirrel Away") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            let image: NSImage = {
                let img = NSImage(named: "MenuBarIcon")!
                img.isTemplate = true
                return img
            }()
            Image(nsImage: image)
        }
    }
    
    private func openSettings() {
        if let existing = NSApp.windows.first(where: { $0.title == "Squirrel Away Settings" }) {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 360),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Squirrel Away Settings"
        window.contentView = NSHostingView(rootView: SettingsView())
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
