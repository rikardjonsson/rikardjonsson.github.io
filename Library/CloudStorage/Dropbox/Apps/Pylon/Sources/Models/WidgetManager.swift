//
//  WidgetManager.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Manages widget containers for the TetrisGrid system
@MainActor
class WidgetManager: ObservableObject {
    @Published private(set) var containers: [any WidgetContainer] = []
    @Published private(set) var refreshInProgress: Set<UUID> = []
    
    // Grid system integration
    private let gridManager = GridManager(configuration: .standard)
    @Published var gridConfiguration = LegacyGridConfiguration()
    
    // Layout persistence
    private var layoutPersistence: GridLayoutPersistence?
    @Published var currentLayoutName: String = "Default Layout"

    // MARK: - Container Management

    func registerContainer(_ container: any WidgetContainer) {
        DebugLog.placement("Registering container: \(container.title)")
        
        containers.append(container)
        
        // Recalculate layout when a new container is added
        if container.isEnabled {
            recalculateLayout()
        }
        
        // Auto-save layout changes
        autoSaveLayout()
        
        DebugLog.placement("Containers count: \(containers.count), \(container.title) enabled: \(container.isEnabled)")
    }

    func removeContainer(id: UUID) {
        containers.removeAll { $0.id == id }
        gridManager.removeWidget(id: id)
        recalculateLayout()
        
        // Auto-save layout changes
        autoSaveLayout()
    }
    
    func removeAllContainers() {
        containers.removeAll()
    }

    func updateContainerSize(id: UUID, newSize: WidgetSize) {
        guard let index = containers.firstIndex(where: { $0.id == id }) else { return }
        var container = containers[index]

        // Check if the new size is supported
        guard container.supportedSizes.contains(newSize) else { return }

        container.size = newSize
        containers[index] = container

        // Layout recalculation is handled by TetrisGrid
    }

    func updateContainerTheme(id: UUID, themeOverride: WidgetThemeOverride?) {
        guard let index = containers.firstIndex(where: { $0.id == id }) else { return }
        var container = containers[index]
        container.theme = themeOverride
        containers[index] = container
    }

    func toggleContainerEnabled(id: UUID) {
        guard let index = containers.firstIndex(where: { $0.id == id }) else { return }
        var container = containers[index]
        container.isEnabled.toggle()
        containers[index] = container
        
        // Recalculate layout when container is enabled/disabled
        recalculateLayout()
        
        // Auto-save layout changes
        autoSaveLayout()
        
        DebugLog.success("Toggled \(container.title) enabled: \(container.isEnabled)")
    }

    // MARK: - Refresh Management

    /// Refresh all enabled widgets with comprehensive error handling
    func refreshAllContainers() async {
        var refreshResults: [RefreshResult] = []
        
        // Refresh all enabled containers concurrently
        await withTaskGroup(of: RefreshResult.self) { group in
            for container in containers where container.isEnabled {
                let containerId = container.id
                let containerTitle = container.title
                
                group.addTask { [weak self] in
                    await self?.refreshContainer(id: containerId) ?? 
                        RefreshResult(widgetId: containerId, widgetTitle: containerTitle, success: false, error: WidgetError.widgetManagerDeallocated)
                }
            }
            
            for await result in group {
                refreshResults.append(result)
            }
        }
        
        // Log summary of refresh operations
        let successCount = refreshResults.filter(\.success).count
        let failureCount = refreshResults.count - successCount
        
        if failureCount == 0 {
            DebugLog.success("Successfully refreshed all \(successCount) widgets")
        } else {
            DebugLog.warning("Refreshed \(successCount)/\(refreshResults.count) widgets - \(failureCount) failed")
            
            // Log details of failed refreshes
            for result in refreshResults where !result.success {
                DebugLog.error("Failed to refresh \(result.widgetTitle): \(result.error?.userFriendlyDescription ?? "Unknown error")")
            }
        }
    }

