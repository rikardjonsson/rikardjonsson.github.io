//
//  DragPreviewView.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Enhanced drag preview
//

import SwiftUI

/// Enhanced drag preview with visual feedback
struct DragPreviewView: View {
    let widget: any GridWidget
    let theme: any Theme
    let configuration: GridConfiguration
    let isValid: Bool
    let targetPosition: GridPosition?
    
    var body: some View {
        ZStack {
            // Ghost/preview widget
            WidgetContainerView(
                widget: widget,
                theme: theme,
                configuration: configuration,
                isDragged: true
            )
            .opacity(0.8)
            .scaleEffect(0.95)
            
            // Validation overlay
            if let _ = targetPosition {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isValid ? Color.green : Color.red,
                        lineWidth: 3
                    )
                    .fill(
                        (isValid ? Color.green : Color.red)
                            .opacity(0.1)
                    )
                    .animation(.easeInOut(duration: 0.2), value: isValid)
            }
        }
        .shadow(
            color: .black.opacity(0.3),
            radius: 12,
            x: 2,
            y: 8
        )
    }
}

/// Drop zone indicator for valid placement areas
struct DropZoneIndicator: View {
    let position: GridPosition
    let size: GridSize
    let isHighlighted: Bool
    let isValid: Bool
    let theme: any Theme
    let configuration: GridConfiguration
    
    var body: some View {
        let frameSize = configuration.frameSize(for: size)
        let framePosition = configuration.framePosition(for: position)
        
        RoundedRectangle(cornerRadius: 12)
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: strokeWidth)
            .frame(
                width: frameSize.width,
                height: frameSize.height
            )
            .position(
                x: framePosition.x + frameSize.width / 2,
                y: framePosition.y + frameSize.height / 2
            )
            .scaleEffect(isHighlighted ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHighlighted)
            .allowsHitTesting(false)
    }
    
    private var fillColor: Color {
        if isHighlighted {
            return (isValid ? Color.green : Color.red).opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    private var strokeColor: Color {
        if isHighlighted {
            return isValid ? Color.green.opacity(0.8) : Color.red.opacity(0.8)
        } else {
            return theme.secondaryColor.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        isHighlighted ? 2.0 : 1.0
    }
}

/// Enhanced drag gesture with haptic feedback
struct EnhancedDragGesture {
    static func create<V: View>(
        for widget: any GridWidget,
        in gridManager: GridManager,
        onDragChanged: @escaping (any GridWidget, DragGesture.Value) -> Void,
        onDragEnded: @escaping (any GridWidget, DragGesture.Value) -> Void
    ) -> some Gesture {
        DragGesture(coordinateSpace: .named("GridContainer"))
            .onChanged { value in
                onDragChanged(widget, value)
                
                // Haptic feedback for grid alignment
                if let targetPosition = gridManager.gridPosition(from: value.location) {
                    let isValid = gridManager.canPlaceWidget(widget, at: targetPosition, excluding: [widget.id])
                    
                    // Light haptic feedback when entering valid drop zones
                    #if os(iOS)
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    #endif
                }
            }
            .onEnded { value in
                onDragEnded(widget, value)
                
                // Success/failure haptic feedback
                #if os(iOS)
                let notification = UINotificationFeedbackGenerator()
                
                if let targetPosition = gridManager.gridPosition(from: value.location),
                   gridManager.canPlaceWidget(widget, at: targetPosition, excluding: [widget.id]) {
                    notification.notificationOccurred(.success)
                } else {
                    notification.notificationOccurred(.error)
                }
                #endif
            }
    }
}