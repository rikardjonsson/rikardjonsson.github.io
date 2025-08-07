//
//  SimpleCollisionDetector.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Collision detection implementation
//

import Foundation

/// Simple collision detector using set-based position checking
struct SimpleCollisionDetector: CollisionDetector {
    
    /// Check if placing a widget would cause a collision
    func wouldCollide(
        _ widget: any GridWidget,
        at position: GridPosition,
        with occupiedPositions: Set<GridPosition>,
        excludingIds: Set<UUID>
    ) -> Bool {
        let requiredPositions = widget.size.occupiedPositions(at: position)
        return !requiredPositions.isDisjoint(with: occupiedPositions)
    }
    
    /// Get all positions that would be occupied by a widget
    func occupiedPositions(
        for widget: any GridWidget,
        at position: GridPosition
    ) -> Set<GridPosition> {
        return widget.size.occupiedPositions(at: position)
    }
    
    /// Find all widgets that would collide with a widget at a position
    func findCollidingWidgets(
        for widget: any GridWidget,
        at position: GridPosition,
        among allWidgets: [any GridWidget],
        excludingIds: Set<UUID>
    ) -> [any GridWidget] {
        let requiredPositions = widget.size.occupiedPositions(at: position)
        
        return allWidgets.filter { otherWidget in
            // Skip excluded widgets and self
            guard !excludingIds.contains(otherWidget.id) && otherWidget.id != widget.id else {
                return false
            }
            
            let otherPositions = otherWidget.size.occupiedPositions(at: otherWidget.position)
            return !requiredPositions.isDisjoint(with: otherPositions)
        }
    }
    
    /// Check if two widgets would overlap
    func widgetsOverlap(
        _ widget1: any GridWidget, at position1: GridPosition,
        _ widget2: any GridWidget, at position2: GridPosition
    ) -> Bool {
        let positions1 = widget1.size.occupiedPositions(at: position1)
        let positions2 = widget2.size.occupiedPositions(at: position2)
        return !positions1.isDisjoint(with: positions2)
    }
    
    /// Get the collision boundary for a widget
    func collisionBoundary(
        for widget: any GridWidget,
        at position: GridPosition
    ) -> CollisionBoundary {
        let size = widget.size
        let topLeft = position
        let bottomRight = GridPosition(
            row: position.row + size.height - 1,
            column: position.column + size.width - 1
        )
        return CollisionBoundary(topLeft: topLeft, bottomRight: bottomRight)
    }
}

// MARK: - Optimized Collision Detection
extension SimpleCollisionDetector {
    /// Fast collision check using bounding box intersection
    func wouldCollideFast(
        _ widget: any GridWidget,
        at position: GridPosition,
        with otherWidget: any GridWidget,
        at otherPosition: GridPosition
    ) -> Bool {
        // Calculate bounding boxes
        let rect1 = GridRect(position: position, size: widget.size)
        let rect2 = GridRect(position: otherPosition, size: otherWidget.size)
        
        return rect1.intersects(rect2)
    }
}

/// Helper struct for efficient bounding box calculations
private struct GridRect {
    let minRow: Int
    let maxRow: Int
    let minColumn: Int
    let maxColumn: Int
    
    init(position: GridPosition, size: GridSize) {
        self.minRow = position.row
        self.maxRow = position.row + size.height - 1
        self.minColumn = position.column
        self.maxColumn = position.column + size.width - 1
    }
    
    func intersects(_ other: GridRect) -> Bool {
        return !(maxRow < other.minRow ||
                minRow > other.maxRow ||
                maxColumn < other.minColumn ||
                minColumn > other.maxColumn)
    }
}