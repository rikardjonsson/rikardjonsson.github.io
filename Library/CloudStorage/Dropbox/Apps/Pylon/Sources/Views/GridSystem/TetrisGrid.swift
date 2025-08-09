//
//  TetrisGrid.swift
//  Pylon
//
//  Created on 06.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

// Bridge to new grid system - GridCell typealias defined in WidgetContainer.swift

/// Main tetris-style grid view for widget placement and arrangement
/// Provides drag-and-drop functionality with collision detection
struct TetrisGrid: View {
    
    // MARK: - Properties
    
    /// Grid manager handling all positioning and collision logic
    @StateObject private var gridManager = GridManager()
    
    /// Currently dragged widget (if any)
    @State private var draggedWidget: (any GridWidget)?
    
    /// Current drag position for preview
    @State private var dragPosition: CGPoint?
    
    /// Highlighted cell during drag operation
    @State private var highlightedCell: GridCell?
    
    /// Whether current drag position is valid
    @State private var dragIsValid = false
    
    /// Previous highlighted cell for hysteresis
    @State private var previousHighlightedCell: GridCell?
    
    /// Widgets to display in the grid
    let widgets: [any GridWidget]
    
    // MARK: - Initialization
    
    init(widgets: [any GridWidget] = []) {
        self.widgets = widgets
    }
    
    // MARK: - Body
    
