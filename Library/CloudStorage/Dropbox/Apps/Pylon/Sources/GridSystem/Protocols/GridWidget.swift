//
//  GridWidget.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Widget protocol definition
//

import Foundation
import SwiftUI

/// Protocol defining a widget that can be placed in the grid system
protocol GridWidget: Identifiable, Sendable {
    /// Unique identifier for the widget
    var id: UUID { get }
    
    /// Current size of the widget in grid units
    var size: GridSize { get set }
    
    /// Current position in the grid
    var position: GridPosition { get set }
    
    /// Display name for the widget
    var title: String { get }
    
    /// Widget type identifier for factory creation
    var type: String { get }
    
    /// Widget category for organization
    var category: GridWidgetCategory { get }
    
    /// Whether the widget is currently enabled/visible
    var isEnabled: Bool { get set }
    
    /// Supported sizes for this widget type
    var supportedSizes: [GridSize] { get }
    
    /// Last update timestamp (for refresh tracking)
    var lastUpdated: Date? { get }
    
    /// Whether the widget is currently loading data
    var isLoading: Bool { get }
    
    /// Current error state, if any
    var error: (any Error)? { get }
    
    /// Refresh the widget's data
    @MainActor func refresh() async throws
    
    /// Create the widget's configuration view
    @MainActor func configure() -> AnyView
    
    /// Render the widget's content
    @MainActor func body(theme: any Theme, configuration: GridConfiguration) -> AnyView
}

/// Widget categories for organization and filtering
enum GridWidgetCategory: String, CaseIterable, Codable, Sendable {
    case productivity = "Productivity"
    case information = "Information" 
    case communication = "Communication"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case system = "System"
    case custom = "Custom"
    
    var displayName: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .productivity: return "checklist"
        case .information: return "info.circle"
        case .communication: return "message"
        case .entertainment: return "tv"
        case .utilities: return "wrench.and.screwdriver"
        case .system: return "gearshape"
        case .custom: return "puzzlepiece"
        }
    }
}

// MARK: - Default Implementations
extension GridWidget {
    /// Default supported sizes (can be overridden)
    var supportedSizes: [GridSize] {
        return [.small, .medium, .large]
    }
    
    /// Default category
    var category: GridWidgetCategory {
        return .utilities
    }
    
    /// Default enabled state
    var isEnabled: Bool {
        get { true }
        set { /* Override in concrete types if needed */ }
    }
    
    /// Default loading state
    var isLoading: Bool { false }
    
    /// Default error state
    var error: (any Error)? { nil }
    
    /// Default refresh implementation
    @MainActor func refresh() async throws {
        // Override in concrete implementations
    }
    
    /// Default configuration view
    @MainActor func configure() -> AnyView {
        AnyView(
            VStack {
                Text("No configuration available")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
}