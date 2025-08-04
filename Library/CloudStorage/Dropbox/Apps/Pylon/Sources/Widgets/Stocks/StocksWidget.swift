//
//  StocksWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Stocks widget showing market prices and trends
/// Demonstrates financial data with mock stock market information
@MainActor
final class StocksWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    @Published private var content: StocksContent
    
    // MARK: - Widget Metadata
    
    let title = "Stocks"
    let category = WidgetCategory.information
    let supportedSizes: [WidgetSize] = [.medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = StocksContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(StocksConfigurationView())
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
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Stocks")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                marketIndicator(theme: theme)
            }
            
            VStack(spacing: 4) {
                ForEach(Array(content.watchlist.prefix(3)), id: \.id) { stock in
                    self.stockRow(stock, theme: theme, compact: true)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Market Watch")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                marketIndicator(theme: theme)
            }
            
            VStack(spacing: 6) {
                ForEach(Array(content.watchlist.prefix(6)), id: \.id) { stock in
                    self.stockRow(stock, theme: theme, compact: false)
                }
            }
            
            HStack {
                Text("Market \(content.marketStatus)")
                    .font(.caption)
                    .foregroundColor(marketStatusColor(content.marketStatus))
                
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
        HStack(spacing: 20) {
            // Left side - Main watchlist
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Watchlist")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                    
                    marketIndicator(theme: theme)
                }
                
                VStack(spacing: 8) {
                    ForEach(content.watchlist, id: \.id) { stock in
                        self.stockRowDetailed(stock, theme: theme)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 140)
            
            // Right side - Market summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Market Summary")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                
                VStack(spacing: 8) {
                    marketSummaryRow("S&P 500", value: content.marketIndices.sp500, theme: theme)
                    marketSummaryRow("NASDAQ", value: content.marketIndices.nasdaq, theme: theme)
                    marketSummaryRow("DOW", value: content.marketIndices.dow, theme: theme)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Market \(content.marketStatus)")
                        .font(.caption)
                        .foregroundColor(marketStatusColor(content.marketStatus))
                    
                    if let lastUpdated = content.lastUpdated {
                        Text("Updated: \(formatTime(lastUpdated))")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            .frame(width: 160)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Views
    
    private func stockRow(_ stock: Stock, theme: any Theme, compact: Bool) -> some View {
        HStack {
            Text(stock.symbol)
                .font(compact ? .caption : .subheadline)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
                .frame(width: compact ? 40 : 50, alignment: .leading)
            
            if !compact {
                Text(stock.name)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(stock.price, specifier: "%.2f")")
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Text("\(stock.change >= 0 ? "+" : "")\(stock.change, specifier: "%.2f")")
                    .font(.caption2)
                    .foregroundColor(stock.change >= 0 ? .green : .red)
            }
        }
    }
    
    private func stockRowDetailed(_ stock: Stock, theme: any Theme) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.symbol)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Text(stock.name)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(stock.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                HStack(spacing: 4) {
                    Text("\(stock.change >= 0 ? "+" : "")\(stock.change, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(stock.change >= 0 ? .green : .red)
                    
                    Text("(\(stock.changePercent >= 0 ? "+" : "")\(stock.changePercent, specifier: "%.1f")%)")
                        .font(.caption)
                        .foregroundColor(stock.change >= 0 ? .green : .red)
                }
            }
        }
    }
    
    private func marketSummaryRow(_ name: String, value: MarketIndex, theme: any Theme) -> some View {
        HStack {
            Text(name)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(value.value, specifier: "%.0f")")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Text("\(value.change >= 0 ? "+" : "")\(value.change, specifier: "%.1f")%")
                    .font(.caption2)
                    .foregroundColor(value.change >= 0 ? .green : .red)
            }
        }
    }
    
    private func marketIndicator(theme: any Theme) -> some View {
        Circle()
            .fill(marketStatusColor(content.marketStatus))
            .frame(width: 8, height: 8)
    }
    
    // MARK: - Helper Methods
    
    private func marketStatusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "open": return .green
        case "closed": return .red
        case "pre-market", "after-hours": return .orange
        default: return .gray
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Stock Data Models

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
}

struct MarketIndex {
    let value: Double
    let change: Double
}

struct MarketIndices {
    let sp500: MarketIndex
    let nasdaq: MarketIndex
    let dow: MarketIndex
}

// MARK: - Stocks Content

@MainActor
final class StocksContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var watchlist: [Stock] = []
    @Published var marketStatus: String = "Open"
    @Published var marketIndices = MarketIndices(
        sp500: MarketIndex(value: 4500, change: 0.5),
        nasdaq: MarketIndex(value: 14000, change: -0.2),
        dow: MarketIndex(value: 35000, change: 0.8)
    )
    
    init() {
        generateMockStocks()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            generateMockStocks()
            updateMarketIndices()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockStocks() {
        let stockData = [
            ("AAPL", "Apple Inc.", 175.0),
            ("GOOGL", "Alphabet Inc.", 2800.0),
            ("MSFT", "Microsoft Corp.", 380.0),
            ("AMZN", "Amazon.com Inc.", 145.0),
            ("TSLA", "Tesla Inc.", 250.0),
            ("META", "Meta Platforms", 320.0),
            ("NFLX", "Netflix Inc.", 450.0),
            ("NVDA", "NVIDIA Corp.", 880.0)
        ]
        
        watchlist = stockData.map { (symbol, name, basePrice) in
            let change = Double.random(in: -15...15)
            let price = max(basePrice + change, 1.0)
            let changePercent = (change / basePrice) * 100
            
            return Stock(
                symbol: symbol,
                name: name,
                price: price,
                change: change,
                changePercent: changePercent
            )
        }
        
        // Update market status based on time
        let hour = Calendar.current.component(.hour, from: Date())
        marketStatus = switch hour {
        case 9...16: "Open"
        case 7...8, 17...20: hour < 9 ? "Pre-Market" : "After-Hours"
        default: "Closed"
        }
    }
    
    private func updateMarketIndices() {
        let sp500Change = Double.random(in: -2...2)
        let nasdaqChange = Double.random(in: -2...2)
        let dowChange = Double.random(in: -2...2)
        
        marketIndices = MarketIndices(
            sp500: MarketIndex(value: 4500 + (sp500Change * 50), change: sp500Change),
            nasdaq: MarketIndex(value: 14000 + (nasdaqChange * 100), change: nasdaqChange),
            dow: MarketIndex(value: 35000 + (dowChange * 200), change: dowChange)
        )
    }
}

// MARK: - Configuration View

struct StocksConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Stocks Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows stock prices, market indices, and trading status with mock data. In a real implementation, this would integrate with financial APIs for live market data.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}