//
//  ClockWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Clock widget showing current time and date
/// Demonstrates real-time updates and multiple display formats
@MainActor
final class ClockWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .small
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: ClockContent
    
    // MARK: - Widget Metadata
    
    let title = "Clock"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = ClockContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(ClockConfigurationView())
    }
    
    // MARK: - Main Widget View
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    smallLayout(theme: theme)
                case .medium:
                    mediumLayout(theme: theme)
                case .large:
                    largeLayout(theme: theme)
                case .xlarge:
                    xlargeLayout(theme: theme)
                }
            }
        )
    }
    
    // MARK: - Size-Specific Layouts
    
    private func smallLayout(theme: any Theme) -> some View {
        VStack(spacing: 2) {
            Text(content.currentTime)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
                .monospacedDigit()
            
            Text(content.currentDate)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Clock")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 4) {
                Text(content.currentTime)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                    .monospacedDigit()
                
                Text(content.currentDate)
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Current Time")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                Text(content.currentTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    .monospacedDigit()
                
                Text(content.currentDate)
                    .font(.title3)
                    .foregroundColor(theme.textSecondary)
                
                Text(content.timezone)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary.opacity(0.8))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.largeTitle)
                            .foregroundColor(theme.accentColor)
                        Text("World Clock")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                    }
                    Text("Multiple time zones and formats")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                Spacer()
            }
            
            // Main time display
            VStack(spacing: 12) {
                Text(content.currentTime)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    .monospacedDigit()
                
                Text(content.currentDate)
                    .font(.title2)
                    .foregroundColor(theme.textSecondary)
            }
            
            // Additional time zones
            HStack(spacing: 20) {
                timeZoneCard("New York", time: formatTimeForZone("America/New_York"), theme: theme)
                timeZoneCard("London", time: formatTimeForZone("Europe/London"), theme: theme)
                timeZoneCard("Tokyo", time: formatTimeForZone("Asia/Tokyo"), theme: theme)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func timeZoneCard(_ city: String, time: String, theme: any Theme) -> some View {
        VStack(spacing: 4) {
            Text(city)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            Text(time)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(theme.textPrimary)
                .monospacedDigit()
        }
        .padding(12)
        .background(theme.cardBackground.opacity(0.3))
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
    
    private func formatTimeForZone(_ identifier: String) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: identifier)
        return formatter.string(from: Date())
    }
}

// MARK: - Clock Content

@MainActor
final class ClockContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var currentTime: String = ""
    @Published var currentDate: String = ""
    @Published var timezone: String = ""
    
    @MainActor
    private var timer: Timer?
    
    init() {
        updateTime()
        Task { @MainActor in
            startTimer()
        }
    }
    
    deinit {
        // Timer cleanup handled by MainActor deallocation
    }
    
    @MainActor
    func refresh() async throws {
        updateTime()
        lastUpdated = Date()
    }
    
    @MainActor
    private func startTimer() {
        // Update every 30 seconds instead of every second to reduce AttributeGraph pressure
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTime()
            }
        }
    }
    
    private func updateTime() {
        let now = Date()
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        timeFormatter.dateStyle = .none
        currentTime = timeFormatter.string(from: now)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        currentDate = dateFormatter.string(from: now)
        
        timezone = TimeZone.current.identifier
        lastUpdated = now
    }
}

// MARK: - Configuration View

struct ClockConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Clock Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows current time and date with real-time updates.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Future configuration options could include:
            // - 12/24 hour format
            // - Timezone selection
            // - Date format preferences
            
            Spacer()
        }
        .padding()
    }
}