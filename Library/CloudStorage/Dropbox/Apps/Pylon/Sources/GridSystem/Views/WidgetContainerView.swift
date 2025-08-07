//
//  WidgetContainerView.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Individual widget container
//

import SwiftUI

/// Container view for individual widgets with proper styling and positioning
struct WidgetContainerView: View {
    
    let widget: any GridWidget
    let theme: any Theme
    let configuration: GridConfiguration
    let isDragged: Bool
    
    var body: some View {
        let frameSize = configuration.frameSize(for: widget.size)
        
        ZStack {
            // Widget background with gradient
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
            widgetContent
                .padding(contentPadding)
        }
        .frame(
            width: frameSize.width,
            height: frameSize.height
        )
        .scaleEffect(isDragged ? 1.02 : 1.0)
        .shadow(
            color: .black.opacity(isDragged ? 0.25 : 0.08),
            radius: isDragged ? 20 : 8,
            x: 0,
            y: isDragged ? 8 : 4
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDragged)
        .contentShape(Rectangle()) // Ensure full area is draggable
    }
    
    // MARK: - Widget Content
    
    @ViewBuilder
    private var widgetContent: some View {
        VStack(spacing: 8) {
            // Header with icon and title
            HStack(spacing: 8) {
                // Widget icon
                Image(systemName: widgetIcon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(widgetAccentColor, in: Circle())
                
                // Title and metadata
                VStack(alignment: .leading, spacing: 0) {
                    Text(widget.title)
                        .font(.system(size: titleFontSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.primaryColor)
                        .lineLimit(1)
                    
                    if widget.size != .small {
                        Text(lastUpdatedText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(theme.secondaryColor)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Error/loading indicator
                if let _ = widget.error {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if widget.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Main content (only for non-small widgets)
            if widget.size != .small {
                Spacer()
                
                widget.body(theme: theme, configuration: configuration)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var contentPadding: EdgeInsets {
        switch widget.size {
        case .small:
            return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        case .medium:
            return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        case .large, .extraLarge:
            return EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        default:
            return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        }
    }
    
    private var iconSize: CGFloat {
        switch widget.size {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .extraLarge: return 20
        default: return 16
        }
    }
    
    private var titleFontSize: CGFloat {
        switch widget.size {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        case .extraLarge: return 18
        default: return 14
        }
    }
    
    private var widgetGradient: LinearGradient {
        let colors = widgetColorPair
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var widgetAccentColor: Color {
        return widgetColorPair.first ?? theme.accentColor
    }
    
    private var widgetIcon: String {
        return widget.category.systemImage
    }
    
    private var widgetColorPair: [Color] {
        switch widget.category {
        case .productivity: return [.blue, .cyan]
        case .information: return [.green, .mint]
        case .communication: return [.orange, .yellow]
        case .entertainment: return [.purple, .pink]
        case .utilities: return [.indigo, .blue]
        case .system: return [.red, .orange]
        case .custom: return [.gray, .secondary]
        }
    }
    
    private var lastUpdatedText: String {
        if let lastUpdated = widget.lastUpdated {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return "Updated \(formatter.localizedString(for: lastUpdated, relativeTo: Date()))"
        } else {
            return "Never updated"
        }
    }
}