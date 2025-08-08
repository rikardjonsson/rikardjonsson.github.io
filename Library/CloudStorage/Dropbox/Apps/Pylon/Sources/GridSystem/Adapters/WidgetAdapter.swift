//
//  WidgetAdapter.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Adapter for existing widgets
//

import SwiftUI
import Foundation

/// Adapter that converts existing WidgetContainer widgets to GridWidget protocol
struct WidgetContainerAdapter: GridWidget {
    let id: UUID
    var size: GridSize
    var position: GridPosition = .zero
    let title: String
    let category: GridWidgetCategory
    var isEnabled: Bool = true
    
    var lastUpdated: Date?
    var isLoading: Bool = false
    var error: (any Error)? = nil
    
    /// The original widget container
    private let originalContainer: any WidgetContainer
    
    @MainActor
    init(from container: any WidgetContainer) {
        self.originalContainer = container
        self.id = container.id
        self.title = container.title
        
        // Convert size - ensure dimensions match
        switch container.size {
        case .small:
            self.size = .small    // 1×1 -> 1×1
        case .medium:
            self.size = .medium   // 2×2 -> 2×2  
        case .large:
            self.size = .large    // 4×2 -> 4×2
        case .xlarge:
            self.size = .extraLarge // 4×4 -> 4×4
        }
        
        print("🔄 WidgetAdapter converting \(container.title): \(container.size) -> \(self.size)")
        
        // Convert category based on widget type
        self.category = Self.determineCategory(for: container)
        self.lastUpdated = container.lastUpdated
        self.isLoading = container.isLoading
        self.isEnabled = container.isEnabled
        self.error = container.error
    }
    
    @MainActor
    func refresh() async throws {
        // Delegate to original widget
        try await originalContainer.refresh()
    }
    
    @MainActor  
    func body(theme: any Theme, configuration: GridConfiguration) -> AnyView {
        // Use the original widget's body with adapted parameters
        return originalContainer.body(
            theme: theme,
            gridUnit: configuration.cellSize,
            spacing: configuration.cellSpacing
        )
    }
    
    /// Determine widget category from widget type
    private static func determineCategory(for container: any WidgetContainer) -> GridWidgetCategory {
        let typeName = String(describing: type(of: container))
        
        switch typeName {
        case let name where name.contains("Clock"):
            return .utilities
        case let name where name.contains("Weather"):
            return .information
        case let name where name.contains("Calendar"):
            return .productivity
        case let name where name.contains("Reminders"):
            return .productivity
        case let name where name.contains("Notes"):
            return .productivity
        case let name where name.contains("System"):
            return .system
        case let name where name.contains("Fitness"):
            return .information
        case let name where name.contains("Finance"):
            return .information
        case let name where name.contains("Email"):
            return .communication
        case let name where name.contains("Stocks"):
            return .information
        case let name where name.contains("Crypto"):
            return .information
        case let name where name.contains("News"):
            return .information
        case let name where name.contains("Music"):
            return .entertainment
        case let name where name.contains("Photo"):
            return .entertainment
        case let name where name.contains("Podcast"):
            return .entertainment
        case let name where name.contains("Social"):
            return .communication
        case let name where name.contains("Shopping"):
            return .utilities
        case let name where name.contains("Travel"):
            return .information
        case let name where name.contains("Activity"):
            return .information
        default:
            return .custom
        }
    }
}

/// Factory for creating adapted widgets
enum WidgetAdapterFactory {
    /// Convert an array of WidgetContainers to GridWidgets
    @MainActor
    static func adapt(_ containers: [any WidgetContainer]) -> [any GridWidget] {
        return containers.map { container in
            WidgetContainerAdapter(from: container)
        }
    }
}