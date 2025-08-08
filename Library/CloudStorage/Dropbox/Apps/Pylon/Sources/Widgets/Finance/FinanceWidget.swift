//
//  FinanceWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Finance widget showing portfolio performance and asset allocation
/// Demonstrates comprehensive financial data with mock investment tracking
@MainActor
final class FinanceWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: FinanceContent
    
    // MARK: - Widget Metadata
    
    let title = "Finance"
    let category = WidgetCategory.information
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = FinanceContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(FinanceConfigurationView())
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
                
                Text("Portfolio")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                performanceIndicator(theme: theme)
            }
            
            VStack(spacing: 6) {
                HStack {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    Text(String(format: "$%.0f", content.portfolio.totalValue))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                }
                
                HStack {
                    Text("Today's Change")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: content.portfolio.dayChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(content.portfolio.dayChange >= 0 ? .green : .red)
                        
                        Text(String(format: "$%.2f", abs(content.portfolio.dayChange)))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(content.portfolio.dayChange >= 0 ? .green : .red)
                    }
                }
                
                HStack {
                    Text("Performance")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    Text(String(format: "%@%.2f%%", content.portfolio.dayChangePercent >= 0 ? "+" : "", content.portfolio.dayChangePercent))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(content.portfolio.dayChangePercent >= 0 ? .green : .red)
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
                
                Text("Portfolio")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                performanceIndicator(theme: theme)
            }
            
            // Portfolio summary
            VStack(spacing: 8) {
                HStack {
                    Text("Total Value")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    Text(String(format: "$%.2f", content.portfolio.totalValue))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                }
                
                HStack {
                    Text("Today's P&L")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: content.portfolio.dayChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                            .foregroundColor(content.portfolio.dayChange >= 0 ? .green : .red)
                        
                        Text(String(format: "$%.2f", abs(content.portfolio.dayChange)))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(content.portfolio.dayChange >= 0 ? .green : .red)
                        
                        Text(String(format: "(%@%.2f%%)", content.portfolio.dayChangePercent >= 0 ? "+" : "", content.portfolio.dayChangePercent))
                            .font(.caption)
                            .foregroundColor(content.portfolio.dayChangePercent >= 0 ? .green : .red)
                    }
                }
            }
            
            Divider()
            
            // Top holdings
            VStack(spacing: 6) {
                ForEach(Array(content.holdings.prefix(4)), id: \.id) { holding in
                    self.holdingRow(holding, theme: theme, compact: false)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(theme.accentColor)
                        Text("Investment Portfolio")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                    }
                    Text("Complete portfolio overview and analytics")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                Spacer()
            }
            
            // Portfolio summary cards
            HStack(spacing: 16) {
                financeCard("Total Value", value: String(format: "$%.2f", content.portfolio.totalValue), subtitle: "Portfolio", color: .blue, theme: theme)
                financeCard("Day Change", value: String(format: "$%.2f", content.portfolio.dayChange), subtitle: String(format: "%.2f%%", content.portfolio.dayChangePercent), color: content.portfolio.dayChange >= 0 ? .green : .red, theme: theme)
                financeCard("Holdings", value: "\(content.holdings.count)", subtitle: "Positions", color: .orange, theme: theme)
            }
            
            // Holdings table
            VStack(alignment: .leading, spacing: 12) {
                Text("Portfolio Holdings")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(content.holdings, id: \.id) { holding in
                            self.holdingRowDetailed(holding, theme: theme)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    // MARK: - Helper Views
    
    private func holdingRow(_ holding: PortfolioHolding, theme: any Theme, compact: Bool) -> some View {
        HStack {
            Text(holding.symbol)
                .font(compact ? .caption : .subheadline)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
                .frame(width: compact ? 40 : 50, alignment: .leading)
            
            if !compact {
                Text(holding.name)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.0f", holding.currentValue))
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                HStack(spacing: 2) {
                    Image(systemName: holding.dayChange >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                        .foregroundColor(holding.dayChange >= 0 ? .green : .red)
                    
                    Text(String(format: "%@%.1f%%", holding.dayChangePercent >= 0 ? "+" : "", holding.dayChangePercent))
                        .font(.caption2)
                        .foregroundColor(holding.dayChange >= 0 ? .green : .red)
                }
            }
        }
    }
    
    private func holdingRowDetailed(_ holding: PortfolioHolding, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(holding.symbol)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "$%.2f", holding.currentValue))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text(String(format: "$%@%.2f", holding.dayChange >= 0 ? "+" : "", holding.dayChange))
                            .font(.caption)
                            .foregroundColor(holding.dayChange >= 0 ? .green : .red)
                        
                        Text(String(format: "(%@%.1f%%)", holding.dayChangePercent >= 0 ? "+" : "", holding.dayChangePercent))
                            .font(.caption)
                            .foregroundColor(holding.dayChange >= 0 ? .green : .red)
                    }
                }
            }
            
            HStack {
                Text(holding.name)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(String(format: "%.2f shares", holding.shares))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func portfolioMetric(_ label: String, value: String, color: Color? = nil, theme: any Theme) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color ?? theme.textPrimary)
        }
    }
    
    private func allocationRow(_ allocation: AssetAllocation, theme: any Theme) -> some View {
        HStack {
            Text(allocation.category)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            
            Spacer()
            
            Text(String(format: "%.1f%%", allocation.percentage))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
        }
    }
    
    private func performanceIndicator(theme: any Theme) -> some View {
        Circle()
            .fill(content.portfolio.dayChangePercent >= 0 ? .green : .red)
            .frame(width: 8, height: 8)
    }
    
    // MARK: - Helper Methods
    
    private func financeCard(_ label: String, value: String, subtitle: String, color: Color, theme: any Theme) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(theme.textPrimary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Finance Data Models

struct Portfolio {
    let totalValue: Double
    let dayChange: Double
    let dayChangePercent: Double
    let cashBalance: Double
    let totalInvested: Double
}

struct PortfolioHolding: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let shares: Double
    let currentPrice: Double
    let currentValue: Double
    let dayChange: Double
    let dayChangePercent: Double
    let costBasis: Double
}

