//
//  CryptoWidget.swift  
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class CryptoWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: CryptoContent
    
    let title = "Crypto"
    let category = WidgetCategory.information
    let supportedSizes: [WidgetSize] = [.medium, .large, .xlarge]
    
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = CryptoContent()
    }
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(EmptyView())
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "bitcoinsign.circle")
                        .font(.title)
                        .foregroundColor(theme.accentColor)
                    Text("Cryptocurrency")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                    Spacer()
                }
                
                VStack(spacing: 6) {
                    ForEach(content.cryptos, id: \.symbol) { crypto in
                        HStack {
                            Text(crypto.symbol)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                                .frame(width: 50, alignment: .leading)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("$\(crypto.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(theme.textPrimary)
                                
                                Text("\(crypto.change >= 0 ? "+" : "")\(crypto.change, specifier: "%.1f")%")
                                    .font(.caption)
                                    .foregroundColor(crypto.change >= 0 ? .green : .red)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
}

struct Crypto {
    let symbol: String
    let price: Double
    let change: Double
}

@MainActor
final class CryptoContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var cryptos: [Crypto] = []
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    func refresh() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 1_500_000_000)
        generateMockData()
        lastUpdated = Date()
        isLoading = false
    }
    
    private func generateMockData() {
        let cryptoData = [
            ("BTC", 45000.0), ("ETH", 3200.0), ("ADA", 0.85), ("DOT", 15.0), ("SOL", 120.0)
        ]
        
        cryptos = cryptoData.map { (symbol, basePrice) in
            let change = Double.random(in: -15...15)
            let price = max(basePrice + (basePrice * change / 100), 0.01)
            return Crypto(symbol: symbol, price: price, change: change)
        }
    }
}