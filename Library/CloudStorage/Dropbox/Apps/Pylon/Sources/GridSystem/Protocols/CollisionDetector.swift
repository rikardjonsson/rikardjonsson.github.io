//
//  CollisionDetector.swift
//  Pylon
//
//  Created on 06.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation

/// Protocol for detecting collisions between widgets in the grid
protocol CollisionDetector: Sendable {
    /// Check if placing a widget would cause a collision
    /// - Parameters:
    ///   - widget: Widget to check
    ///   - position: Proposed position
    ///   - occupiedPositions: Currently occupied positions
    ///   - excludingIds: Widget IDs to exclude from collision checks
    /// - Returns: True if there would be a collision
    func wouldCollide(
        _ widget: any GridWidget,
        at position: GridPosition,
        with occupiedPositions: Set<GridPosition>,
        excludingIds: Set<UUID>
    ) -> Bool
    
    /// Get all positions that would be occupied by a widget
    /// - Parameters:
    ///   - widget: Widget to check
    ///   - position: Position to check from
    /// - Returns: Set of all positions the widget would occupy
    func occupiedPositions(
        for widget: any GridWidget,
        at position: GridPosition
    ) -> Set<GridPosition>
    
    /// Find all widgets that would collide with a widget at a position
    /// - Parameters:
    ///   - widget: Widget to check
    ///   - position: Proposed position
    ///   - allWidgets: All widgets to check against
    ///   - excludingIds: Widget IDs to exclude
    /// - Returns: Array of colliding widgets
    func findCollidingWidgets(
        for widget: any GridWidget,
        at position: GridPosition,
        among allWidgets: [any GridWidget],
        excludingIds: Set<UUID>
    ) -> [any GridWidget]
    
    /// Check if two widgets would overlap
    /// - Parameters:
    ///   - widget1: First widget
    ///   - position1: Position of first widget
    ///   - widget2: Second widget
    ///   - position2: Position of second widget
    /// - Returns: True if widgets would overlap
    func widgetsOverlap(
        _ widget1: any GridWidget, at position1: GridPosition,
        _ widget2: any GridWidget, at position2: GridPosition
    ) -> Bool
    
    /// Get the collision boundary for a widget
    /// - Parameters:
    ///   - widget: Widget to get boundary for
    ///   - position: Widget position
    /// - Returns: Boundary rectangle as a set of positions
    func collisionBoundary(
        for widget: any GridWidget,
        at position: GridPosition
    ) -> CollisionBoundary
}

// MARK: - Collision Boundary

/// Represents the collision boundary of a widget
struct CollisionBoundary: Sendable {
    let topLeft: GridPosition
    let bottomRight: GridPosition
    let occupiedPositions: Set<GridPosition>
    
    init(topLeft: GridPosition, bottomRight: GridPosition) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
        
        var positions = Set<GridPosition>()
        for row in topLeft.row...bottomRight.row {
            for column in topLeft.column...bottomRight.column {
                positions.insert(GridPosition(row: row, column: column))
            }
        }
        self.occupiedPositions = positions
    }
    
    /// Check if this boundary overlaps with another
    func overlaps(with other: CollisionBoundary) -> Bool {
        !occupiedPositions.isDisjoint(with: other.occupiedPositions)
    }
    
    /// Get overlap positions with another boundary
    func overlapPositions(with other: CollisionBoundary) -> Set<GridPosition> {
        occupiedPositions.intersection(other.occupiedPositions)
    }
}

// MARK: - Collision Result

/// Result of a collision detection operation
struct CollisionResult: Sendable {
    let hasCollision: Bool
    let collidingWidgets: [UUID]
    let conflictPositions: Set<GridPosition>
    
    static let noCollision = CollisionResult(
        hasCollision: false,
        collidingWidgets: [],
        conflictPositions: []
    )
    
    init(hasCollision: Bool, collidingWidgets: [UUID] = [], conflictPositions: Set<GridPosition> = []) {
        self.hasCollision = hasCollision
        self.collidingWidgets = collidingWidgets
        self.conflictPositions = conflictPositions
    }
}