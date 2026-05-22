import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Only hide other apps when Finder is brought forward", isOn: $settings.finderOnlyMode)
            Toggle("Launch at login", isOn: $settings.launchAtLogin)
            
            Divider()
            
            Text("Never hide these apps:")
                .font(.headline)
            
            // The list of excluded apps. Empty state when none.
            if settings.excludedApps.isEmpty {
                Text("No apps excluded yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .frame(minHeight: 120)
            } else {
                List {
                    ForEach(settings.excludedApps) { app in
                        HStack {
                            // Show the app's actual icon if we can find it.
                            if let icon = appIcon(for: app.bundleIdentifier) {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "app.dashed")
                                    .frame(width: 24, height: 24)
                            }
                            Text(app.displayName)
                            Spacer()
                            Button {
                                settings.remove(app)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.bordered)
                .frame(minHeight: 200)
            }
            
            HStack {
                Spacer()
                Button("Add App…") {
                    addAppViaFilePicker()
                }
            }
        }
        .padding()
        .frame(width: 420, height: 360)
    }
    
    // Open a file picker rooted at /Applications, let the user pick a .app bundle,
    // then extract its bundle ID and display name.
    private func addAppViaFilePicker() {
        let panel = NSOpenPanel()
        panel.title = "Choose an app to never hide"
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            guard let bundle = Bundle(url: url),
                  let bundleID = bundle.bundleIdentifier else {
                return
            }
            let displayName = FileManager.default.displayName(atPath: url.path)
                .replacingOccurrences(of: ".app", with: "")
            
            settings.add(ExcludedApp(bundleIdentifier: bundleID, displayName: displayName))
        }
    }
    
    // Look up an app's icon by its bundle ID, so the list looks nice.
    private func appIcon(for bundleID: String) -> NSImage? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
}

#Preview {
    SettingsView()
}
