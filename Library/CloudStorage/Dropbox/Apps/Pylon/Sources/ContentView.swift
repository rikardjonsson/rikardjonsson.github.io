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
        // Always use native macOS content view with TetrisGrid
        // TODO: Implement theme-specific styling within NativeContentView
        NativeContentView()
            .environment(\.theme, appState.selectedTheme)
    }
    
    // MARK: - Legacy Content View (for non-native themes)
    
    private var legacyContentView: some View {
        VStack(spacing: 0) {
            // Top bar with title and toolbar
            TopBarView()
                .background(appState.selectedTheme.backgroundMaterial.opacity(0.8))
                .overlay(
                    Rectangle()
                        .fill(appState.selectedTheme.accentColor.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
            
            // Main content area
            ZStack {
                // Sophisticated charcoal background
                Rectangle()
                    .fill(Color(red: 0.04, green: 0.04, blue: 0.069))
                    .ignoresSafeArea()

                MainContentView()
                
                // Scan lines effect
                scanLinesOverlay()
                
                // Surveillance overlays
                surveillanceOverlay()
            }
        }
    }
    
    // MARK: - Surveillance Overlay
    
    private func surveillanceOverlay() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                // System timestamp
                VStack(alignment: .trailing, spacing: 2) {
                    Text("SYS_TIME")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(appState.selectedTheme.accentColor.opacity(0.7))
                    Text(currentTimestamp())
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(appState.selectedTheme.accentColor)
                    Text("STATUS: ONLINE")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.green)
                        .opacity(0.8)
                }
                .padding(.horizontal, 16) // 8pt grid system
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.ultraThinMaterial) // Enhanced glass effect
                        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    appState.selectedTheme.accentColor.opacity(0.4),
                                    appState.selectedTheme.accentColor.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
            }
            .padding(.trailing, 16) // 8pt grid system
            .padding(.bottom, 16)    // 8pt grid system
        }
    }
    
    private func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
    
    // MARK: - Scan Lines Effect
    
    private func scanLinesOverlay() -> some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        appState.selectedTheme.ambientGlow.opacity(0.03),
                        appState.selectedTheme.contextualAccent.opacity(0.02),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
            )
            .mask(
                VStack(spacing: 8) { // Golden ratio inspired spacing
                    ForEach(0..<35, id: \.self) { index in
                        Rectangle()
                            .frame(height: 0.33) // Even thinner for ultra-subtlety
                            .opacity(sin(Double(index) * 0.1) * 0.04 + 0.02) // Subtle wave pattern
                    }
                }
            )
            .blendMode(.overlay) // Sophisticated blend mode
            .allowsHitTesting(false)
    }
}

// MARK: - Top Bar View

