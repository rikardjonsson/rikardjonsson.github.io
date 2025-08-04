//
//  ContentView.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            // Background with material effect
            Rectangle()
                .fill(appState.selectedTheme.backgroundMaterial)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HeaderView()

                // Main content area
                MainContentView()

                Spacer()

                // Footer with theme toggle
                FooterView()
            }
            .padding()
        }
        .environment(\.theme, appState.selectedTheme)
    }
}

// MARK: - Header View

struct HeaderView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pylon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)

                Text("Your productivity dashboard")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)

                Text("life is a circle because no one learns anything")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary.opacity(0.8))
                    .italic()
            }

            Spacer()

            // Refresh button
            Button(action: {
                Task {
                    await appState.refreshAllWidgets()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(appState.isRefreshing)
            .opacity(appState.isRefreshing ? 0.6 : 1.0)
        }
        .padding(.horizontal)
    }
}

// MARK: - Main Content View

struct MainContentView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if appState.widgetManager.containers.isEmpty {
                    // Welcome state
                    welcomeView
                } else {
                    // Widget grid
                    widgetGridView
                }
            }
            .padding(appState.widgetManager.gridConfiguration.padding)
        }
    }

    private var welcomeView: some View {
        VStack(spacing: 20) {
            Text("Welcome to Pylon")
                .font(.title)
                .foregroundColor(theme.textPrimary)

            Text("Container-based widget system with dynamic sizing")
                .font(.body)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)

            Button("Add Sample Widget") {
                addSampleWidget()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            // Show sample widgets in different sizes for demonstration
            sampleWidgetShowcase
        }
    }

    private var widgetGridView: some View {
        let config = appState.widgetManager.gridConfiguration
        let columns = Array(repeating: GridItem(.flexible(), spacing: config.spacing), count: config.columns)

        return LazyVGrid(columns: columns, spacing: config.spacing) {
            ForEach(appState.widgetManager.enabledContainers(), id: \.id) { container in
                AnyView(
                    WidgetContainerView(
                        container: container,
                        theme: theme,
                        gridUnit: config.gridUnit,
                        spacing: config.spacing
                    )
                )
            }
        }
    }

    private var sampleWidgetShowcase: some View {
        VStack(spacing: 16) {
            Text("Widget Sizes")
                .font(.headline)
                .foregroundColor(theme.textPrimary)

            HStack(spacing: 12) {
                ForEach(WidgetSize.allCases, id: \.self) { size in
                    let sampleWidget = createSampleWidget(size: size)

                    WidgetContainerView(
                        container: sampleWidget,
                        theme: theme,
                        gridUnit: 80, // Smaller for showcase
                        spacing: 8
                    )
                    .scaleEffect(0.7)
                }
            }
        }
        .padding(.top, 20)
    }

    private func addSampleWidget() {
        let sampleWidget = SampleWidget()
        appState.widgetManager.registerContainer(sampleWidget)
    }

    private func createSampleWidget(size: WidgetSize) -> SampleWidget {
        let widget = SampleWidget()
        widget.size = size
        return widget
    }
}

// MARK: - Placeholder Widget View

struct PlaceholderWidgetView: View {
    let title: String
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.grid.2x2")
                .font(.title)
                .foregroundColor(theme.accentColor)

            Text(title)
                .font(.headline)
                .foregroundColor(theme.textPrimary)

            Text("Coming soon...")
                .font(.caption)
                .foregroundColor(theme.textSecondary)
        }
        .frame(minHeight: 120)
        .frame(maxWidth: .infinity)
        .background(theme.glassEffect, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Footer View

struct FooterView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack {
            Text("Theme: \(appState.selectedTheme.name)")
                .font(.caption)
                .foregroundColor(theme.textSecondary)

            Spacer()

            Button("Toggle Theme") {
                appState.toggleTheme()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
}
