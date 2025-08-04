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
            appState.selectedTheme.backgroundStyle
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
        VStack(spacing: 16) {
            Text("Welcome to Pylon")
                .font(.title)
                .foregroundColor(theme.textPrimary)

            Text("Your productivity widgets will appear here once the widget system is implemented.")
                .font(.body)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Placeholder widget grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(0 ..< 6, id: \.self) { index in
                    PlaceholderWidgetView(title: "Widget \(index + 1)")
                }
            }
            .padding(.top, 20)
        }
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
