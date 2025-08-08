//
//  WidgetSize.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// Defines the four standardized widget sizes for the new grid system
/// Following tetris-style layout: small (1×1), medium (2×2), large (4×2), xlarge (4×4)
enum WidgetSize: String, CaseIterable, Sendable, Codable {
    case small  // 1×1 grid cells - for simple data (clock, single metric)
    case medium // 2×2 grid cells - for detailed widgets (charts, lists)
    case large  // 4×2 grid cells - for complex widgets (dashboards, tables)
    case xlarge // 4×4 grid cells - for dashboard-style widgets (calendars, analytics)

    /// Display name for the size
    var displayName: String {
        switch self {
        case .small: "Small (1×1)"
        case .medium: "Medium (2×2)"
        case .large: "Large (4×2)"
        case .xlarge: "Extra Large (4×4)"
        }
    }

    /// Grid dimensions for this size (width, height in cells)
    var gridDimensions: (width: Int, height: Int) {
        switch self {
        case .small:  (1, 1) // 1×1 = 1 cell
        case .medium: (2, 2) // 2×2 = 4 cells
        case .large:  (4, 2) // 4×2 = 8 cells
        case .xlarge: (4, 4) // 4×4 = 16 cells
        }
    }
    
    /// Number of grid cells this widget occupies
    var cellCount: Int {
        let dims = gridDimensions
        return dims.width * dims.height
    }
    
    /// Calculate which grid cells this widget would occupy at a given position
    func occupiedCells(at position: GridCell) -> Set<GridCell> {
        let dims = gridDimensions
        var cells = Set<GridCell>()
        
        for row in 0..<dims.height {
            for column in 0..<dims.width {
                let cell = GridCell(row: position.row + row, column: position.column + column)
                cells.insert(cell)
            }
        }
        
        return cells
    }

    /// Calculated frame size based on grid unit
    func frameSize(gridUnit: CGFloat, spacing: CGFloat) -> CGSize {
        let dims = gridDimensions
        let width = CGFloat(dims.width) * gridUnit + CGFloat(dims.width - 1) * spacing
        let height = CGFloat(dims.height) * gridUnit + CGFloat(dims.height - 1) * spacing
        
        // Use full grid space - no more tiny scaling!
        return CGSize(width: width, height: height)
    }

    /// Minimum content area after padding
    var minContentSize: CGSize {
        switch self {
        case .small: CGSize(width: 100, height: 100)
        case .medium: CGSize(width: 220, height: 220)
        case .large: CGSize(width: 440, height: 220)
        case .xlarge: CGSize(width: 440, height: 440)
        }
    }
}
