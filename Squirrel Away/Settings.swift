import Foundation
import SwiftUI
import Combine
import ServiceManagement

// Represents one excluded app. We store the bundle ID (for matching)
// and the display name (for showing in the UI).
struct ExcludedApp: Codable, Identifiable, Hashable {
    var id: String { bundleIdentifier }   // bundle ID is unique, use it as the identity
    let bundleIdentifier: String
    let displayName: String
}

// A single source of truth for the app's settings.
// ObservableObject lets SwiftUI redraw views automatically when this changes.
class Settings: ObservableObject {
    static let shared = Settings()   // one shared instance for the whole app
    
    // When true, hiding only happens when Finder is activated.
    // When false, hiding happens for every app switch.
    @AppStorage("finderOnlyMode") var finderOnlyMode: Bool = false
    
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet { applyLaunchAtLogin() }
    }
    
    @Published var excludedApps: [ExcludedApp] {
        didSet { save() }   // whenever the list changes, save it to disk
    }
    
    private let storageKey = "excludedApps"
    
    private init() {
        // Load from UserDefaults when the app starts.
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ExcludedApp].self, from: data) {
            self.excludedApps = decoded
        } else {
            self.excludedApps = []
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(excludedApps) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // Helpers for adding/removing.
    func add(_ app: ExcludedApp) {
        guard !excludedApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) else { return }
        excludedApps.append(app)
    }
    
    func remove(_ app: ExcludedApp) {
        excludedApps.removeAll { $0.bundleIdentifier == app.bundleIdentifier }
    }
    
    // Quick check used by AppHider.
    func isExcluded(bundleID: String?) -> Bool {
        guard let bundleID else { return false }
        return excludedApps.contains(where: { $0.bundleIdentifier == bundleID })
    }
    
    // Register or unregister the app to launch at login.
    func applyLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if launchAtLogin {
                if service.status == .enabled { return }
                try service.register()
            } else {
                if service.status == .notRegistered { return }
                try service.unregister()
            }
        } catch {
            print("Launch at login error: \(error.localizedDescription)")
        }
    }

    // Sync the toggle state to match what the system actually has registered.
    // Call this once at app launch in case the user changed it elsewhere.
    func syncLaunchAtLoginState() {
        let isRegistered = SMAppService.mainApp.status == .enabled
        if launchAtLogin != isRegistered {
            // Update without triggering didSet to avoid a redundant register/unregister call.
            UserDefaults.standard.set(isRegistered, forKey: "launchAtLogin")
        }
    }
}