struct AssetAllocation {
    let category: String
    let percentage: Double
    let value: Double
}

// MARK: - Finance Content

@MainActor
final class FinanceContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var portfolio = Portfolio(totalValue: 0, dayChange: 0, dayChangePercent: 0, cashBalance: 0, totalInvested: 0)
    @Published var holdings: [PortfolioHolding] = []
    @Published var assetAllocation: [AssetAllocation] = []
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 2_200_000_000)
            generateMockData()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockData() {
        // Generate mock holdings
        let holdingData = [
            ("AAPL", "Apple Inc.", 150.0, 25.0),
            ("GOOGL", "Alphabet Inc.", 2800.0, 10.0),
            ("MSFT", "Microsoft Corp.", 380.0, 50.0),
            ("TSLA", "Tesla Inc.", 250.0, 15.0),
            ("NVDA", "NVIDIA Corp.", 880.0, 12.0),
            ("AMZN", "Amazon.com Inc.", 145.0, 30.0),
            ("META", "Meta Platforms", 320.0, 20.0),
            ("NFLX", "Netflix Inc.", 450.0, 8.0)
        ]
        
        holdings = holdingData.prefix(Int.random(in: 5...8)).map { (symbol, name, basePrice, baseShares) in
            let priceVariation = Double.random(in: -0.15...0.15)
            let currentPrice = basePrice * (1 + priceVariation)
            let shares = baseShares * Double.random(in: 0.5...2.0)
            let currentValue = currentPrice * shares
            let dayChange = currentPrice * Double.random(in: -0.08...0.08)
            let dayChangePercent = (dayChange / currentPrice) * 100
            let costBasis = currentPrice * Double.random(in: 0.7...1.3)
            
            return PortfolioHolding(
                symbol: symbol,
                name: name,
                shares: shares,
                currentPrice: currentPrice,
                currentValue: currentValue,
                dayChange: dayChange,
                dayChangePercent: dayChangePercent,
                costBasis: costBasis
            )
        }.sorted { $0.currentValue > $1.currentValue }
        
        // Calculate portfolio totals
        let totalValue = holdings.reduce(0) { $0 + $1.currentValue }
        let totalDayChange = holdings.reduce(0) { $0 + ($1.dayChange * $1.shares) }
        let dayChangePercent = totalValue > 0 ? (totalDayChange / totalValue) * 100 : 0
        let cashBalance = Double.random(in: 1000...10000)
        
        portfolio = Portfolio(
            totalValue: totalValue + cashBalance,
            dayChange: totalDayChange,
            dayChangePercent: dayChangePercent,
            cashBalance: cashBalance,
            totalInvested: totalValue
        )
        
        // Generate asset allocation
        let stocksPercentage = (totalValue / (totalValue + cashBalance)) * 100
        let cashPercentage = (cashBalance / (totalValue + cashBalance)) * 100
        
        assetAllocation = [
            AssetAllocation(category: "Stocks", percentage: stocksPercentage, value: totalValue),
            AssetAllocation(category: "Cash", percentage: cashPercentage, value: cashBalance),
            AssetAllocation(category: "Bonds", percentage: 0, value: 0) // Placeholder for future
        ].filter { $0.percentage > 0 }
    }
}

// MARK: - Configuration View

struct FinanceConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Finance Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows portfolio performance, holdings, and asset allocation with mock financial data. In a real implementation, this would integrate with brokerage APIs or financial data providers.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}