struct TopBarView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var appState: AppState
    @State private var currentMessageIndex = 0
    @State private var timer: Timer?
    
    private let philosophicalMessages = [
        "Life's a loop because no one learns anything",
        "The reward for surviving is doing it again tomorrow",
        "Rest is just the pause before more effort",
        "You survive the storm and return to the forecast",
        "Every finish line is just the start of the next task",
        "The prize for holding it together is holding more",
        "You don't escape the cycle; you decorate it"
    ]

    var body: some View {
        HStack {
            // Fluid title section with responsive typography
            VStack(alignment: .leading, spacing: 3) {
                Text("Pylon")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                theme.textPrimary,
                                theme.textPrimary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: theme.ambientGlow.opacity(0.1), radius: 2, x: 0, y: 1)

                Text(philosophicalMessages[currentMessageIndex])
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                theme.contextualAccent.opacity(0.9),
                                theme.contextualAccent.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentMessageIndex)
            }

            Spacer()

            // Toolbar buttons
            HStack(spacing: 8) {
                // Morphing add widget button
                Menu {
                    Button("TEMPORAL_MONITOR") { addClockWidget() }
                    Button("ATMOSPHERIC_SCAN") { addWeatherWidget() }  
                    Button("SCHEDULE_TRACK") { addCalendarWidget() }
                    Button("TASK_MONITOR") { addRemindersWidget() }
                    Button("DATA_ARCHIVE") { addNotesWidget() }
                    Divider()
                    Button("SYSTEM_STATUS") { addSystemMonitorWidget() }
                    Button("BIOMETRIC_SCAN") { addFitnessWidget() }
                    Button("ASSET_TRACK") { addFinanceWidget() }
                    Button("COMM_INTERCEPT") { addEmailWidget() }
                    Divider()
                    Button("MARKET_WATCH") { addStocksWidget() }
                    Button("CRYPTO_TRACE") { addCryptoWidget() }
                    Button("INFO_FEED") { addNewsWidget() }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.depthLayer2)
                            .frame(width: 32, height: 32)
                            .shadow(color: theme.ambientGlow.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "plus")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        theme.contextualAccent,
                                        theme.contextualAccent.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .buttonStyle(.plain)
                .help("DEPLOY NEW FEED")
                
                // Fluid refresh button
                Button(action: {
                    Task {
                        await appState.refreshAllWidgets()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.depthLayer2)
                            .frame(width: 32, height: 32)
                            .shadow(color: theme.ambientGlow.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: appState.isRefreshing ? "antenna.radiowaves.left.and.right" : "arrow.triangle.2.circlepath")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        appState.isRefreshing ? theme.contextualAccent : theme.accentColor,
                                        (appState.isRefreshing ? theme.contextualAccent : theme.accentColor).opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(appState.isRefreshing ? 360 : 0))
                            .animation(
                                appState.isRefreshing ? 
                                .linear(duration: 1.2).repeatForever(autoreverses: false) : 
                                .spring(response: 0.4, dampingFraction: 0.7), 
                                value: appState.isRefreshing
                            )
                    }
                }
                .buttonStyle(.plain)
                .disabled(appState.isRefreshing)
                .help("RESYNC ALL FEEDS")
            }
        }
        .padding(.horizontal, 16) // 8pt grid system
        .padding(.vertical, 12)   // Adjusted for better visual rhythm
        .onAppear {
            startMessageRotation()
        }
        .onDisappear {
            stopMessageRotation()
        }
    }
    
    private func startMessageRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in // Even more relaxed
            withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0)) { // Spring physics for text
                currentMessageIndex = (currentMessageIndex + 1) % philosophicalMessages.count
            }
        }
    }
    
    private func stopMessageRotation() {
        timer?.invalidate()
        timer = nil
    }
    
    // Widget creation methods
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
    
    private func addEmailWidget() {
        let emailWidget = EmailWidget()
        appState.widgetManager.registerContainer(emailWidget)
    }
    
    private func addFinanceWidget() {
        let financeWidget = FinanceWidget()
        appState.widgetManager.registerContainer(financeWidget)
    }
    
    private func addFitnessWidget() {
        let fitnessWidget = FitnessWidget()
        appState.widgetManager.registerContainer(fitnessWidget)
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
            .padding(.top, 8)
            .padding(.horizontal, appState.widgetManager.gridConfiguration.padding.leading)
        }
    }

    private var welcomeView: some View {
        VStack(spacing: 48) { // Golden ratio spacing
            VStack(spacing: 24) {
                Text("Welcome to Pylon")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                theme.textPrimary,
                                theme.contextualAccent.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: theme.ambientGlow.opacity(0.2), radius: 4, x: 0, y: 2)

                Text("Hyper-fluid widget ecosystem with intelligent morphing")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                theme.textSecondary,
                                theme.textSecondary.opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(theme.contextualAccent)
                        .shadow(color: theme.ambientGlow.opacity(0.3), radius: 2, x: 0, y: 0)
                    
                    Text("Deploy your first surveillance feed above")
                        .font(.system(.callout, design: .rounded, weight: .medium))
                        .foregroundColor(theme.contextualAccent)
                        .multilineTextAlignment(.center)
                }
                .opacity(0.9)
            }

            // Enhanced sample widget showcase
            fluidSampleWidgetShowcase
        }
        .padding(.top, 80) // More breathing room
    }

    private var widgetGridView: some View {
        TetrisGrid(
            widgets: convertToGridWidgets(appState.widgetManager.enabledContainers())
        )
        .frame(minHeight: 600) // Allow horizontal resizing, minimum height for content
    }
    
    /// Convert existing widgets to GridWidget protocol
    private func convertToGridWidgets(_ containers: [any WidgetContainer]) -> [any GridWidget] {
        return WidgetAdapterFactory.adapt(containers)
    }

    private var fluidSampleWidgetShowcase: some View {
        VStack(spacing: 24) {
            Text("Adaptive Container Matrix")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            theme.textPrimary,
                            theme.textPrimary.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            HStack(spacing: 16) {
                ForEach(WidgetSize.allCases, id: \.self) { size in
                    let sampleWidget = createSampleWidget(size: size)

                    FluidWidgetContainer(
                        container: sampleWidget,
                        theme: theme,
                        gridUnit: 60, // Optimized for showcase
                        spacing: 6
                    )
                    .scaleEffect(0.6)
                    .shadow(color: theme.ambientGlow.opacity(0.15), radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(.top, 32)
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
