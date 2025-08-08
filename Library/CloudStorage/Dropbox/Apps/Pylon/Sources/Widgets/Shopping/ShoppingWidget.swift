//
//  ShoppingWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Shopping widget showing cart items, recent orders, and wishlist
/// Demonstrates comprehensive e-commerce integration with mock shopping data
@MainActor
final class ShoppingWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: ShoppingContent
    
    // MARK: - Widget Metadata
    
    let title = "Shopping"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = ShoppingContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(ShoppingConfigurationView())
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
                    largeLayout(theme: theme) // Use large layout for xlarge
                }
            }
        )
    }
    
    // MARK: - Size-Specific Layouts
    
    private func smallLayout(theme: any Theme) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "cart.fill")
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text("\(content.cartItems.count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            
            Text("items")
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
            
            if content.cartTotal > 0 {
                Text(String(format: "$%.0f", content.cartTotal))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.accentColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Shopping")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                cartBadge(count: content.cartItems.count, theme: theme)
            }
            
            if !content.cartItems.isEmpty {
                VStack(spacing: 4) {
                    ForEach(Array(content.cartItems.prefix(3)), id: \.id) { item in
                        self.cartItemRow(item, theme: theme, compact: true)
                    }
                    
                    if content.cartTotal > 0 {
                        HStack {
                            Text("Total")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(theme.textSecondary)
                            
                            Spacer()
                            
                            Text(String(format: "$%.2f", content.cartTotal))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(theme.accentColor)
                        }
                        .padding(.top, 4)
                    }
                }
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "cart.badge.plus")
                        .font(.title3)
                        .foregroundColor(theme.textSecondary.opacity(0.6))
                    
                    Text("Cart is empty")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Shopping")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    cartBadge(count: content.cartItems.count, theme: theme)
                    if !content.recentOrders.isEmpty {
                        Text("\(content.recentOrders.count) recent orders")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            
            if !content.cartItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cart Items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textPrimary)
                    
                    VStack(spacing: 6) {
                        ForEach(Array(content.cartItems.prefix(4)), id: \.id) { item in
                            self.cartItemRow(item, theme: theme, compact: false)
                        }
                    }
                    
                    HStack {
                        Text("Total")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.textPrimary)
                        
                        Spacer()
                        
                        Text(String(format: "$%.2f", content.cartTotal))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(theme.accentColor)
                    }
                    .padding(.top, 4)
                }
            } else if !content.recentOrders.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Orders")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textPrimary)
                    
                    VStack(spacing: 6) {
                        ForEach(Array(content.recentOrders.prefix(3)), id: \.id) { order in
                            self.orderRow(order, theme: theme, compact: true)
                        }
                    }
                }
            } else {
                emptyState(theme: theme)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    // MARK: - Helper Views
    
    private func cartItemRow(_ item: CartItem, theme: any Theme, compact: Bool) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(productColor(for: item.name))
                .frame(width: compact ? 8 : 12, height: compact ? 8 : 12)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                if !compact {
                    Text("Qty: \(item.quantity)")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
            
            Text(String(format: "$%.2f", item.price * Double(item.quantity)))
                .font(compact ? .caption : .subheadline)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
        }
    }
    
    private func cartItemRowDetailed(_ item: CartItem, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Rectangle()
                    .fill(productColor(for: item.name))
                    .frame(width: 16, height: 16)
                    .cornerRadius(3)
                
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text(String(format: "$%.2f", item.price * Double(item.quantity)))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
            }
            
            HStack {
                Text(item.category)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                Spacer()
                
                Text("Qty: \(item.quantity) × $\(String(format: "%.2f", item.price))")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func orderRow(_ order: Order, theme: any Theme, compact: Bool) -> some View {
        HStack {
            Circle()
                .fill(orderStatusColor(order.status))
                .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Order #\(order.orderNumber)")
                    .font(compact ? .caption : .caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                if !compact {
                    Text(order.status.rawValue)
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.0f", order.total))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                if !compact {
                    Text(formatDate(order.orderDate))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
    }
    
    private func wishlistItemRow(_ item: WishlistItem, theme: any Theme) -> some View {
        HStack {
            Image(systemName: "heart.fill")
                .font(.caption2)
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                Text(String(format: "$%.2f", item.price))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func cartBadge(count: Int, theme: any Theme) -> some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(theme.accentColor, in: Capsule())
        } else {
            EmptyView()
        }
    }
    
    private func emptyState(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "cart.badge.plus")
                .font(.title2)
                .foregroundColor(theme.textSecondary.opacity(0.6))
            
            Text("Cart is empty")
                .font(.subheadline)
                .foregroundColor(theme.textSecondary)
            
            Text("Start shopping to see items here")
                .font(.caption)
                .foregroundColor(theme.textSecondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func productColor(for name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .cyan, .indigo, .mint]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
    
    private func orderStatusColor(_ status: OrderStatus) -> Color {
        switch status {
        case .processing: return .orange
        case .shipped: return .blue
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Shopping Data Models

struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let price: Double
    let quantity: Int
    let imageURL: String?
}

struct Order: Identifiable {
    let id = UUID()
    let orderNumber: String
    let items: [CartItem]
    let total: Double
    let status: OrderStatus
    let orderDate: Date
    let estimatedDelivery: Date?
}

struct WishlistItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let category: String
    let inStock: Bool
}

enum OrderStatus: String, CaseIterable {
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

// MARK: - Shopping Content

@MainActor
final class ShoppingContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var cartItems: [CartItem] = []
    @Published var recentOrders: [Order] = []
    @Published var wishlistItems: [WishlistItem] = []
    @Published var cartTotal: Double = 0
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_300_000_000)
            generateMockData()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockData() {
        // Generate cart items
        let productNames = [
            "Wireless Bluetooth Headphones", "Mechanical Keyboard", "4K Webcam",
            "USB-C Hub", "Portable Monitor", "Wireless Mouse", "Phone Stand",
            "Laptop Sleeve", "External SSD", "Bluetooth Speaker", "Smart Watch",
            "Tablet Case", "Wireless Charger", "Gaming Chair", "Desk Lamp",
            "Coffee Mug", "Water Bottle", "Notebook Set", "Pen Collection",
            "Phone Case", "Screen Protector", "Cable Organizer"
        ]
        
        let categories = [
            "Electronics", "Accessories", "Home & Garden", "Office Supplies",
            "Sports & Outdoors", "Books & Media", "Clothing", "Health & Beauty"
        ]
        
        // Sometimes have empty cart, sometimes 1-6 items
        let cartCount = Bool.random() && Double.random(in: 0...1) < 0.7 ? Int.random(in: 1...6) : 0
        
        cartItems = (0..<cartCount).map { _ in
            CartItem(
                name: productNames.randomElement() ?? "Product",
                category: categories.randomElement() ?? "Electronics",
                price: Double.random(in: 9.99...299.99),
                quantity: Int.random(in: 1...3),
                imageURL: nil
            )
        }
        
        // Calculate cart total
        cartTotal = cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        
        // Generate recent orders
        let calendar = Calendar.current
        let now = Date()
        
        recentOrders = (0..<Int.random(in: 3...8)).compactMap { i in
            let daysAgo = (i + 1) * Int.random(in: 1...14)
            guard let orderDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { return nil }
            
            let orderItems = (0..<Int.random(in: 1...4)).map { _ in
                CartItem(
                    name: productNames.randomElement() ?? "Product",
                    category: categories.randomElement() ?? "Electronics",
                    price: Double.random(in: 9.99...199.99),
                    quantity: Int.random(in: 1...2),
                    imageURL: nil
                )
            }
            
            let total = orderItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
            let estimatedDelivery = calendar.date(byAdding: .day, value: Int.random(in: 1...7), to: orderDate)
            
            return Order(
                orderNumber: String(format: "%04d%02d%02d", 
                                  Int.random(in: 1000...9999),
                                  Int.random(in: 10...99),
                                  Int.random(in: 10...99)),
                items: orderItems,
                total: total,
                status: OrderStatus.allCases.randomElement() ?? .processing,
                orderDate: orderDate,
                estimatedDelivery: estimatedDelivery
            )
        }.sorted { $0.orderDate > $1.orderDate }
        
        // Generate wishlist items
        wishlistItems = (0..<Int.random(in: 2...8)).map { _ in
            WishlistItem(
                name: productNames.randomElement() ?? "Product",
                price: Double.random(in: 19.99...399.99),
                category: categories.randomElement() ?? "Electronics",
                inStock: Bool.random()
            )
        }
    }
}

// MARK: - Configuration View

struct ShoppingConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Shopping Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows shopping cart items, recent orders, and wishlist with mock e-commerce data. In a real implementation, this would integrate with shopping APIs and payment systems.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}