    var body: some View {
        let gridWidth = gridManager.gridSize.width
        let gridHeight = gridManager.gridSize.height
        
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    colors: [
                        .black.opacity(0.02),
                        .black.opacity(0.08),
                        .black.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: gridWidth, height: gridHeight)
                
                // Grid background with visual feedback
                GridBackground(
                    bounds: gridManager.configuration.bounds,
                    cellSize: gridManager.configuration.cellSize,
                    spacing: gridManager.configuration.cellSpacing,
                    occupiedCells: gridManager.occupiedPositions,
                    highlightedCell: highlightedCell,
                    highlightIsValid: dragIsValid
                )
                .frame(width: gridWidth, height: gridHeight)
                
                // Widgets positioned absolutely using overlays
                Color.clear
                    .frame(width: gridWidth, height: gridHeight)
                    .overlay(alignment: .topLeading) {
                        ForEach(Array(gridManager.widgets.enumerated()), id: \.element.id) { index, widget in
                            let _ = print("📱 Rendering widget \(index): \(widget.title) at (\(widget.position.row),\(widget.position.column))")
                            let position = gridManager.framePosition(for: widget)
                            let size = gridManager.frameSize(for: widget)
                            
                            WidgetView(
                                widget: widget,
                                gridManager: gridManager,
                                isDragged: draggedWidget?.id == widget.id
                            )
                            .frame(width: size.width, height: size.height)
                            .contentShape(Rectangle()) // Ensure entire frame is hit-testable
                            .border(Color.red.opacity(0.5), width: 2) // Debug: Show widget bounds
                            .scaleEffect(draggedWidget?.id == widget.id ? 1.05 : 1.0)
                            .zIndex(draggedWidget?.id == widget.id ? 1000 : Double(index))
                            .offset(x: position.x, y: position.y)
                            .simultaneousGesture(
                                DragGesture(coordinateSpace: .named("TetrisGrid"))
                                    .onChanged { value in
                                        print("🎯 Drag gesture received by: \(widget.title)")
                                        handleDragChanged(widget: widget, value: value)
                                    }
                                    .onEnded { value in
                                        print("🎯 Drag gesture ended for: \(widget.title)")
                                        handleDragEnded(widget: widget, value: value)
                                    }
                            )
                        }
                    }
            }
            .coordinateSpace(name: "TetrisGrid")
        }
        .frame(width: gridWidth)
        .onAppear {
            setupInitialWidgets()
        }
        .onChange(of: widgets.count) { _, _ in
            updateWidgets(widgets)
        }
    }
    
    // MARK: - Setup and Updates
    
    /// Setup initial widgets in the grid
    private func setupInitialWidgets() {
        DebugLog.placement("Setting up \(widgets.count) widgets in TetrisGrid")
        gridManager.removeAllWidgets()
        
        for widget in widgets {
            DebugLog.placement("Placing \(widget.title) (size: \(widget.size))")
            if gridManager.addWidget(widget) {
                DebugLog.placement("Successfully placed \(widget.title)")
            } else {
                DebugLog.critical("No available position for \(widget.title)")
            }
        }
        DebugLog.placement("Setup complete. GridManager now has \(gridManager.widgets.count) widgets")
    }
    
    /// Update widgets when the list changes
    private func updateWidgets(_ newWidgets: [any GridWidget]) {
        // For now, just recreate the layout
        // TODO: Implement more intelligent diffing
        setupInitialWidgets()
    }
    
    // MARK: - Drag Handling
    
    /// Handle drag gesture changes
    private func handleDragChanged(
        widget: any GridWidget,
        value: DragGesture.Value
    ) {
        // Set dragged widget on first drag or if this is a different widget
        if draggedWidget?.id != widget.id {
            draggedWidget = widget
            DebugLog.drag("Started dragging: \(widget.title)")
        }
        
        let currentPosition = value.location
        DebugLog.drag("\(widget.title) at \(currentPosition)")
        
        dragPosition = currentPosition
        
        // Find which grid cell the drag position corresponds to
        if let cell = gridCellFromPoint(currentPosition) {
            DebugLog.coordinate("Mapped to grid cell: (\(cell.row),\(cell.column))")
            highlightedCell = cell
            
            // Check if this position would be valid for the widget
            dragIsValid = gridManager.canPlaceWidget(widget, at: cell, excluding: [widget.id])
            if !dragIsValid {
                DebugLog.coordinate("Position (\(cell.row),\(cell.column)) invalid for \(widget.title)")
            }
        } else {
            highlightedCell = nil
            dragIsValid = false
        }
    }
    
    /// Handle drag gesture end
    private func handleDragEnded(
        widget: any GridWidget,
        value: DragGesture.Value
    ) {
        DebugLog.drag("Drag ended for \(widget.title)")
        
        defer {
            // Clean up drag state
            draggedWidget = nil
            dragPosition = nil
            highlightedCell = nil
            dragIsValid = false
            previousHighlightedCell = nil
        }
        
        // Find target cell for drop
        guard let targetCell = highlightedCell, dragIsValid else {
            if let cell = highlightedCell {
                DebugLog.error("Invalid drop for \(widget.title) at (\(cell.row),\(cell.column))")
            }
            return
        }
        
        // Attempt to move widget to new position
        let success = gridManager.moveWidget(id: widget.id, to: targetCell)
        if success {
            DebugLog.success("Moved \(widget.title) to (\(targetCell.row),\(targetCell.column))")
        } else {
            DebugLog.error("Failed to move \(widget.title) to (\(targetCell.row),\(targetCell.column))")
        }
    }
    
    /// Convert a point in the view to a grid cell with hysteresis
    private func gridCellFromPoint(_ point: CGPoint) -> GridCell? {
        DebugLog.coordinate("Converting point \(point) to grid cell")
        
        // Calculate cell indices from point
        // Grid cells are spaced at regular intervals
        let cellStep = gridManager.configuration.cellSize + gridManager.configuration.cellSpacing
        
        // Map point to grid cell (simple grid-based mapping)
        let column = Int(point.x / cellStep)
        let row = Int(point.y / cellStep)
        
        let newCell = GridCell(row: max(0, row), column: max(0, column))
        
        // Apply hysteresis - only change cell if we've moved significantly
        let finalCell: GridCell
        if let previous = previousHighlightedCell {
            // Calculate distance from previous cell center
            let prevCenterX = CGFloat(previous.column) * cellStep + gridManager.configuration.cellSize / 2
            let prevCenterY = CGFloat(previous.row) * cellStep + gridManager.configuration.cellSize / 2
            let distance = sqrt(pow(point.x - prevCenterX, 2) + pow(point.y - prevCenterY, 2))
            
            // Require moving at least 30% of cell size to change cells
            let hysteresisThreshold = gridManager.configuration.cellSize * 0.3
            if distance < hysteresisThreshold {
                finalCell = previous
            } else {
                finalCell = newCell
                previousHighlightedCell = newCell
            }
        } else {
            finalCell = newCell
            previousHighlightedCell = newCell
        }
        
        // Validate cell is within bounds
        let isValid = gridManager.configuration.bounds.contains(finalCell)
        if !isValid {
            DebugLog.coordinate("Cell (\(finalCell.row),\(finalCell.column)) outside bounds \(gridManager.configuration.bounds)")
        }
        
        return isValid ? finalCell : nil
    }
}

// MARK: - WidgetView

/// Individual widget view within the grid
private struct WidgetView: View {
    let widget: any GridWidget
    let gridManager: GridManager
    let isDragged: Bool
    
