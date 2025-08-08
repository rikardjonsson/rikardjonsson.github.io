//
//  NetworkWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class NetworkWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: NetworkContent
    
    let title = "NETWORK_SCAN"
    let category = WidgetCategory.system
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = NetworkContent()
    }
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(NetworkConfigurationView())
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    VStack(spacing: 4) {
                        Image(systemName: content.isConnected ? "wifi" : "wifi.slash")
                            .font(.title2)
                            .foregroundColor(content.isConnected ? .green : .red)
                        Text(content.signalStrength)
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                    }
                case .medium:
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "wifi")
                                .font(.title2)
                                .foregroundColor(theme.accentColor)
            Text("NET_SCAN")
                                .font(.system(.headline, design: .monospaced))
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                            Circle()
                                .fill(content.isConnected ? .green : .red)
                                .frame(width: 8, height: 8)
                        }
                        
                        VStack(spacing: 4) {
                            Text(content.networkName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(theme.textPrimary)
                            Text("Signal: \(content.signalStrength)")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                            Text("Speed: \(content.downloadSpeed) Mbps")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                        }
                        Spacer()
                    }
                case .large:
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "wifi")
                                .font(.title)
                                .foregroundColor(theme.accentColor)
                            Text("Network Status")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            networkRow("Network", value: content.networkName, theme: theme)
                            networkRow("Status", value: content.isConnected ? "Connected" : "Disconnected", theme: theme)
                            networkRow("Signal", value: content.signalStrength, theme: theme)
                            networkRow("Download", value: "\(content.downloadSpeed) Mbps", theme: theme)
                            networkRow("Upload", value: "\(content.uploadSpeed) Mbps", theme: theme)
                            networkRow("Ping", value: "\(content.ping) ms", theme: theme)
                        }
                        Spacer()
                    }
                case .xlarge:
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "wifi")
                                .font(.largeTitle)
                                .foregroundColor(theme.accentColor)
                            Text("Network Monitor")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                            Circle()
                                .fill(content.isConnected ? .green : .red)
                                .frame(width: 16, height: 16)
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Connection")
                                    .font(.headline)
                                    .foregroundColor(theme.textPrimary)
                                networkRow("Network", value: content.networkName, theme: theme)
                                networkRow("Status", value: content.isConnected ? "Connected" : "Disconnected", theme: theme)
                                networkRow("Signal", value: content.signalStrength, theme: theme)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Performance")
                                    .font(.headline)
                                    .foregroundColor(theme.textPrimary)
                                networkRow("Download", value: "\(content.downloadSpeed) Mbps", theme: theme)
                                networkRow("Upload", value: "\(content.uploadSpeed) Mbps", theme: theme)
                                networkRow("Ping", value: "\(content.ping) ms", theme: theme)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private func networkRow(_ label: String, value: String, theme: any Theme) -> some View {
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
}

@MainActor
final class NetworkContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var isConnected: Bool = true
    @Published var networkName: String = "Home WiFi"
    @Published var signalStrength: String = "Strong"
    @Published var downloadSpeed: Int = 150
    @Published var uploadSpeed: Int = 25
    @Published var ping: Int = 12
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    func refresh() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 1_000_000_000)
        generateMockData()
        lastUpdated = Date()
        isLoading = false
    }
    
    private func generateMockData() {
        let networks = ["Home WiFi", "Office Network", "Coffee Shop", "iPhone Hotspot"]
        let strengths = ["Excellent", "Strong", "Fair", "Weak"]
        
        isConnected = Bool.random() ? true : Double.random(in: 0...1) > 0.1 // 90% connected
        networkName = networks.randomElement() ?? "WiFi Network"
        signalStrength = strengths.randomElement() ?? "Good"
        downloadSpeed = Int.random(in: 50...200)
        uploadSpeed = Int.random(in: 10...50)
        ping = Int.random(in: 5...30)
    }
}

struct NetworkConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Network Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            Text("Shows WiFi connection status and network performance metrics.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}