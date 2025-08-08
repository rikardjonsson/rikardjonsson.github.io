//
//  WeatherWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Weather widget showing current conditions
/// Demonstrates mock data patterns for external API integration
@MainActor
final class WeatherWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: WeatherContent
    
    // MARK: - Widget Metadata
    
    let title = "Weather"
    let category = WidgetCategory.information
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = WeatherContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(WeatherConfigurationView())
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
        VStack(spacing: 4) {
            Image(systemName: content.weatherData.icon)
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text("\(content.weatherData.temperature)°")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            
            Text(content.weatherData.location)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        HStack(spacing: 12) {
            Image(systemName: content.weatherData.icon)
                .font(.system(size: 32))
                .foregroundColor(theme.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(content.weatherData.temperature)°")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Text(content.weatherData.condition)
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)
                
                Text(content.weatherData.location)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary.opacity(0.8))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "cloud.sun")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Weather")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: content.weatherData.icon)
                        .font(.system(size: 48))
                        .foregroundColor(theme.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text("\(content.weatherData.temperature)°")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(theme.textPrimary)
                        
                        Text(content.weatherData.condition)
                            .font(.headline)
                            .foregroundColor(theme.textSecondary)
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 6) {
                    weatherDetail("Location", value: content.weatherData.location, theme: theme)
                    weatherDetail("Humidity", value: "\(content.weatherData.humidity)%", theme: theme)
                    weatherDetail("Wind", value: content.weatherData.windSpeed, theme: theme)
                }
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
                        Image(systemName: "cloud.sun")
                            .font(.largeTitle)
                            .foregroundColor(theme.accentColor)
                        Text("Weather Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                    }
                    Text("Current conditions and forecast")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                Spacer()
            }
            
            // Main weather display
            HStack(spacing: 24) {
                // Current weather
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: content.weatherData.icon)
                            .font(.system(size: 80))
                            .foregroundColor(theme.accentColor)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(content.weatherData.temperature)°")
                                .font(.system(size: 64, weight: .bold))
                                .foregroundColor(theme.textPrimary)
                            
                            Text(content.weatherData.condition)
                                .font(.title2)
                                .foregroundColor(theme.textSecondary)
                            
                            Text(content.weatherData.location)
                                .font(.subheadline)
                                .foregroundColor(theme.textSecondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Weather details grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        weatherCard("Humidity", value: "\(content.weatherData.humidity)%", icon: "drop", theme: theme)
                        weatherCard("Wind", value: content.weatherData.windSpeed, icon: "wind", theme: theme)
                        weatherCard("Feels Like", value: "\(content.weatherData.temperature + Int.random(in: -3...3))°", icon: "thermometer", theme: theme)
                        weatherCard("UV Index", value: "5", icon: "sun.max", theme: theme)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    // MARK: - Helper Views
    
    private func weatherDetail(_ label: String, value: String, theme: any Theme) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
        }
    }
    
    private func weatherCard(_ label: String, value: String, icon: String, theme: any Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
        }
        .padding(16)
        .background(theme.surfaceSecondary.opacity(0.3))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Weather Data Model

struct WeatherData {
    let temperature: Int
    let feelsLike: Int
    let condition: String
    let icon: String
    let location: String
    let humidity: Int
    let windSpeed: String
    let pressure: String
}

// MARK: - Weather Content

@MainActor
final class WeatherContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var weatherData: WeatherData
    
    init() {
        // Mock data - in real implementation, this would come from WeatherKit or another API
        weatherData = WeatherData(
            temperature: 22,
            feelsLike: 25,
            condition: "Partly Cloudy",
            icon: "cloud.sun",
            location: "Stockholm, Sweden",
            humidity: 65,
            windSpeed: "8 km/h",
            pressure: "1013 hPa"
        )
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            // Simulate API call
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Mock updated data
            let temperatures = [18, 19, 20, 21, 22, 23, 24, 25]
            let conditions = [
                ("Sunny", "sun.max"),
                ("Partly Cloudy", "cloud.sun"),
                ("Cloudy", "cloud"),
                ("Rainy", "cloud.rain")
            ]
            
            let randomTemp = temperatures.randomElement() ?? 22
            let randomCondition = conditions.randomElement() ?? ("Partly Cloudy", "cloud.sun")
            
            weatherData = WeatherData(
                temperature: randomTemp,
                feelsLike: randomTemp + Int.random(in: -2...4),
                condition: randomCondition.0,
                icon: randomCondition.1,
                location: "Stockholm, Sweden",
                humidity: Int.random(in: 40...80),
                windSpeed: "\(Int.random(in: 0...15)) km/h",
                pressure: "\(Int.random(in: 995...1025)) hPa"
            )
            
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
}

// MARK: - Configuration View

struct WeatherConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Weather Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows current weather conditions with mock data. In a real implementation, this would integrate with WeatherKit or another weather API.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Future configuration options could include:
            // - Location selection
            // - Temperature units (C/F)
            // - Update frequency
            // - Weather service provider
            
            Spacer()
        }
        .padding()
    }
}