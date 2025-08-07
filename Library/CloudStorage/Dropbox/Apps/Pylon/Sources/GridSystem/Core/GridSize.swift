//
//  GridSize.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Widget size definitions
//

import Foundation

/// Represents the size of a widget in grid units
struct GridSize: Hashable, Codable, Sendable {
    let width: Int   // Number of columns
    let height: Int  // Number of rows
    
    /// Initialize a grid size
    init(width: Int, height: Int) {
        precondition(width > 0, "Width must be positive")
        precondition(height > 0, "Height must be positive")
        self.width = width
        self.height = height
    }
    
    /// Total number of grid cells occupied
    var cellCount: Int {
        return width * height
    }
}

// MARK: - Size Presets
extension GridSize {
    /// Small widget (1×1 grid cells)
    static let small = GridSize(width: 1, height: 1)
    
    /// Medium widget (2×2 grid cells)
    static let medium = GridSize(width: 2, height: 2)
    
    /// Large widget (4×2 grid cells)
    static let large = GridSize(width: 4, height: 2)
    
    /// Extra large widget (4×4 grid cells)
    static let extraLarge = GridSize(width: 4, height: 4)
}

// MARK: - CustomStringConvertible
extension GridSize: CustomStringConvertible {
    var description: String {
        return "\(width)×\(height)"
    }
    
    var displayName: String {
        switch self {
        case .small: return "Small (1×1)"
        case .medium: return "Medium (2×2)"
        case .large: return "Large (4×2)"
        case .extraLarge: return "Extra Large (4×4)"
        default: return "\(width)×\(height)"
        }
    }
}

// MARK: - Geometry Calculations
extension GridSize {
    /// Generate all grid positions that would be occupied by a widget of this size
    /// placed at the given position
    func occupiedPositions(at position: GridPosition) -> Set<GridPosition> {
        var positions = Set<GridPosition>()
        
        for row in 0..<height {
            for column in 0..<width {
                let occupiedPosition = GridPosition(
                    row: position.row + row,
                    column: position.column + column
                )
                positions.insert(occupiedPosition)
            }
        }
        
        return positions
    }
    
    /// Check if this size can fit within given bounds at the specified position
    func fits(at position: GridPosition, within bounds: GridBounds) -> Bool {
        let maxRow = position.row + height - 1
        let maxColumn = position.column + width - 1
        
        return maxRow < bounds.rows && maxColumn < bounds.columns
    }
}