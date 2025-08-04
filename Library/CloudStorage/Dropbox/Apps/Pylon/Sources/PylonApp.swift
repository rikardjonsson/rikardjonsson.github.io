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
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
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
