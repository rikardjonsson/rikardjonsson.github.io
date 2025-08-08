//
//  SystemMonitorWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// System monitor widget showing CPU, memory, and disk usage
/// Demonstrates system integration and real-time monitoring
@MainActor
final class SystemMonitorWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: SystemMonitorContent
    
    // MARK: - Widget Metadata
    
    let title = "System Monitor"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = SystemMonitorContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(SystemMonitorConfigurationView())
    }
    
    // MARK: - Main Widget View
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    mediumLayout(theme: theme) // Use medium for small
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
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "cpu")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("System Monitor")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 6) {
                systemMetric("CPU", value: content.systemData.cpuUsage, color: cpuColor(content.systemData.cpuUsage), theme: theme)
                systemMetric("Memory", value: content.systemData.memoryUsage, color: memoryColor(content.systemData.memoryUsage), theme: theme)
                systemMetric("Disk", value: content.systemData.diskUsage, color: diskColor(content.systemData.diskUsage), theme: theme)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "cpu")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("System Monitor")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                systemMetricDetailed("CPU Usage", value: content.systemData.cpuUsage, 
                                   color: cpuColor(content.systemData.cpuUsage), theme: theme)
                systemMetricDetailed("Memory Usage", value: content.systemData.memoryUsage, 
                                   color: memoryColor(content.systemData.memoryUsage), theme: theme)
                systemMetricDetailed("Disk Usage", value: content.systemData.diskUsage, 
                                   color: diskColor(content.systemData.diskUsage), theme: theme)
            }
            
            HStack {
                Text("Uptime: \(content.systemData.uptime)")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                Spacer()
                
                if let lastUpdated = content.lastUpdated {
                    Text("Updated: \(formatTime(lastUpdated))")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "cpu")
                    .font(.largeTitle)
                    .foregroundColor(theme.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Monitor")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                    Text("Real-time Performance")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Processes: \(content.systemData.processCount)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    Text("Load: \(content.systemData.loadAverage)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    Text("Temp: \(content.systemData.temperature)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            VStack(spacing: 16) {
                systemMetricEnhanced("CPU Usage", value: content.systemData.cpuUsage, 
                                   color: cpuColor(content.systemData.cpuUsage), theme: theme)
                systemMetricEnhanced("Memory Usage", value: content.systemData.memoryUsage, 
                                   color: memoryColor(content.systemData.memoryUsage), theme: theme)
                systemMetricEnhanced("Disk Usage", value: content.systemData.diskUsage, 
                                   color: diskColor(content.systemData.diskUsage), theme: theme)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("System Information")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    infoRow("Uptime", value: content.systemData.uptime, theme: theme)
                    infoRow("Load Average", value: content.systemData.loadAverage, theme: theme)
                    infoRow("Temperature", value: content.systemData.temperature, theme: theme)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Statistics")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    infoRow("Processes", value: "\(content.systemData.processCount)", theme: theme)
                    if let lastUpdated = content.lastUpdated {
                        infoRow("Updated", value: formatTime(lastUpdated), theme: theme)
                    }
                    infoRow("Status", value: "Monitoring", theme: theme)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    // MARK: - Helper Views
    
    private func systemMetric(_ label: String, value: Double, color: Color, theme: any Theme) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            
            Spacer()
            
            Text("\(Int(value))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
    
    private func systemMetricDetailed(_ label: String, value: Double, color: Color, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            ProgressView(value: value / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 0.8)
        }
    }
    
    private func systemMetricEnhanced(_ label: String, value: Double, color: Color, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .monospacedDigit()
            }
            
            ProgressView(value: value / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 1.2)
            
            HStack {
                Text(statusText(for: value, type: label))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                Spacer()
                
                Text(usageDescription(value))
                    .font(.caption)
                    .foregroundColor(color)
            }
        }
    }
    
    private func infoRow(_ label: String, value: String, theme: any Theme) -> some View {
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
    
    // MARK: - Helper Methods
    
    private func cpuColor(_ usage: Double) -> Color {
        switch usage {
        case 0..<50: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
    
    private func memoryColor(_ usage: Double) -> Color {
        switch usage {
        case 0..<60: return .green
        case 60..<85: return .orange
        default: return .red
        }
    }
    
    private func diskColor(_ usage: Double) -> Color {
        switch usage {
        case 0..<80: return .green
        case 80..<95: return .orange
        default: return .red
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func statusText(for value: Double, type: String) -> String {
        if type.contains("CPU") {
            switch value {
            case 0..<30: return "Idle"
            case 30..<60: return "Normal"
            case 60..<80: return "Busy"
            default: return "Critical"
            }
        } else if type.contains("Memory") {
            switch value {
            case 0..<50: return "Available"
            case 50..<75: return "Moderate"
            case 75..<90: return "High"
            default: return "Critical"
            }
        } else if type.contains("Disk") {
            switch value {
            case 0..<60: return "Spacious"
            case 60..<85: return "Filling"
            case 85..<95: return "Nearly Full"
            default: return "Critical"
            }
        }
        return "Normal"
    }
    
    private func usageDescription(_ value: Double) -> String {
        switch value {
        case 0..<25: return "Low"
        case 25..<50: return "Moderate"
        case 50..<75: return "High"
        case 75..<90: return "Very High"
        default: return "Critical"
        }
    }
}

// MARK: - System Data Model

struct SystemData {
    let cpuUsage: Double
    let memoryUsage: Double
    let diskUsage: Double
    let uptime: String
    let processCount: Int
    let loadAverage: String
    let temperature: String
}

// MARK: - System Monitor Content

@MainActor
final class SystemMonitorContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var systemData: SystemData
    
    private var timer: Timer?
    
    init() {
        systemData = SystemData(
            cpuUsage: Double.random(in: 10...45),
            memoryUsage: Double.random(in: 30...70),
            diskUsage: Double.random(in: 45...85),
            uptime: "2d 14h 32m",
            processCount: Int.random(in: 200...400),
            loadAverage: "1.2",
            temperature: "45°C"
        )
        lastUpdated = Date()
        startTimer()
    }
    
    deinit {
        // Note: Timer invalidation in deinit may not work reliably with Swift concurrency
        // Consider implementing a proper cleanup method instead
    }
    
    @MainActor
    func refresh() async throws {
        updateSystemData()
        lastUpdated = Date()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateSystemData()
            }
        }
    }
    
    private func updateSystemData() {
        // Mock system data - in real implementation, this would use system APIs
        systemData = SystemData(
            cpuUsage: max(0, min(100, systemData.cpuUsage + Double.random(in: -10...10))),
            memoryUsage: max(0, min(100, systemData.memoryUsage + Double.random(in: -5...5))),
            diskUsage: systemData.diskUsage, // Disk usage changes slowly
            uptime: generateUptime(),
            processCount: Int.random(in: 200...400),
            loadAverage: String(format: "%.1f", Double.random(in: 0.5...3.0)),
            temperature: "\(Int.random(in: 35...55))°C"
        )
        lastUpdated = Date()
    }
    
    private func generateUptime() -> String {
        let components = ["2d 14h 33m", "2d 14h 34m", "2d 14h 35m"]
        return components.randomElement() ?? "2d 14h 32m"
    }
}

// MARK: - Configuration View

struct SystemMonitorConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("System Monitor Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Monitors system resources including CPU, memory, and disk usage. Data is currently mocked for demonstration purposes.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Future configuration options could include:
            // - Update frequency
            // - Alert thresholds
            // - Metric selection
            // - Temperature units
            
            Spacer()
        }
        .padding()
    }
}