import AppKit
import Combine

class AppHider: ObservableObject {
    private var cancellable: AnyCancellable?
    private let settings = Settings.shared
    
    init() {
        cancellable = NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] notification in
                self?.handleAppActivation(notification)
            }
    }
    
    private func handleAppActivation(_ notification: Notification) {
        guard let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }
        
        let ourBundleID = Bundle.main.bundleIdentifier
        
        // If WE are the one being activated, don't treat this as a normal app switch.
        if activatedApp.bundleIdentifier == ourBundleID {
            return
        }
        
        // Shift-key override: holding Shift during an app switch cancels hiding entirely.
        if NSEvent.modifierFlags.contains(.shift) {
            return
        }
        
        // Finder-only mode: only proceed if the activated app is Finder.
        if settings.finderOnlyMode && activatedApp.bundleIdentifier != "com.apple.finder" {
            return
        }
        
        for app in NSWorkspace.shared.runningApplications {
            if app.processIdentifier == activatedApp.processIdentifier { continue }
            if app.bundleIdentifier == ourBundleID { continue }
            if app.activationPolicy != .regular { continue }
            if settings.isExcluded(bundleID: app.bundleIdentifier) { continue }
            
            app.hide()
        }
    }
}
