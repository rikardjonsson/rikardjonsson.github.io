//
//  GridBounds.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Grid boundaries and validation
//

import Foundation

/// Defines the boundaries and constraints of the grid system
struct GridBounds: Hashable, Sendable, Codable {
    let columns: Int    // Maximum number of columns (fixed at 8)
    let rows: Int       // Maximum number of rows (can be unlimited)
    
    /// Initialize grid bounds
    init(columns: Int, rows: Int = Int.max) {
        precondition(columns > 0, "Columns must be positive")
        precondition(rows > 0, "Rows must be positive")
        self.columns = columns
        self.rows = rows
    }
    
    /// Total number of cells in bounded grid (Int.max for unlimited rows)
    var totalCells: Int {
        return rows == Int.max ? Int.max : columns * rows
    }
    
    /// Whether this grid has unlimited vertical space
    var isUnlimited: Bool {
        return rows == Int.max
    }
}

// MARK: - Standard Configurations
extension GridBounds {
    /// Standard 8-column grid with unlimited rows (main configuration)
    static let standard = GridBounds(columns: 8, rows: Int.max)
    
    /// Compact 6-column grid with unlimited rows
    static let compact = GridBounds(columns: 6, rows: Int.max)
    
    /// Desktop testing grid (8×12)
    static let desktop = GridBounds(columns: 8, rows: 12)
}

// MARK: - Validation
extension GridBounds {
    /// Check if a position is within the grid bounds
    func contains(_ position: GridPosition) -> Bool {
        return position.row >= 0 && position.row < rows &&
               position.column >= 0 && position.column < columns
    }
    
    /// Check if a widget of given size can fit at the specified position
    func canFit(_ size: GridSize, at position: GridPosition) -> Bool {
        guard contains(position) else { return false }
        return size.fits(at: position, within: self)
    }
    
    /// Generate all valid positions within the bounds
    func allPositions(upTo maxRows: Int? = nil) -> Set<GridPosition> {
        let effectiveRows = min(rows, maxRows ?? rows)
        var positions = Set<GridPosition>()
        
        for row in 0..<effectiveRows {
            for column in 0..<columns {
                positions.insert(GridPosition(row: row, column: column))
            }
        }
        
        return positions
    }
}

// MARK: - Geometry
extension GridBounds {
    /// Get all positions occupied by a widget of given size at given position
    func occupiedPositions(size: GridSize, at position: GridPosition) -> Set<GridPosition> {
        guard canFit(size, at: position) else { return [] }
        return size.occupiedPositions(at: position)
    }
    
    /// Calculate the minimum rows needed to accommodate widgets up to a certain row
    func minimumRows(containing positions: Set<GridPosition>) -> Int {
        guard !positions.isEmpty else { return 0 }
        let maxRow = positions.map(\.row).max() ?? 0
        return maxRow + 1
    }
}

// MARK: - CustomStringConvertible
extension GridBounds: CustomStringConvertible {
    var description: String {
        if isUnlimited {
            return "\(columns)-column grid (unlimited rows)"
        } else {
            return "\(columns)×\(rows) grid (\(totalCells) cells)"
        }
    }
}