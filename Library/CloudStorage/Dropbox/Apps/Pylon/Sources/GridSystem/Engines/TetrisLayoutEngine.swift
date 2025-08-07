//
//  TetrisLayoutEngine.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Tetris-style placement algorithm
//

import Foundation

/// Layout engine that places widgets using Tetris-like top-to-bottom, left-to-right logic
struct TetrisLayoutEngine: LayoutEngine {
    
    /// Find the first available position for a widget using tetris placement logic
    func findAvailablePosition(
        for widget: any GridWidget,
        avoiding occupiedPositions: Set<GridPosition>,
        configuration: GridConfiguration
    ) -> GridPosition? {
        
        let bounds = configuration.bounds
        
        print("🔍 TetrisLayoutEngine: Finding position for \(widget.title) (size: \(widget.size))")
        print("🔍 Grid bounds: \(bounds), occupied positions: \(occupiedPositions)")
        
        // For unlimited grids, we need to determine the current height
        let maxRow: Int
        if bounds.isUnlimited {
            // Find the bottom-most occupied position + some buffer
            let currentMaxRow = occupiedPositions.map(\.row).max() ?? 0
            maxRow = max(currentMaxRow + widget.size.height, 20) // At least 20 rows to scan
            print("🔍 Unlimited grid, scanning up to row \(maxRow)")
        } else {
            maxRow = bounds.rows
            print("🔍 Limited grid, scanning up to row \(maxRow)")
        }
        
        // Scan from top-left to bottom-right (Tetris-style)
        for row in 0..<maxRow {
            for column in 0..<bounds.columns {
                let position = GridPosition(row: row, column: column)
                
                // Check if widget fits within bounds at this position
                guard bounds.canFit(widget.size, at: position) else { 
                    print("🔍 Position (\(row),\(column)) doesn't fit in bounds")
                    continue 
                }
                
                // Check for collisions
                let requiredPositions = widget.size.occupiedPositions(at: position)
                if requiredPositions.isDisjoint(with: occupiedPositions) {
                    print("✅ Found available position: (\(row),\(column))")
                    return position
                } else {
                    print("🔍 Position (\(row),\(column)) has collision")
                }
            }
        }
        
        print("❌ No space available for \(widget.title)")
        return nil // No space available
    }
    
    /// Validate layout for conflicts and boundary issues
    func validateLayout(
        _ widgets: [any GridWidget],
        configuration: GridConfiguration
    ) -> [LayoutValidationError] {
        
        var errors: [LayoutValidationError] = []
        var allOccupiedPositions: Set<GridPosition> = []
        var seenIds: Set<UUID> = []
        
        for widget in widgets {
            // Check for duplicate IDs
            if seenIds.contains(widget.id) {
                errors.append(.duplicateWidgetId(widget.id))
                continue
            }
            seenIds.insert(widget.id)
            
            // Validate position
            if widget.position.row < 0 || widget.position.column < 0 {
                errors.append(.invalidPosition(widgetId: widget.id, position: widget.position))
                continue
            }
            
            // Validate size
            if widget.size.width <= 0 || widget.size.height <= 0 {
                errors.append(.invalidSize(widgetId: widget.id, size: widget.size))
                continue
            }
            
            // Check bounds
            if !configuration.bounds.canFit(widget.size, at: widget.position) {
                errors.append(.widgetOutOfBounds(
                    widgetId: widget.id,
                    position: widget.position,
                    size: widget.size
                ))
                continue
            }
            
            // Check for overlaps
            let widgetPositions = occupiedPositions(for: widget, at: widget.position)
            let overlappingPositions = widgetPositions.intersection(allOccupiedPositions)
            
            if !overlappingPositions.isEmpty {
                // Find which widget(s) we're overlapping with
                for otherWidget in widgets where otherWidget.id != widget.id {
                    let otherPositions = occupiedPositions(for: otherWidget, at: otherWidget.position)
                    let commonPositions = widgetPositions.intersection(otherPositions)
                    
                    if !commonPositions.isEmpty {
                        errors.append(.widgetsOverlapping(
                            widgetId1: widget.id,
                            widgetId2: otherWidget.id,
                            positions: commonPositions
                        ))
                    }
                }
            }
            
            allOccupiedPositions.formUnion(widgetPositions)
        }
        
        return errors
    }
    
    /// Optimize layout by compacting widgets toward the top-left
    func optimizeLayout(
        _ widgets: [any GridWidget],
        configuration: GridConfiguration
    ) -> [(widget: any GridWidget, position: GridPosition)] {
        
        // Sort widgets by their current position (top-to-bottom, left-to-right)
        let sortedWidgets = widgets.sorted { lhs, rhs in
            if lhs.position.row == rhs.position.row {
                return lhs.position.column < rhs.position.column
            }
            return lhs.position.row < rhs.position.row
        }
        
        var optimizedPlacements: [(widget: any GridWidget, position: GridPosition)] = []
        var occupiedPositions: Set<GridPosition> = []
        
        // Re-place each widget in the optimal position
        for widget in sortedWidgets {
            if let optimalPosition = findAvailablePosition(
                for: widget,
                avoiding: occupiedPositions,
                configuration: configuration
            ) {
                optimizedPlacements.append((widget: widget, position: optimalPosition))
                let widgetPositions = self.occupiedPositions(for: widget, at: optimalPosition)
                occupiedPositions.formUnion(widgetPositions)
            } else {
                // Keep original position if no better one found
                optimizedPlacements.append((widget: widget, position: widget.position))
                let widgetPositions = self.occupiedPositions(for: widget, at: widget.position)
                occupiedPositions.formUnion(widgetPositions)
            }
        }
        
        return optimizedPlacements
    }
    
    /// Calculate occupied positions for a widget at a given position
    func occupiedPositions(
        for widget: any GridWidget,
        at position: GridPosition
    ) -> Set<GridPosition> {
        return widget.size.occupiedPositions(at: position)
    }
}