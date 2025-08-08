//
//  PylonApp.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

@main
struct PylonApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize) // Allow resizing in both directions
        .defaultSize(width: 1200, height: 800) // Better default size for widget layout
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Pylon") {
                    // TODO: Show about window
                }
            }
            CommandGroup(after: .appInfo) {
                Divider()
                Button("Preferences...") {
                    // TODO: Show preferences
                }
                .keyboardShortcut(",")
            }
            CommandGroup(after: .newItem) {
                Button("Quick Add...") {
                    // TODO: Show quick add
                }
                .keyboardShortcut("n")

                Button("Refresh All") {
                    Task {
                        await appState.refreshAllWidgets()
                    }
                }
                .keyboardShortcut("r")
            }
        }
    }
}