    var body: some View {
        ZStack {
            // Main widget background
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(widgetGradient)
                        .opacity(0.15)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
            
            // Widget content
            VStack(spacing: 8) {
                // Icon and title
                HStack(spacing: 8) {
                    widgetIcon
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(widgetAccentColor, in: Circle())
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(widget.title)
                            .font(.system(size: titleFontSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        if widget.size != .small {
                            Text("Last updated now")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                
                if widget.size != .small {
                    // Widget content area
                    Spacer()
                    
                    widgetContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
            }
            .padding(widget.size == .small ? 12 : 16)
        }
        // Size is now handled by the container
        .scaleEffect(isDragged ? 1.02 : 1.0)
        .shadow(
            color: .black.opacity(isDragged ? 0.25 : 0.08),
            radius: isDragged ? 20 : 8,
            x: 0,
            y: isDragged ? 8 : 4
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDragged)
    }
    
    // MARK: - Computed Properties
    
    private var widgetGradient: LinearGradient {
        switch widget.title.lowercased() {
        case "weather":
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "calendar":
            return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "clock":
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "system monitor":
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "finance", "stocks":
            return LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "email":
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "reminders":
            return LinearGradient(colors: [.teal, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "notes":
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "fitness":
            return LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.gray, .secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var widgetAccentColor: Color {
        switch widget.title.lowercased() {
        case "weather": return .blue
        case "calendar": return .red
        case "clock": return .purple
        case "system monitor": return .green
        case "finance", "stocks": return .indigo
        case "email": return .orange
        case "reminders": return .teal
        case "notes": return .yellow
        case "fitness": return .pink
        default: return .gray
        }
    }
    
    private var widgetIcon: Image {
        switch widget.title.lowercased() {
        case "weather": return Image(systemName: "cloud.sun.fill")
        case "calendar": return Image(systemName: "calendar")
        case "clock": return Image(systemName: "clock.fill")
        case "system monitor": return Image(systemName: "cpu")
        case "finance", "stocks": return Image(systemName: "chart.line.uptrend.xyaxis")
        case "email": return Image(systemName: "envelope.fill")
        case "reminders": return Image(systemName: "checklist")
        case "notes": return Image(systemName: "note.text")
        case "fitness": return Image(systemName: "heart.fill")
        default: return Image(systemName: "app.fill")
        }
    }
    
    private var iconSize: CGFloat {
        if widget.size == .small {
            return 14
        } else if widget.size == .medium {
            return 16
        } else if widget.size == .large {
            return 18
        } else if widget.size == .extraLarge {
            return 20
        } else {
            return 16 // Default
        }
    }
    
    private var titleFontSize: CGFloat {
        if widget.size == .small {
            return 12
        } else if widget.size == .medium {
            return 14
        } else if widget.size == .large {
            return 16
        } else if widget.size == .extraLarge {
            return 18
        } else {
            return 14 // Default
        }
    }
    
    @ViewBuilder
    private var widgetContent: some View {
        switch widget.title.lowercased() {
        case "weather":
            VStack(spacing: 4) {
                Text("22°")
                    .font(.system(size: widget.size == .large ? 36 : 28, weight: .thin, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Partly Cloudy")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
        case "calendar":
            VStack(spacing: 8) {
                Text("Today")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(widgetAccentColor)
                                .frame(width: 4, height: 4)
                            Text("Meeting")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
            }
            
        case "system monitor":
            VStack(spacing: 8) {
                HStack {
                    Text("CPU")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("12%")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                
                HStack {
                    Text("Memory")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("8.2 GB")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                
                HStack {
                    Text("Disk")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("256 GB")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
            
        case "finance", "stocks":
            VStack(spacing: 4) {
                HStack {
                    Text("AAPL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("+2.4%")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                Text("$182.50")
                    .font(.system(size: widget.size == .large ? 20 : 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
        default:
            Text("No data")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    // Create some sample widgets for testing
    struct SampleGridWidget: GridWidget {
        let id = UUID()
        var size: GridSize
        var position = GridPosition.zero
        
        let title: String
        let category: GridWidgetCategory
        let type: String
        let lastUpdated: Date? = Date()
        let isLoading = false
        let error: (any Error)? = nil
        
        @MainActor
        func refresh() async throws {
            // No-op for sample widget
        }
        
        @MainActor
        func body(theme: any Theme, configuration: GridConfiguration) -> AnyView {
            AnyView(EmptyView())
        }
    }
    
    let sampleWidgets: [any GridWidget] = [
        SampleGridWidget(size: .small, title: "Clock", category: .productivity, type: "clock"),
        SampleGridWidget(size: .medium, title: "Weather", category: .information, type: "weather"),
        SampleGridWidget(size: .large, title: "Calendar", category: .productivity, type: "calendar"),
        SampleGridWidget(size: .small, title: "Stocks", category: .information, type: "stocks")
    ]
    
    return TetrisGrid(widgets: sampleWidgets)
        .frame(width: 900, height: 700)
        .background(.windowBackground)
}