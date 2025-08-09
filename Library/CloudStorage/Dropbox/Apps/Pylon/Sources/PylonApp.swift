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
    @State private var showingAbout = false
    @State private var showingPreferences = false
    @State private var showingQuickAdd = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .sheet(isPresented: $showingAbout) {
                    AboutWindow()
                }
                .sheet(isPresented: $showingPreferences) {
                    PreferencesWindow()
                        .environmentObject(appState)
                }
                .sheet(isPresented: $showingQuickAdd) {
                    QuickAddWindow()
                        .environmentObject(appState)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize) // Allow resizing in both directions
        .defaultSize(width: 1200, height: 800) // Better default size for widget layout
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Pylon") {
                    showingAbout = true
                }
            }
            CommandGroup(after: .appInfo) {
                Divider()
                Button("Preferences...") {
                    showingPreferences = true
                }
                .keyboardShortcut(",")
            }
            CommandGroup(after: .newItem) {
                Button("Quick Add...") {
                    showingQuickAdd = true
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
