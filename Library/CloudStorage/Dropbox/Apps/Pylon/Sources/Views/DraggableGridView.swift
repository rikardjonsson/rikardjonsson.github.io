//
//  DraggableGridView.swift
//  Pylon
//
//  Created on 05.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// Enhanced grid layout system with drag & drop support for widget rearrangement
/// Supports responsive columns, drag and drop reordering, and layout persistence
struct DraggableGridView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.theme) private var theme
    
    @State private var draggedWidget: (any WidgetContainer)?
    @State private var dragOffset: CGSize = .zero
    @State private var dragPosition: CGPoint = .zero
    @State private var dropTargetPosition: GridPosition?
    
    private let gridConfig: GridConfiguration
    private let containers: [any WidgetContainer]
    
    init(gridConfig: GridConfiguration, containers: [any WidgetContainer]) {
        self.gridConfig = gridConfig
        self.containers = containers
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background with guides
                gridBackground(in: geometry)
                
                // Widget containers
                ForEach(Array(containers.enumerated()), id: \.element.id) { index, container in
                    let gridPosition = calculateGridPosition(for: index, in: geometry)
                    
                    DraggableWidgetView(
                        container: container,
                        position: gridPosition,
                        gridConfig: gridConfig,
                        isDragging: draggedWidget?.id == container.id,
                        onDragChanged: { value in
                            handleDragChanged(container: container, value: value, geometry: geometry)
                        },
                        onDragEnded: { value in
                            handleDragEnded(container: container, value: value, geometry: geometry)
                        }
                    )
                    .zIndex(draggedWidget?.id == container.id ? 1000 : Double(index))
                }
                
                // Drop target indicator
                if let dropTarget = dropTargetPosition {
                    dropTargetIndicator(at: dropTarget, in: geometry)
                }
            }
        }
        .background(Color.clear)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dropTargetPosition)
    }
    
    // MARK: - Grid Background
    
    private func gridBackground(in geometry: GeometryProxy) -> some View {
        let availableWidth = geometry.size.width - gridConfig.padding.leading - gridConfig.padding.trailing
        let actualColumns = max(1, min(gridConfig.columns, Int(availableWidth / (gridConfig.gridUnit + gridConfig.spacing))))
        
        return VStack(spacing: 0) {
            ForEach(0..<10, id: \.self) { row in // Show up to 10 rows
                HStack(spacing: gridConfig.spacing) {
                    ForEach(0..<actualColumns, id: \.self) { column in
                        Rectangle()
                            .fill(theme.backgroundMaterial.opacity(0.05))
                            .frame(width: gridConfig.gridUnit, height: gridConfig.gridUnit)
                            .overlay(
                                Rectangle()
                                    .stroke(theme.accentColor.opacity(0.1), lineWidth: 0.5)
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, gridConfig.padding.leading)
                
                if row < 9 {
                    Spacer().frame(height: gridConfig.spacing)
                }
            }
        }
        .opacity(draggedWidget != nil ? 0.3 : 0.0)
        .animation(.easeInOut(duration: 0.2), value: draggedWidget != nil)
    }
    
    // MARK: - Drop Target Indicator
    
    private func dropTargetIndicator(at position: GridPosition, in geometry: GeometryProxy) -> some View {
        let frame = frameForGridPosition(position, in: geometry)
        
        return RoundedRectangle(cornerRadius: 12)
            .fill(theme.accentColor.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.accentColor, lineWidth: 2)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
            )
            .frame(width: frame.width, height: frame.height)
            .position(x: frame.midX, y: frame.midY)
            .animation(.easeInOut(duration: 0.2), value: position)
    }
    
    // MARK: - Position Calculations
    
    private func calculateGridPosition(for index: Int, in geometry: GeometryProxy) -> CGPoint {
        let availableWidth = geometry.size.width - gridConfig.padding.leading - gridConfig.padding.trailing
        let actualColumns = max(1, min(gridConfig.columns, Int(availableWidth / (gridConfig.gridUnit + gridConfig.spacing))))
        
        let row = index / actualColumns
        let column = index % actualColumns
        
        let x = gridConfig.padding.leading + CGFloat(column) * (gridConfig.gridUnit + gridConfig.spacing) + gridConfig.gridUnit / 2
        let y = gridConfig.padding.top + CGFloat(row) * (gridConfig.gridUnit + gridConfig.spacing) + gridConfig.gridUnit / 2
        
        return CGPoint(x: x, y: y)
    }
    
    private func frameForGridPosition(_ position: GridPosition, in geometry: GeometryProxy) -> CGRect {
        let availableWidth = geometry.size.width - gridConfig.padding.leading - gridConfig.padding.trailing
        let actualColumns = max(1, min(gridConfig.columns, Int(availableWidth / (gridConfig.gridUnit + gridConfig.spacing))))
        
        let x = gridConfig.padding.leading + CGFloat(position.column) * (gridConfig.gridUnit + gridConfig.spacing)
        let y = gridConfig.padding.top + CGFloat(position.row) * (gridConfig.gridUnit + gridConfig.spacing)
        
        return CGRect(x: x, y: y, width: gridConfig.gridUnit, height: gridConfig.gridUnit)
    }
    
    private func gridPositionFromPoint(_ point: CGPoint, in geometry: GeometryProxy) -> GridPosition? {
        let availableWidth = geometry.size.width - gridConfig.padding.leading - gridConfig.padding.trailing
        let actualColumns = max(1, min(gridConfig.columns, Int(availableWidth / (gridConfig.gridUnit + gridConfig.spacing))))
        
        let adjustedX = point.x - gridConfig.padding.leading
        let adjustedY = point.y - gridConfig.padding.top
        
        guard adjustedX >= 0 && adjustedY >= 0 else { return nil }
        
        let column = Int(adjustedX / (gridConfig.gridUnit + gridConfig.spacing))
        let row = Int(adjustedY / (gridConfig.gridUnit + gridConfig.spacing))
        
        guard column >= 0 && column < actualColumns && row >= 0 else { return nil }
        
        return GridPosition(row: row, column: column)
    }
    
    // MARK: - Drag Handling
    
    private func handleDragChanged(container: any WidgetContainer, value: DragGesture.Value, geometry: GeometryProxy) {
        if draggedWidget == nil {
            draggedWidget = container
        }
        
        dragOffset = value.translation
        dragPosition = CGPoint(
            x: value.location.x + value.translation.x,
            y: value.location.y + value.translation.y
        )
        
        // Calculate potential drop position
        if let newPosition = gridPositionFromPoint(dragPosition, in: geometry) {
            dropTargetPosition = newPosition
        }
    }
    
    private func handleDragEnded(container: any WidgetContainer, value: DragGesture.Value, geometry: GeometryProxy) {
        defer {
            draggedWidget = nil
            dragOffset = .zero
            dragPosition = .zero
            dropTargetPosition = nil
        }
        
        guard let targetPosition = dropTargetPosition else { return }
        
        // Find current container index
        guard let currentIndex = containers.firstIndex(where: { $0.id == container.id }) else { return }
        
        // Calculate target index from grid position
        let availableWidth = geometry.size.width - gridConfig.padding.leading - gridConfig.padding.trailing
        let actualColumns = max(1, min(gridConfig.columns, Int(availableWidth / (gridConfig.gridUnit + gridConfig.spacing))))
        let targetIndex = targetPosition.row * actualColumns + targetPosition.column
        
        // Only move if position actually changed
        guard targetIndex != currentIndex && targetIndex >= 0 && targetIndex < containers.count else { return }
        
        // Trigger the move in the widget manager
        appState.widgetManager.moveContainer(fromIndex: currentIndex, toIndex: targetIndex)
    }
}

// MARK: - Draggable Widget View

struct DraggableWidgetView: View {
    let container: any WidgetContainer
    let position: CGPoint
    let gridConfig: GridConfiguration
    let isDragging: Bool
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    @Environment(\.theme) private var theme
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        WidgetContainerView(
            container: container,
            theme: theme,
            gridUnit: gridConfig.gridUnit,
            spacing: gridConfig.spacing
        )
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .opacity(isDragging ? 0.9 : 1.0)
        .shadow(
            color: isDragging ? .black.opacity(0.3) : .clear,
            radius: isDragging ? 10 : 0,
            x: 0,
            y: isDragging ? 5 : 0
        )
        .offset(isDragging ? dragOffset : .zero)
        .position(position)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    dragOffset = value.translation
                    onDragChanged(value)
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        dragOffset = .zero
                    }
                    onDragEnded(value)
                }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isDragging)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
    }
}

// MARK: - Grid Position

/// Represents a position in the grid layout
struct GridPosition: Equatable, Hashable, Codable {
    let row: Int
    let column: Int
    
    static let zero = GridPosition(row: 0, column: 0)
    
    var index: Int {
        // This will be calculated based on grid configuration
        row * 4 + column // Assuming 4 columns for now
    }
}