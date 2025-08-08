//
//  GridContainerView.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Main grid container
//

import SwiftUI
import Foundation

/// Main container view for the grid system
struct GridContainerView: View {
    
    /// Grid manager (observed for changes)
    @State private var gridManager: GridManager
    
    /// Theme for styling
    let theme: any Theme
    
    /// Widget manager for synchronization (optional)
    let widgetManager: WidgetManager?
    
    /// Current drag state
    @State private var draggedWidget: UUID?
    @State private var dragPosition: CGPoint = .zero
    @State private var dragPreviewPosition: GridPosition?
    @State private var isDragValid: Bool = false
    @State private var dragOffset: CGSize = .zero
    
    /// Initialize with configuration
    init(
        configuration: GridConfiguration = .standard,
        theme: any Theme,
        widgets: [any GridWidget] = [],
        widgetManager: WidgetManager? = nil
    ) {
        let manager = GridManager(configuration: configuration)
        
        // Add initial widgets
        print("🚀 GridContainerView initializing with \(widgets.count) widgets")
        for widget in widgets {
            print("🔧 Adding widget: \(widget.title) at \(widget.position)")
            manager.addWidget(widget)
        }
        
        self._gridManager = State(initialValue: manager)
        self.theme = theme
        self.widgetManager = widgetManager
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                // Background
                backgroundView
                
                // Enhanced grid visualization during drag
                if draggedWidget != nil {
                    enhancedGridBackgroundView
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
                
                // Drag preview overlay
                if let draggedId = draggedWidget,
                   let draggedWidget = gridManager.widgets.first(where: { $0.id == draggedId }) {
                    DragPreviewView(
                        widget: draggedWidget,
                        theme: theme,
                        configuration: gridManager.configuration,
                        isValid: isDragValid,
                        targetPosition: dragPreviewPosition
                    )
                    .offset(dragOffset)
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Widget container
                widgetContainer
            }
            .frame(
                width: gridManager.configuration.gridWidth,
                height: gridManager.gridSize.height
            )
            .coordinateSpace(name: "GridContainer")
        }
        .frame(width: gridManager.configuration.gridWidth)
        .clipped()
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                theme.backgroundColor.opacity(0.02),
                theme.backgroundColor.opacity(0.08),
                theme.backgroundColor.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: gridManager.configuration.gridWidth, height: gridManager.gridSize.height)
    }
    
    // MARK: - Grid Background Views
    
    @ViewBuilder  
    private var enhancedGridBackgroundView: some View {
        let config = gridManager.configuration
        let maxRows = Int(gridManager.gridSize.height / (config.cellSize + config.cellSpacing)) + 2
        
        // Drop zone indicators for current widget size
        if let draggedId = draggedWidget,
           let draggedWidget = gridManager.widgets.first(where: { $0.id == draggedId }) {
            
            ForEach(0..<maxRows, id: \.self) { row in
                ForEach(0..<config.bounds.columns, id: \.self) { column in
                    let position = GridPosition(row: row, column: column)
                    let isHighlighted = position == dragPreviewPosition
                    let isValid = gridManager.canPlaceWidget(
                        draggedWidget, 
                        at: position, 
                        excluding: [draggedId]
                    )
                    
                    if isHighlighted {
                        DropZoneIndicator(
                            position: position,
                            size: draggedWidget.size,
                            isHighlighted: isHighlighted,
                            isValid: isValid,
                            theme: theme,
                            configuration: config
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var gridBackgroundView: some View {
        let config = gridManager.configuration
        let maxRows = Int(gridManager.gridSize.height / (config.cellSize + config.cellSpacing)) + 2
        
        ForEach(0..<maxRows, id: \.self) { row in
            ForEach(0..<config.bounds.columns, id: \.self) { column in
                let position = GridPosition(row: row, column: column)
                let isOccupied = gridManager.occupiedPositions.contains(position)
                let isHighlighted = position == dragPreviewPosition
                
                GridCellView(
                    position: position,
                    isOccupied: isOccupied,
                    isHighlighted: isHighlighted,
                    isValid: dragPreviewPosition == position ? isDragPositionValid : true,
                    theme: theme,
                    configuration: config
                )
            }
        }
    }
    
    // MARK: - Widget Container
    
    @ViewBuilder
    private var widgetContainer: some View {
        ForEach(Array(gridManager.widgets.enumerated()), id: \.element.id) { index, widget in
            let framePosition = gridManager.framePosition(for: widget)
            
            WidgetContainerView(
                widget: widget,
                theme: theme,
                configuration: gridManager.configuration,
                isDragged: draggedWidget == widget.id
            )
            .position(
                x: framePosition.x + gridManager.frameSize(for: widget).width / 2,
                y: framePosition.y + gridManager.frameSize(for: widget).height / 2
            )
            .zIndex(draggedWidget == widget.id ? 1000 : Double(index))
            .gesture(
                widgetDragGesture(for: widget)
            )
        }
    }
    
    // MARK: - Drag Gesture
    
    private func widgetDragGesture(for widget: any GridWidget) -> some Gesture {
        DragGesture(coordinateSpace: .named("GridContainer"))
            .onChanged { value in
                handleDragChanged(widget: widget, value: value)
            }
            .onEnded { value in
                handleDragEnded(widget: widget, value: value)
            }
    }
    
    private func handleDragChanged(widget: any GridWidget, value: DragGesture.Value) {
        // Set dragged widget if not already set
        if draggedWidget != widget.id {
            draggedWidget = widget.id
        }
        
        dragPosition = value.location
        dragOffset = value.translation
        
        // Calculate preview position and validity
        if let previewPosition = gridManager.gridPosition(from: dragPosition) {
            let newPreviewPosition = previewPosition
            let isValid = gridManager.canPlaceWidget(widget, at: newPreviewPosition, excluding: [widget.id])
            
            // Update state with animation
            withAnimation(.easeOut(duration: 0.1)) {
                dragPreviewPosition = newPreviewPosition
                isDragValid = isValid
            }
        } else {
            dragPreviewPosition = nil
            isDragValid = false
        }
    }
    
    private func handleDragEnded(widget: any GridWidget, value: DragGesture.Value) {
        let shouldMove = dragPreviewPosition != nil && isDragValid
        
        // Animate the drop
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            // Attempt to move widget to preview position
            if let targetPosition = dragPreviewPosition, shouldMove {
                // Use WidgetManager if available, otherwise use GridManager directly
                if let widgetManager = widgetManager {
                    let success = widgetManager.moveContainer(id: widget.id, to: targetPosition)
                    if !success {
                        print("⚠️ Failed to move widget via WidgetManager")
                    }
                } else {
                    gridManager.moveWidget(id: widget.id, to: targetPosition)
                }
            }
            
            // Clean up drag state with animation
            draggedWidget = nil
            dragPreviewPosition = nil
            isDragValid = false
            dragOffset = .zero
        }
        
        // Haptic feedback for macOS (through system sounds)
        if shouldMove {
            NSSound.beep() // Success sound
        }
    }
    
    // MARK: - Computed Properties
    
    private var isDragPositionValid: Bool {
        guard let draggedId = draggedWidget,
              let previewPosition = dragPreviewPosition,
              let widget = gridManager.widgets.first(where: { $0.id == draggedId }) else {
            return false
        }
        
        return gridManager.canPlaceWidget(widget, at: previewPosition, excluding: [draggedId])
    }
}

// MARK: - Grid Cell View

/// Individual grid cell visualization
private struct GridCellView: View {
    let position: GridPosition
    let isOccupied: Bool
    let isHighlighted: Bool
    let isValid: Bool
    let theme: any Theme
    let configuration: GridConfiguration
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: strokeWidth)
            .frame(
                width: configuration.cellSize,
                height: configuration.cellSize
            )
            .position(
                x: configuration.framePosition(for: position).x + configuration.cellSize / 2,
                y: configuration.framePosition(for: position).y + configuration.cellSize / 2
            )
            .scaleEffect(isHighlighted ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHighlighted)
    }
    
    private var fillColor: Color {
        if isHighlighted {
            return isValid ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        } else if isOccupied {
            return theme.backgroundColor.opacity(0.05)
        } else {
            return Color.clear
        }
    }
    
    private var strokeColor: Color {
        if isHighlighted {
            return isValid ? Color.green.opacity(0.8) : Color.red.opacity(0.8)
        } else if isOccupied {
            return theme.secondaryColor.opacity(0.2)
        } else {
            return theme.secondaryColor.opacity(0.1)
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

// MARK: - Public Interface
extension GridContainerView {
    /// Add a widget to the grid
    func addWidget(_ widget: any GridWidget) {
        gridManager.addWidget(widget)
    }
    
    /// Remove a widget from the grid
    func removeWidget(id: UUID) {
        gridManager.removeWidget(id: id)
    }
    
    /// Get current widgets
    var widgets: [any GridWidget] {
        gridManager.widgets
    }
}