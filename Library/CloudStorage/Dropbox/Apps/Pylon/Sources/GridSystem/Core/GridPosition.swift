//
//  GridPosition.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Core coordinate system
//

import Foundation

/// Represents a position in the grid coordinate system
/// Origin (0,0) is at top-left, with positive values extending right and down
struct GridPosition: Hashable, Codable, Sendable {
    let row: Int
    let column: Int
    
    /// Initialize a grid position
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
    
    /// Zero position (top-left corner)
    static let zero = GridPosition(row: 0, column: 0)
}

// MARK: - Comparable
extension GridPosition: Comparable {
    static func < (lhs: GridPosition, rhs: GridPosition) -> Bool {
        if lhs.row == rhs.row {
            return lhs.column < rhs.column
        }
        return lhs.row < rhs.row
    }
}

// MARK: - CustomStringConvertible
extension GridPosition: CustomStringConvertible {
    var description: String {
        return "(\(row),\(column))"
    }
}

// MARK: - Arithmetic Operations
extension GridPosition {
    /// Add offset to position
    func offset(by rowOffset: Int, _ columnOffset: Int) -> GridPosition {
        return GridPosition(row: row + rowOffset, column: column + columnOffset)
    }
    
    /// Calculate distance to another position
    func distance(to other: GridPosition) -> Double {
        let deltaRow = Double(other.row - row)
        let deltaColumn = Double(other.column - column)
        return sqrt(deltaRow * deltaRow + deltaColumn * deltaColumn)
    }
}