//
//  GridBackground.swift
//  Pylon
//
//  Created on 06.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

// Bridge to new grid system - GridCell typealias defined in WidgetContainer.swift

/// Visual grid background showing all available grid cells
/// Provides clear visual feedback for widget placement
struct GridBackground: View {
    
    // MARK: - Properties
    
    /// Grid bounds defining the number of rows and columns
    let bounds: GridBounds
    
    /// Size of each grid cell in points
    let cellSize: CGFloat
    
    /// Spacing between grid cells
    let spacing: CGFloat
    
    /// Set of currently occupied cells (to highlight differently)
    let occupiedCells: Set<GridPosition>
    
    /// Currently highlighted cell (during drag operations)
    let highlightedCell: GridPosition?
    
    /// Whether highlight is valid (green) or invalid (red)
    let highlightIsValid: Bool
    
    // MARK: - Initialization
    
    init(
        bounds: GridBounds,
        cellSize: CGFloat = 100,
        spacing: CGFloat = 4,
        occupiedCells: Set<GridPosition> = [],
        highlightedCell: GridPosition? = nil,
        highlightIsValid: Bool = true
    ) {
        self.bounds = bounds
        self.cellSize = cellSize
        self.spacing = spacing
        self.occupiedCells = occupiedCells
        self.highlightedCell = highlightedCell
        self.highlightIsValid = highlightIsValid
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Subtle grid pattern (only show when dragging)
            if highlightedCell != nil {
                ForEach(0..<bounds.rows, id: \.self) { row in
                    ForEach(0..<bounds.columns, id: \.self) { column in
                        let cell = GridPosition(row: row, column: column)
                        let isOccupied = occupiedCells.contains(cell)
                        let isHighlighted = cell == highlightedCell
                        
                        GridCellView(
                            cell: cell,
                            isOccupied: isOccupied,
                            isHighlighted: isHighlighted,
                            highlightIsValid: highlightIsValid
                        )
                        .frame(width: cellSize, height: cellSize)
                        .position(cellPosition(for: cell))
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: highlightedCell != nil)
    }
    
    // MARK: - Layout Calculations
    
    /// Calculate the position for a grid cell
    private func cellPosition(for cell: GridPosition) -> CGPoint {
        let x = CGFloat(cell.column) * (cellSize + spacing) + cellSize / 2
        let y = CGFloat(cell.row) * (cellSize + spacing) + cellSize / 2
        DebugLog.grid("GridBackground: cell (\(cell.row),\(cell.column)) -> position (\(x), \(y))")
        return CGPoint(x: x, y: y)
    }
    
    /// Total width of the grid
    private var gridWidth: CGFloat {
        CGFloat(bounds.columns) * cellSize + CGFloat(bounds.columns - 1) * spacing
    }
    
    /// Total height of the grid
    private var gridHeight: CGFloat {
        CGFloat(bounds.rows) * cellSize + CGFloat(bounds.rows - 1) * spacing
    }
}

// MARK: - GridCellView

/// Individual grid cell with different visual states
private struct GridCellView: View {
    let cell: GridPosition
    let isOccupied: Bool
    let isHighlighted: Bool
    let highlightIsValid: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(strokeColor, lineWidth: strokeWidth)
            )
            .scaleEffect(isHighlighted ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHighlighted)
    }
    
    // MARK: - Colors and Styling
    
    private var fillColor: Color {
        if isHighlighted {
            return highlightIsValid ? 
                Color.green.opacity(0.2) : 
                Color.red.opacity(0.2)
        } else if isOccupied {
            return .secondary.opacity(0.05)
        } else {
            return .clear
        }
    }
    
    private var strokeColor: Color {
        if isHighlighted {
            return highlightIsValid ? 
                Color.green.opacity(0.8) : 
                Color.red.opacity(0.8)
        } else if isOccupied {
            return .secondary.opacity(0.2)
        } else {
            return .secondary.opacity(0.1)
        }
    }
    
    private var strokeWidth: CGFloat {
        if isHighlighted {
            return 2.0
        } else if isOccupied {
            return 1.0
        } else {
            return 0.5
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Grid Background Examples")
            .font(.headline)
        
        // Empty grid
        GridBackground(
            bounds: GridBounds(columns: 4, rows: 6),
            cellSize: 60,
            spacing: 3
        )
        .background(.windowBackground)
        
        // Grid with some occupied cells
        GridBackground(
            bounds: GridBounds(columns: 4, rows: 6),
            cellSize: 60,
            spacing: 3,
            occupiedCells: [
                GridPosition(row: 0, column: 0),
                GridPosition(row: 0, column: 1),
                GridPosition(row: 1, column: 0),
                GridPosition(row: 1, column: 1),
                GridPosition(row: 3, column: 2)
            ],
            highlightedCell: GridPosition(row: 2, column: 1),
            highlightIsValid: true
        )
        .background(.windowBackground)
    }
    .padding()
}