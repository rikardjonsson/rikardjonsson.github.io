//
//  GridManager.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Central grid management
//

import Foundation
import SwiftUI

/// Central manager for the grid layout system
@MainActor
class GridManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current grid configuration
    @Published private(set) var configuration: GridConfiguration
    
    /// All widgets in the grid
    @Published private(set) var widgets: [any GridWidget] = []
    
    /// Currently occupied positions (cached for performance)
    @Published private(set) var occupiedPositions: Set<GridPosition> = []
    
    /// Layout and collision detection engines
    private let layoutEngine: any LayoutEngine
    private let collisionDetector: any CollisionDetector
    
    // MARK: - Initialization
    
    init(
        configuration: GridConfiguration = .standard,
        layoutEngine: (any LayoutEngine)? = nil,
        collisionDetector: (any CollisionDetector)? = nil
    ) {
        self.configuration = configuration
        self.layoutEngine = layoutEngine ?? SimpleSequentialEngine()
        self.collisionDetector = collisionDetector ?? SimpleCollisionDetector()
    }
    
    // MARK: - Widget Management
    
    /// Add a widget to the grid
    /// - Parameter widget: Widget to add
    /// - Returns: True if successfully placed, false if no space
    @discardableResult
    func addWidget(_ widget: any GridWidget) -> Bool {
        // Check for duplicate IDs
        guard !widgets.contains(where: { $0.id == widget.id }) else {
            print("⚠️ Widget with ID \(widget.id) already exists")
            return false
        }
        
        var mutableWidget = widget
        
        // Find available position if not already set or if current position is invalid
        if mutableWidget.position == .zero || !isValidPosition(mutableWidget.position, for: mutableWidget) {
            guard let availablePosition = layoutEngine.findAvailablePosition(
                for: mutableWidget,
                avoiding: occupiedPositions,
                configuration: configuration
            ) else {
                print("❌ No space available for widget: \(widget.title)")
                return false
            }
            mutableWidget.position = availablePosition
            print("🔧 Found available position \(availablePosition) for \(widget.title)")
        }
        
        // Add widget and update occupied positions
        widgets.append(mutableWidget)
        updateOccupiedPositions()
        
        print("✅ Added widget: \(widget.title) at \(mutableWidget.position) (size: \(mutableWidget.size))")
        print("🔍 All widgets now: \(widgets.map { "\($0.title): \($0.position) (\($0.size))" })")
        print("🔍 Current occupied positions: \(occupiedPositions)")
        return true
    }
    
    /// Remove a widget from the grid
    /// - Parameter id: ID of widget to remove
    /// - Returns: True if widget was found and removed
    @discardableResult
    func removeWidget(id: UUID) -> Bool {
        guard let index = widgets.firstIndex(where: { $0.id == id }) else {
            print("⚠️ Widget with ID \(id) not found")
            return false
        }
        
        let widget = widgets[index]
        widgets.remove(at: index)
        updateOccupiedPositions()
        
        print("✅ Removed widget: \(widget.title)")
        return true
    }
    
    /// Move a widget to a new position
    /// - Parameters:
    ///   - id: Widget ID
    ///   - newPosition: Target position
    /// - Returns: True if move was successful
    @discardableResult
    func moveWidget(id: UUID, to newPosition: GridPosition) -> Bool {
        guard let index = widgets.firstIndex(where: { $0.id == id }) else {
            print("⚠️ Widget with ID \(id) not found")
            return false
        }
        
        var widget = widgets[index]
        
        // Validate new position (excluding the widget being moved)
        if !canPlaceWidget(widget, at: newPosition, excluding: [id]) {
            print("❌ Cannot move \(widget.title) to \(newPosition) - position invalid or occupied")
            return false
        }
        
        let oldPosition = widget.position
        widget.position = newPosition
        widgets[index] = widget
        updateOccupiedPositions()
        
        print("✅ Moved \(widget.title) from \(oldPosition) to \(newPosition)")
        return true
    }
    
    /// Remove all widgets
    func removeAllWidgets() {
        widgets.removeAll()
        occupiedPositions.removeAll()
        print("✅ Removed all widgets from grid")
    }
    
    /// Clear the grid completely (alias for removeAllWidgets)
    func clearGrid() {
        removeAllWidgets()
    }
    
    // MARK: - Layout Operations
    
    /// Optimize the current layout
    func optimizeLayout() {
        let optimizedPlacements = layoutEngine.optimizeLayout(widgets, configuration: configuration)
        
        for (widget, newPosition) in optimizedPlacements {
            if let index = widgets.firstIndex(where: { $0.id == widget.id }) {
                var mutableWidget = widgets[index]
                mutableWidget.position = newPosition
                widgets[index] = mutableWidget
            }
        }
        
        updateOccupiedPositions()
        print("✅ Layout optimized")
    }
    
    /// Validate the current layout
    func validateLayout() -> [LayoutValidationError] {
        return layoutEngine.validateLayout(widgets, configuration: configuration)
    }
    
    // MARK: - Position Queries
    
    /// Check if a position is valid for a widget
    func isValidPosition(_ position: GridPosition, for widget: any GridWidget) -> Bool {
        return configuration.bounds.canFit(widget.size, at: position)
    }
    
    /// Check if a widget can be placed at a position
    func canPlaceWidget(_ widget: any GridWidget, at position: GridPosition, excluding excludeIds: Set<UUID> = []) -> Bool {
        // Check bounds
        guard isValidPosition(position, for: widget) else { 
            print("❌ \(widget.title) at \(position) - invalid bounds")
            return false 
        }
        
        // Check collisions
        let wouldCollide = collisionDetector.wouldCollide(widget, at: position, with: occupiedPositions, excludingIds: excludeIds)
        if wouldCollide {
            print("❌ \(widget.title) at \(position) - collision detected")
        } else {
            print("✅ \(widget.title) at \(position) - placement OK")
        }
        return !wouldCollide
    }
    
    /// Get widget at specific position
    func widget(at position: GridPosition) -> (any GridWidget)? {
        return widgets.first { widget in
            let widgetPositions = widget.size.occupiedPositions(at: widget.position)
            return widgetPositions.contains(position)
        }
    }
    
    // MARK: - Configuration
    
    /// Update grid configuration
    func updateConfiguration(_ newConfiguration: GridConfiguration) {
        self.configuration = newConfiguration
        // Re-validate all widgets with new configuration
        let errors = validateLayout()
        if !errors.isEmpty {
            print("⚠️ Configuration change resulted in \(errors.count) layout errors")
        }
    }
    
    // MARK: - Visual Calculations
    
    /// Calculate visual frame size for a widget
    func frameSize(for widget: any GridWidget) -> CGSize {
        return configuration.frameSize(for: widget.size)
    }
    
    /// Calculate visual position (top-left) for a widget
    func framePosition(for widget: any GridWidget) -> CGPoint {
        return configuration.framePosition(for: widget.position)
    }
    
    /// Calculate center position for a widget
    func centerPosition(for widget: any GridWidget) -> CGPoint {
        return configuration.centerPosition(for: widget.position, size: widget.size)
    }
    
    /// Convert point to grid position
    func gridPosition(from point: CGPoint) -> GridPosition? {
        return configuration.gridPosition(from: point)
    }
    
    /// Current grid dimensions
    var gridSize: CGSize {
        let maxRow = widgets.map { $0.position.row + $0.size.height }.max() ?? 10
        return CGSize(
            width: configuration.gridWidth,
            height: configuration.gridHeight(for: maxRow)
        )
    }
    
    // MARK: - Private Methods
    
    /// Update the cached occupied positions
    private func updateOccupiedPositions() {
        occupiedPositions.removeAll()
        
        for widget in widgets {
            let widgetPositions = widget.size.occupiedPositions(at: widget.position)
            occupiedPositions.formUnion(widgetPositions)
        }
    }
}

// MARK: - Debug
extension GridManager {
    /// Debug description of current state
    var debugDescription: String {
        var description = "GridManager(\(configuration.bounds.description))\n"
        description += "Widgets: \(widgets.count)\n"
        description += "Occupied positions: \(occupiedPositions.count)\n"
        
        for widget in widgets.sorted(by: { $0.position < $1.position }) {
            description += "- \(widget.title) at \(widget.position) (\(widget.size))\n"
        }
        
        return description
    }
}