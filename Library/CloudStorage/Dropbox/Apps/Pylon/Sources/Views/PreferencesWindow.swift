//
//  PreferencesWindow.swift
//  Pylon
//
//  Created on 08.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

struct PreferencesWindow: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("General")
                }
                .tag(0)
            
            AppearancePreferencesView()
                .tabItem {
                    Image(systemName: "paintbrush")
                    Text("Appearance")
                }
                .tag(1)
            
            WidgetsPreferencesView()
                .tabItem {
                    Image(systemName: "square.grid.3x3")
                    Text("Widgets")
                }
                .tag(2)
            
            AdvancedPreferencesView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Advanced")
                }
                .tag(3)
        }
        .frame(width: 600, height: 500)
    }
}

struct GeneralPreferencesView: View {
    @AppStorage("refreshInterval") private var refreshInterval: Double = 300.0
    @AppStorage("startAtLogin") private var startAtLogin: Bool = false
    @AppStorage("showInDock") private var showInDock: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General Preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Refresh Interval:")
                        .frame(width: 120, alignment: .trailing)
                    
                    Slider(value: $refreshInterval, in: 60...3600, step: 60) {
                        Text("Refresh Interval")
                    } minimumValueLabel: {
                        Text("1m")
                    } maximumValueLabel: {
                        Text("1h")
                    }
                    .frame(width: 200)
                    
                    Text("\(Int(refreshInterval / 60))m")
                        .frame(width: 40, alignment: .leading)
                        .monospacedDigit()
                }
                
                Toggle("Start at Login", isOn: $startAtLogin)
                    .toggleStyle(.checkbox)
                
                Toggle("Show in Dock", isOn: $showInDock)
                    .toggleStyle(.checkbox)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct AppearancePreferencesView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Appearance Preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme:")
                    .font(.headline)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(["Native macOS", "Dark", "Light", "Auto"], id: \.self) { themeName in
                        Button(action: {
                            // TODO: Implement theme switching
                        }) {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themePreviewColor(for: themeName))
                                    .frame(height: 60)
                                
                                Text(themeName)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func themePreviewColor(for theme: String) -> Color {
        switch theme {
        case "Native macOS": return .accentColor
        case "Dark": return .black
        case "Light": return .white
        case "Auto": return .gray
        default: return .clear
        }
    }
}

struct WidgetsPreferencesView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Widget Preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(appState.widgetManager.containers, id: \.id) { container in
                        HStack {
                            Image(systemName: iconForWidget(container.title))
                                .frame(width: 24, height: 24)
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(container.title)
                                    .font(.headline)
                                Text(container.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: .constant(container.isEnabled))
                                .toggleStyle(.switch)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func iconForWidget(_ title: String) -> String {
        switch title.lowercased() {
        case "calendar": return "calendar"
        case "clock": return "clock"
        case "weather": return "cloud.sun"
        case "reminders": return "checklist"
        case "notes": return "note.text"
        case "email": return "envelope"
        default: return "app.dashed"
        }
    }
}

struct AdvancedPreferencesView: View {
    @AppStorage("debugMode") private var debugMode: Bool = false
    @AppStorage("performanceMode") private var performanceMode: Bool = false
    @AppStorage("gridSpacing") private var gridSpacing: Double = 8.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Advanced Preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Debug Mode", isOn: $debugMode)
                    .toggleStyle(.checkbox)
                
                Toggle("Performance Mode", isOn: $performanceMode)
                    .toggleStyle(.checkbox)
                
                HStack {
                    Text("Grid Spacing:")
                        .frame(width: 120, alignment: .trailing)
                    
                    Slider(value: $gridSpacing, in: 4...20, step: 2) {
                        Text("Grid Spacing")
                    }
                    .frame(width: 200)
                    
                    Text("\(Int(gridSpacing))px")
                        .frame(width: 40, alignment: .leading)
                        .monospacedDigit()
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reset Options")
                        .font(.headline)
                    
                    Button("Reset All Preferences") {
                        // TODO: Implement preference reset
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Reset Widget Layout") {
                        // TODO: Implement layout reset
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PreferencesWindow()
        .environmentObject(AppState())
}