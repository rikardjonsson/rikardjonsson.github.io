//
//  GridConfiguration.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - System configuration and constants
//

import Foundation
import SwiftUI

/// Configuration for the grid layout system
struct GridConfiguration: Hashable, Codable, Sendable {
    /// Size of each grid cell in points
    let cellSize: CGFloat
    
    /// Spacing between grid cells in points
    let cellSpacing: CGFloat
    
    /// Grid boundaries
    let bounds: GridBounds
    
    /// Initialize with custom configuration
    init(cellSize: CGFloat = 120, cellSpacing: CGFloat = 8, bounds: GridBounds = .standard) {
        precondition(cellSize > 0, "Cell size must be positive")
        precondition(cellSpacing >= 0, "Cell spacing must be non-negative")
        
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
        self.bounds = bounds
    }
}

// MARK: - Presets
extension GridConfiguration {
    /// Standard configuration (120pt cells, 8pt spacing, 8-column unlimited grid)
    static let standard = GridConfiguration()
    
    /// Compact configuration (60pt cells, 3pt spacing, 6-column grid)
    static let compact = GridConfiguration(cellSize: 60, cellSpacing: 3, bounds: .compact)
    
    /// Large configuration (100pt cells, 8pt spacing, 8-column grid)
    static let large = GridConfiguration(cellSize: 100, cellSpacing: 8, bounds: .standard)
}

// MARK: - Calculations
extension GridConfiguration {
    /// Calculate total width needed for the grid
    var gridWidth: CGFloat {
        return CGFloat(bounds.columns) * cellSize + CGFloat(bounds.columns - 1) * cellSpacing
    }
    
    /// Calculate height needed for given number of rows
    func gridHeight(for rows: Int) -> CGFloat {
        guard rows > 0 else { return 0 }
        return CGFloat(rows) * cellSize + CGFloat(rows - 1) * cellSpacing
    }
    
    /// Calculate the visual frame size for a grid size
    func frameSize(for gridSize: GridSize) -> CGSize {
        let width = CGFloat(gridSize.width) * cellSize + CGFloat(gridSize.width - 1) * cellSpacing
        let height = CGFloat(gridSize.height) * cellSize + CGFloat(gridSize.height - 1) * cellSpacing
        return CGSize(width: width, height: height)
    }
    
    /// Calculate the visual position (top-left corner) for a grid position
    func framePosition(for position: GridPosition) -> CGPoint {
        let x = CGFloat(position.column) * (cellSize + cellSpacing)
        let y = CGFloat(position.row) * (cellSize + cellSpacing)
        return CGPoint(x: x, y: y)
    }
    
    /// Calculate the center position for a widget at given grid position
    func centerPosition(for position: GridPosition, size: GridSize) -> CGPoint {
        let topLeft = framePosition(for: position)
        let frameSize = frameSize(for: size)
        return CGPoint(
            x: topLeft.x + frameSize.width / 2,
            y: topLeft.y + frameSize.height / 2
        )
    }
}

// MARK: - Coordinate Conversion
extension GridConfiguration {
    /// Convert a point in the coordinate space to a grid position
    func gridPosition(from point: CGPoint) -> GridPosition? {
        guard point.x >= 0 && point.y >= 0 else { return nil }
        
        let column = Int(point.x / (cellSize + cellSpacing))
        let row = Int(point.y / (cellSize + cellSpacing))
        
        let position = GridPosition(row: row, column: column)
        return bounds.contains(position) ? position : nil
    }
    
    /// Convert a point to grid position with snapping logic
    func snapToGrid(_ point: CGPoint) -> GridPosition? {
        guard let basePosition = gridPosition(from: point) else { return nil }
        
        // Calculate the center of the detected cell
        let cellCenter = centerPosition(for: basePosition, size: .small)
        
        // If point is within cell boundaries, return the position
        let cellBounds = CGRect(
            origin: framePosition(for: basePosition),
            size: frameSize(for: .small)
        )
        
        return cellBounds.contains(point) ? basePosition : nil
    }
}