    /// Refresh a specific widget with retry logic and detailed error handling
    func refreshContainer(id: UUID, maxRetries: Int = 2) async -> RefreshResult {
        guard let container = containers.first(where: { $0.id == id }) else { 
            return RefreshResult(widgetId: id, widgetTitle: "Unknown", success: false, error: WidgetError.widgetNotFound)
        }
        
        refreshInProgress.insert(id)
        defer { refreshInProgress.remove(id) }
        
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                try await container.refresh()
                DebugLog.success("Refreshed \(container.title)\(attempt > 0 ? " (attempt \(attempt + 1))" : "")")
                return RefreshResult(widgetId: id, widgetTitle: container.title, success: true, error: nil)
            } catch {
                lastError = error
                
                if attempt < maxRetries {
                    let delay = calculateRetryDelay(attempt: attempt, error: error)
                    DebugLog.warning("Refresh failed for \(container.title) (attempt \(attempt + 1)), retrying in \(delay)ms...")
                    
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000))
                } else {
                    DebugLog.error("Failed to refresh \(container.title) after \(maxRetries + 1) attempts: \(error.userFriendlyDescription)")
                }
            }
        }
        
        return RefreshResult(
            widgetId: id, 
            widgetTitle: container.title, 
            success: false, 
            error: lastError ?? WidgetError.unknownRefreshError
        )
    }
    
    /// Calculate retry delay based on attempt number and error type
    private func calculateRetryDelay(attempt: Int, error: Error) -> Int {
        // Exponential backoff with jitter
        let baseDelay = 1000 * (1 << attempt) // 1s, 2s, 4s, etc.
        let jitter = Int.random(in: 0...500) // 0-500ms random jitter
        return baseDelay + jitter
    }

    func isRefreshing(containerId: UUID) -> Bool {
        refreshInProgress.contains(containerId)
    }

    // MARK: - Filtering and Organization

    func containers(in category: WidgetCategory) -> [any WidgetContainer] {
        containers.filter { $0.category == category }
    }

    func enabledContainers() -> [any WidgetContainer] {
        let enabled = containers.filter(\.isEnabled)
        
        // Sort widgets by their grid positions (row first, then column)
        // Widgets with invalid positions (0,0) are placed after positioned widgets
        let sorted = enabled.sorted { a, b in
            let aIsPositioned = a.gridPosition != GridPosition.zero
            let bIsPositioned = b.gridPosition != GridPosition.zero
            
            // Positioned widgets come before unpositioned ones
            if aIsPositioned != bIsPositioned {
                return aIsPositioned
            }
            
            // Both positioned or both unpositioned - sort by position
            if a.gridPosition.row != b.gridPosition.row {
                return a.gridPosition.row < b.gridPosition.row
            }
            return a.gridPosition.column < b.gridPosition.column
        }
        
        DebugLog.placement("Enabled containers: \(enabled.count)/\(containers.count) (sorted by position)")
        sorted.forEach { container in
            let positionStatus = container.gridPosition == GridPosition.zero ? "(unpositioned)" : ""
            DebugLog.placement("  \(container.title) at (\(container.gridPosition.row),\(container.gridPosition.column)) \(positionStatus)")
        }
        return sorted
    }
    
    /// Get enabled containers ordered by their saved grid positions
    /// This ensures consistent visual layout that matches stored positions
    func enabledContainersOrderedByPosition() -> [any WidgetContainer] {
        return enabledContainers() // Now returns position-sorted containers
    }
    
    // MARK: - Grid Layout Management
    
    /// Recalculate layout positions for all enabled containers
    func recalculateLayout() {
        DebugLog.placement("🔄 Recalculating layout for \(containers.count) containers")
        
        // Clear current grid
        gridManager.clearGrid()
        
        // Convert enabled containers to grid widgets and add to grid
        let enabledWidgets = enabledContainers()
        
        for container in enabledWidgets {
            // Convert WidgetContainer to GridWidget via adapter
            let gridWidget = WidgetContainerAdapter(from: container)
            
            // Add to grid manager (this will find positions automatically)
            let success = gridManager.addWidget(gridWidget)
            if !success {
                DebugLog.error("Failed to place widget: \(container.title)")
            }
        }
        
        // Update container positions based on grid placements
        updateContainerPositions()
        
        DebugLog.success("✅ Layout recalculation complete")
    }
    
    /// Move a container from one position to another
    func moveContainer(from currentPosition: GridPosition, to newPosition: GridPosition) -> Bool {
        // Find container at the current position
        guard let container = containers.first(where: { $0.gridPosition == currentPosition }) else {
            DebugLog.error("No container found at position \(currentPosition)")
            return false
        }
        
        return moveContainer(id: container.id, to: newPosition)
    }
    
    /// Move a container to a new grid position
    func moveContainer(id: UUID, to newPosition: GridPosition) -> Bool {
        guard let index = containers.firstIndex(where: { $0.id == id }) else {
            DebugLog.error("Container not found: \(id)")
            return false
        }
        
        var container = containers[index]
        let gridWidget = WidgetContainerAdapter(from: container)
        
        // Check if move is valid using grid manager
        guard gridManager.canPlaceWidget(gridWidget, at: newPosition, excluding: [id]) else {
            DebugLog.error("Cannot move \(container.title) to \(newPosition) - collision detected")
            return false
        }
        
        // Update grid manager
        gridManager.removeWidget(id: id)
        var updatedWidget = gridWidget
        updatedWidget.position = newPosition
        
        guard gridManager.addWidget(updatedWidget) else {
            DebugLog.error("Failed to add widget back to grid after move")
            return false
        }
        
        // Update container position
        container.gridPosition = newPosition
        containers[index] = container
        
        // Auto-save layout changes
        autoSaveLayout()
        
        DebugLog.success("Moved \(container.title) to \(newPosition)")
        return true
    }
    
    /// Update container positions based on current grid state
    private func updateContainerPositions() {
        for (index, container) in containers.enumerated() {
            if let gridWidget = gridManager.widgets.first(where: { $0.id == container.id }) {
                var updatedContainer = container
                updatedContainer.gridPosition = gridWidget.position
                containers[index] = updatedContainer
            }
        }
    }
    
    /// Get current grid manager (for TetrisGrid integration)
    var currentGridManager: GridManager {
        return gridManager
    }
    
    // MARK: - Layout Persistence
    
    /// Initialize layout persistence
    func initializePersistence() {
        do {
            layoutPersistence = try GridLayoutPersistence()
            loadLastLayout()
        } catch {
            DebugLog.error("Failed to initialize layout persistence: \(error)")
        }
    }
    
    /// Auto-save current layout (delayed)
    private func autoSaveLayout() {
        guard let persistence = layoutPersistence else { return }
        persistence.autoSaveLayout(gridManager, name: currentLayoutName)
    }
    
    /// Save current layout with specified name
    func saveLayout(name: String) {
        guard let persistence = layoutPersistence else { return }
        do {
            try persistence.saveLayout(gridManager, name: name)
            currentLayoutName = name
            DebugLog.success("Saved layout: \(name)")
        } catch {
            DebugLog.error("Failed to save layout: \(error)")
        }
    }
    
    /// Load a specific layout
    func loadLayout(_ layoutData: GridLayoutData) {
        guard let persistence = layoutPersistence else { return }
        do {
            // Clear current containers before loading
            removeAllContainers()
            
            // Load the grid layout
            try persistence.loadLayout(layoutData, into: gridManager)
            
            // Recreate WidgetContainer instances from grid widgets using widget factory
            recreateContainersFromGridWidgets()
            
            currentLayoutName = layoutData.name
            DebugLog.success("Loaded layout: \(layoutData.name)")
        } catch {
            DebugLog.error("Failed to load layout: \(error)")
        }
    }
    
    /// Load the most recent layout on app startup
    private func loadLastLayout() {
        guard let persistence = layoutPersistence,
              let mostRecent = persistence.mostRecentLayout else { return }
        
        loadLayout(mostRecent)
    }
    
    /// Get all saved layouts
    var savedLayouts: [GridLayoutData] {
        return layoutPersistence?.savedLayouts ?? []
    }
    
    /// Delete a saved layout
    func deleteLayout(_ layoutData: GridLayoutData) {
        guard let persistence = layoutPersistence else { return }
        do {
            try persistence.deleteLayout(layoutData)
            DebugLog.success("Deleted layout: \(layoutData.name)")
        } catch {
            DebugLog.error("Failed to delete layout: \(error)")
        }
    }
    
    /// Recreate WidgetContainer instances from grid widgets after loading layout
    private func recreateContainersFromGridWidgets() {
        Task { @MainActor in
            for gridWidget in gridManager.widgets {
                if let container = WidgetFactory.createContainer(from: gridWidget) {
                    containers.append(container)
                    DebugLog.success("Recreated widget: \(container.title) at \(container.gridPosition)")
                } else {
                    DebugLog.success("Widget factory returned nil for type: \(gridWidget.type)")
                }
            }
        }
    }
}

