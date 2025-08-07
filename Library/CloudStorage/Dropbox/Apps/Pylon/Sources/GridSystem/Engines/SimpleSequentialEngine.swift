//
//  SimpleSequentialEngine.swift
//  Pylon
//
//  Created on 07.08.25.
//  Simple sequential layout engine - guaranteed no overlaps
//

import Foundation

/// Simple layout engine that places widgets sequentially without overlaps
/// This is a fallback to ensure the grid system works reliably
struct SimpleSequentialEngine: LayoutEngine {
    
    /// Find the next available position sequentially (left-to-right, top-to-bottom)
    func findAvailablePosition(
        for widget: any GridWidget,
        avoiding occupiedPositions: Set<GridPosition>,
        configuration: GridConfiguration
    ) -> GridPosition? {
        
        let bounds = configuration.bounds
        print("🔍 SimpleSequentialEngine: Finding position for \(widget.title) (size: \(widget.size))")
        
        // Start from top-left, scan row by row
        for row in 0..<50 { // Reasonable max rows
            for column in 0..<bounds.columns {
                let position = GridPosition(row: row, column: column)
                
                // Check if widget fits at this position
                guard bounds.canFit(widget.size, at: position) else { 
                    continue 
                }
                
                // Get all positions this widget would occupy
                let requiredPositions = widget.size.occupiedPositions(at: position)
                
                // Check if any required positions are already occupied
                if requiredPositions.isDisjoint(with: occupiedPositions) {
                    print("✅ SimpleSequentialEngine: Found position \(position) for \(widget.title)")
                    return position
                }
            }
        }
        
        print("❌ SimpleSequentialEngine: No space found for \(widget.title)")
        return nil
    }
    
    /// Validate layout (same as TetrisLayoutEngine)
    func validateLayout(
        _ widgets: [any GridWidget],
        configuration: GridConfiguration
    ) -> [LayoutValidationError] {
        
        var errors: [LayoutValidationError] = []
        var allOccupiedPositions: Set<GridPosition> = []
        
        for widget in widgets {
            let widgetPositions = widget.size.occupiedPositions(at: widget.position)
            let overlappingPositions = widgetPositions.intersection(allOccupiedPositions)
            
            if !overlappingPositions.isEmpty {
                errors.append(.widgetsOverlapping(
                    widgetId1: widget.id,
                    widgetId2: UUID(), // Would need to find the actual overlapping widget
                    positions: overlappingPositions
                ))
            }
            
            allOccupiedPositions.formUnion(widgetPositions)
        }
        
        return errors
    }
    
    /// Simple optimization - just return widgets as-is
    func optimizeLayout(
        _ widgets: [any GridWidget],
        configuration: GridConfiguration
    ) -> [(widget: any GridWidget, position: GridPosition)] {
        
        return widgets.map { widget in
            (widget: widget, position: widget.position)
        }
    }
    
    /// Calculate occupied positions for a widget at a given position
    func occupiedPositions(
        for widget: any GridWidget,
        at position: GridPosition
    ) -> Set<GridPosition> {
        return widget.size.occupiedPositions(at: position)
    }
}