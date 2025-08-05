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

            VStack(spacing: 12) {
                // Row 1: Core widgets
                HStack(spacing: 8) {
                    Button("Clock") { addClockWidget() }.buttonStyle(.bordered)
                    Button("Weather") { addWeatherWidget() }.buttonStyle(.bordered)
                    Button("Calendar") { addCalendarWidget() }.buttonStyle(.bordered)
                    Button("Reminders") { addRemindersWidget() }.buttonStyle(.bordered)
                }
                
                // Row 2: Information widgets
                HStack(spacing: 8) {
                    Button("Notes") { addNotesWidget() }.buttonStyle(.bordered)
                    Button("Stocks") { addStocksWidget() }.buttonStyle(.bordered)
                    Button("Crypto") { addCryptoWidget() }.buttonStyle(.bordered)
                    Button("News") { addNewsWidget() }.buttonStyle(.bordered)
                }
                
                // Row 3: Communication & Finance
                HStack(spacing: 8) {
                    Button("Email") { addEmailWidget() }.buttonStyle(.bordered)
                    Button("Finance") { addFinanceWidget() }.buttonStyle(.bordered)
                    Button("Social") { addSocialWidget() }.buttonStyle(.bordered)
                    Button("Fitness") { addFitnessWidget() }.buttonStyle(.bordered)
                }
                
                // Row 4: Entertainment & Travel
                HStack(spacing: 8) {
                    Button("Music") { addMusicWidget() }.buttonStyle(.bordered)
                    Button("Photos") { addPhotosWidget() }.buttonStyle(.bordered)
                    Button("Podcast") { addPodcastWidget() }.buttonStyle(.bordered)
                    Button("Travel") { addTravelWidget() }.buttonStyle(.bordered)
                }
                
                // Row 5: Activity & System
                HStack(spacing: 8) {
                    Button("Activity") { addActivityWidget() }.buttonStyle(.bordered)
                    Button("Network") { addNetworkWidget() }.buttonStyle(.bordered)
                    Button("System") { addSystemMonitorWidget() }.buttonStyle(.bordered)
                    Button("Shopping") { addShoppingWidget() }.buttonStyle(.bordered)
                }
            }

            // Show sample widgets in different sizes for demonstration
            sampleWidgetShowcase
        }
    }

    private var widgetGridView: some View {
        let config = appState.widgetManager.gridConfiguration
        let enabledContainers = appState.widgetManager.enabledContainers()
        
        return DraggableGridView(
            gridConfig: config,
            containers: enabledContainers
        )
        .frame(minHeight: 400) // Ensure minimum height for proper interaction
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
    
    private func addClockWidget() {
        let clockWidget = ClockWidget()
        appState.widgetManager.registerContainer(clockWidget)
    }
    
    private func addWeatherWidget() {
        let weatherWidget = WeatherWidget()
        appState.widgetManager.registerContainer(weatherWidget)
    }
    
    private func addSystemMonitorWidget() {
        let systemWidget = SystemMonitorWidget()
        appState.widgetManager.registerContainer(systemWidget)
    }
    
    private func addCalendarWidget() {
        let calendarWidget = CalendarWidget()
        appState.widgetManager.registerContainer(calendarWidget)
    }
    
    private func addRemindersWidget() {
        let remindersWidget = RemindersWidget()
        appState.widgetManager.registerContainer(remindersWidget)
    }
    
    private func addNotesWidget() {
        let notesWidget = NotesWidget()
        appState.widgetManager.registerContainer(notesWidget)
    }
    
    private func addStocksWidget() {
        let stocksWidget = StocksWidget()
        appState.widgetManager.registerContainer(stocksWidget)
    }
    
    private func addCryptoWidget() {
        let cryptoWidget = CryptoWidget()
        appState.widgetManager.registerContainer(cryptoWidget)
    }
    
    private func addNewsWidget() {
        let newsWidget = NewsWidget()
        appState.widgetManager.registerContainer(newsWidget)
    }
    
    private func addMusicWidget() {
        let musicWidget = MusicWidget()
        appState.widgetManager.registerContainer(musicWidget)
    }
    
    private func addPhotosWidget() {
        let photosWidget = PhotosWidget()
        appState.widgetManager.registerContainer(photosWidget)
    }
    
    private func addActivityWidget() {
        let activityWidget = ActivityWidget()
        appState.widgetManager.registerContainer(activityWidget)
    }
    
    private func addNetworkWidget() {
        let networkWidget = NetworkWidget()
        appState.widgetManager.registerContainer(networkWidget)
    }
    
    private func addEmailWidget() {
        let emailWidget = EmailWidget()
        appState.widgetManager.registerContainer(emailWidget)
    }
    
    private func addFinanceWidget() {
        let financeWidget = FinanceWidget()
        appState.widgetManager.registerContainer(financeWidget)
    }
    
    private func addSocialWidget() {
        let socialWidget = SocialWidget()
        appState.widgetManager.registerContainer(socialWidget)
    }
    
    private func addFitnessWidget() {
        let fitnessWidget = FitnessWidget()
        appState.widgetManager.registerContainer(fitnessWidget)
    }
    
    private func addPodcastWidget() {
        let podcastWidget = PodcastWidget()
        appState.widgetManager.registerContainer(podcastWidget)
    }
    
    private func addTravelWidget() {
        let travelWidget = TravelWidget()
        appState.widgetManager.registerContainer(travelWidget)
    }
    
    private func addShoppingWidget() {
        let shoppingWidget = ShoppingWidget()
        appState.widgetManager.registerContainer(shoppingWidget)
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
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
}