// MARK: - Widget Factory

/// Factory for creating WidgetContainer instances from saved data
struct WidgetFactory {
    @MainActor
    static func createContainer(from gridWidget: any GridWidget) -> (any WidgetContainer)? {
        // For now, just log the widget type - full recreation would require
        // more complex serialization of widget state
        DebugLog.success("Would recreate widget: \(gridWidget.type) at \(gridWidget.position)")
        return nil
    }
}

// MARK: - Extensions

extension WidgetSize {
    init(from gridSize: GridSize) {
        if gridSize == .small {
            self = .small
        } else if gridSize == .medium {
            self = .medium
        } else if gridSize == .large {
            self = .large
        } else if gridSize == .extraLarge {
            self = .xlarge
        } else {
            // Default fallback for unknown sizes
            self = .medium
        }
    }
}

// MARK: - Compatibility Types (to be removed)

/// Temporary stub for old GridConfiguration to fix compilation
/// This will be removed once layout persistence is updated for TetrisGrid
struct LegacyGridConfiguration: Sendable {
    var columns: Int = 8
    var gridUnit: CGFloat = 100
    var spacing: CGFloat = 4
    var padding: EdgeInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
}

// MARK: - Widget Errors

enum WidgetError: Error, LocalizedError {
    case permissionDenied
    case networkUnavailable
    case dataCorrupted
    case widgetNotFound
    case widgetManagerDeallocated
    case unknownRefreshError
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Permission denied. Please grant access in System Preferences."
        case .networkUnavailable:
            "Network unavailable. Please check your connection."
        case .dataCorrupted:
            "Data corrupted. Please try refreshing."
        case .widgetNotFound:
            "Widget not found."
        case .widgetManagerDeallocated:
            "Widget manager was deallocated during refresh."
        case .unknownRefreshError:
            "An unknown error occurred during refresh."
        case let .unknownError(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Refresh Result

/// Result of a widget refresh operation
struct RefreshResult: Sendable {
    let widgetId: UUID
    let widgetTitle: String
    let success: Bool
    let error: Error?
    let timestamp: Date
    
    init(widgetId: UUID, widgetTitle: String, success: Bool, error: Error?) {
        self.widgetId = widgetId
        self.widgetTitle = widgetTitle
        self.success = success
        self.error = error
        self.timestamp = Date()
    }
}

// MARK: - Error Handling Extensions

extension Error {
    /// Convert any error to a user-friendly description
    var userFriendlyDescription: String {
        if let widgetError = self as? WidgetError {
            return widgetError.errorDescription ?? localizedDescription
        }
        
        // Handle common system errors with better descriptions
        let nsError = self as NSError
        switch nsError.code {
        case NSURLErrorTimedOut, NSURLErrorCannotConnectToHost:
            return "Network timeout. Please check your connection."
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection available."
        case -1009: // NSURLErrorNotConnectedToInternet on some systems
            return "No internet connection available."
        default:
            return localizedDescription
        }
    }
}