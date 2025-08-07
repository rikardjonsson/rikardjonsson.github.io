//
//  LayoutEngine.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Layout algorithm interface
//

import Foundation

/// Protocol defining a layout engine for widget placement
protocol LayoutEngine: Sendable {
    /// Find an available position for a widget
    /// - Parameters:
    ///   - widget: The widget to place
    ///   - occupiedPositions: Currently occupied grid positions
    ///   - configuration: Grid configuration
    /// - Returns: Available position, or nil if no space
    func findAvailablePosition(
        for widget: any GridWidget,
        avoiding occupiedPositions: Set<GridPosition>,
        configuration: GridConfiguration
    ) -> GridPosition?
    
    /// Validate that all widgets in the layout don't collide
    /// - Parameters:
    ///   - widgets: Widgets to validate
    ///   - configuration: Grid configuration
    /// - Returns: Array of validation errors
    func validateLayout(
        _ widgets: [any GridWidget],
        configuration: GridConfiguration
    ) -> [LayoutValidationError]
    
    /// Optimize the layout by repositioning widgets for better space utilization
    /// - Parameters:
    ///   - widgets: Current widgets
    ///   - configuration: Grid configuration
    /// - Returns: Optimized widget positions
    func optimizeLayout(
        _ widgets: [any GridWidget],
        configuration: GridConfiguration
    ) -> [(widget: any GridWidget, position: GridPosition)]
    
    /// Calculate all positions that would be occupied by a widget at given position
    /// - Parameters:
    ///   - widget: The widget
    ///   - position: Position to check
    /// - Returns: Set of occupied positions
    func occupiedPositions(
        for widget: any GridWidget,
        at position: GridPosition
    ) -> Set<GridPosition>
}

/// Validation error types for layout checking
enum LayoutValidationError: Error, Equatable {
    case widgetOutOfBounds(widgetId: UUID, position: GridPosition, size: GridSize)
    case widgetsOverlapping(widgetId1: UUID, widgetId2: UUID, positions: Set<GridPosition>)
    case duplicateWidgetId(UUID)
    case invalidPosition(widgetId: UUID, position: GridPosition)
    case invalidSize(widgetId: UUID, size: GridSize)
    
    var localizedDescription: String {
        switch self {
        case .widgetOutOfBounds(let id, let position, let size):
            return "Widget \(id) at \(position) with size \(size) extends outside grid bounds"
        case .widgetsOverlapping(let id1, let id2, let positions):
            return "Widgets \(id1) and \(id2) overlap at positions: \(positions)"
        case .duplicateWidgetId(let id):
            return "Duplicate widget ID found: \(id)"
        case .invalidPosition(let id, let position):
            return "Widget \(id) has invalid position: \(position)"
        case .invalidSize(let id, let size):
            return "Widget \(id) has invalid size: \(size)"
        }
    }
}

// Note: CollisionDetector protocol is defined in CollisionDetector.swift