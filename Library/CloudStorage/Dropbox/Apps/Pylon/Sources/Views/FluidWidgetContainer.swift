//
//  FluidWidgetContainer.swift
//  Pylon
//
//  Created on 05.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// 2025 Design System: Hyper-sleek widget container with variable blur, morphing shapes, and spring physics
struct FluidWidgetContainer: View {
    let container: any WidgetContainer
    let theme: any Theme
    let gridUnit: CGFloat
    let spacing: CGFloat
    
    @State private var isHovered = false
    @State private var isFocused = false
    @State private var isPressed = false
    @State private var showingConfiguration = false
    @State private var morphingCornerRadius: CGFloat = 8.0
    @State private var ambientGlowIntensity: Double = 0.0
    @State private var contentScale: CGFloat = 1.0
    @State private var depthLevel: Int = 0
    
    @EnvironmentObject private var appState: AppState
    
    private let goldenRatio: CGFloat = 1.618
    
    var body: some View {
        let frameSize = container.size.frameSize(gridUnit: gridUnit, spacing: spacing)
        
        VStack(spacing: 0) {
            // Fluid header with anticipatory motion
            if isHovered || container.size == .small || isFocused {
                fluidHeaderView
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
            
            // Main content with morphing container
            fluidContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .background(variableBlurBackground)
        .overlay(ambientLightingOverlay)
        .overlay(liquidBorderOverlay)
        .scaleEffect(contentScale)
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                isHovered = hovering
                morphingCornerRadius = hovering ? theme.fluidCornerRadius * goldenRatio : theme.fluidCornerRadius
                ambientGlowIntensity = hovering ? 0.8 : 0.0
                contentScale = hovering ? 1.02 : 1.0
                depthLevel = hovering ? 1 : 0
            }
        }
        .onTapGesture {
            // Haptic-style visual feedback
            withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                isPressed = true
                contentScale = 0.98
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                    contentScale = isHovered ? 1.02 : 1.0
                }
            }
        }
        .contextMenu {
            contextMenuContent
        }
        .disabled(!container.isEnabled)
        .opacity(container.isEnabled ? 1.0 : 0.6)
        .sheet(isPresented: $showingConfiguration) {
            VStack {
                Text("Widget Configuration")
                    .font(.headline)
                Text("Configuration for \(container.title)")
                    .foregroundStyle(.secondary)
                
                Button("Close") {
                    showingConfiguration = false
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    // MARK: - Fluid Header with Typography Transitions
    
    private var fluidHeaderView: some View {
        HStack(spacing: goldenRatio * 4) {
            Image(systemName: container.category.iconName)
                .font(.system(size: isHovered ? 12 : 10, weight: .medium, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            effectiveAccentColor,
                            effectiveAccentColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isHovered ? 1.1 : 1.0)
            
            Text(container.title.uppercased())
                .font(.system(
                    size: isHovered ? 11 : 9,
                    weight: isHovered ? .semibold : .medium,
                    design: .rounded
                ))
                .foregroundColor(theme.textPrimary)
                .lineLimit(1)
                .scaleEffect(x: isHovered ? 1.05 : 1.0, y: 1.0, anchor: .leading)
            
            Spacer()
            
            // Morphing configuration button
            Button(action: {
                showingConfiguration = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .scaleEffect(isHovered ? 1.2 : 0.8)
                    .rotationEffect(.degrees(isHovered ? 90 : 0))
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1.0 : 0.0)
        }
        .padding(.horizontal, goldenRatio * 8) // Golden ratio spacing
        .padding(.vertical, goldenRatio * 4)
        .background(variableDepthMaterial)
        .clipShape(RoundedRectangle(cornerRadius: morphingCornerRadius * 0.6))
        .overlay(
            RoundedRectangle(cornerRadius: morphingCornerRadius * 0.6)
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.contextualAccent.opacity(0.3),
                            theme.contextualAccent.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
    
    // MARK: - Fluid Content with Contextual Adaptation
    
    private var fluidContentView: some View {
        Group {
            if container.isLoading {
                fluidLoadingView
            } else if let error = container.error {
                fluidErrorView(error)
            } else {
                container.body(theme: theme, gridUnit: gridUnit, spacing: spacing)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            }
        }
        .padding(adaptiveContentPadding)
        .background(
            // Contextual color adaptation based on content importance
            RoundedRectangle(cornerRadius: morphingCornerRadius * 0.8)
                .fill(contextualBackgroundColor.opacity(0.1))
        )
    }
    
    private var fluidLoadingView: some View {
        VStack(spacing: goldenRatio * 4) {
            // Morphing progress indicator
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [theme.contextualAccent, theme.contextualAccent.opacity(0.3)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(isHovered ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isHovered)
            
            Text("LOADING...")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(theme.contextualAccent)
                .opacity(ambientGlowIntensity > 0 ? 1.0 : 0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func fluidErrorView(_ error: Error) -> some View {
        VStack(spacing: goldenRatio * 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isHovered ? 1.1 : 1.0)
            
            Text("SIGNAL_LOST")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(Color.red)
            
            Text("RECONNECTING...")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Variable Blur Background System
    
    private var variableBlurBackground: some View {
        RoundedRectangle(cornerRadius: morphingCornerRadius)
            .fill(variableDepthMaterial)
            .shadow(
                color: Color.black.opacity(depthLevel == 1 ? 0.2 : 0.1),
                radius: depthLevel == 1 ? 12 : 4,
                x: 0,
                y: depthLevel == 1 ? 6 : 2
            )
            .shadow(
                color: Color.black.opacity(depthLevel == 1 ? 0.1 : 0.05),
                radius: depthLevel == 1 ? 4 : 1,
                x: 0,
                y: depthLevel == 1 ? 2 : 0.5
            )
    }
    
    private var variableDepthMaterial: Material {
        switch depthLevel {
        case 1: return theme.depthLayer1  // Focused - strongest blur
        case 0: return theme.depthLayer2  // Default - medium blur
        default: return theme.depthLayer3 // Background - subtle blur
        }
    }
    
    // MARK: - Ambient Lighting Effects
    
    private var ambientLightingOverlay: some View {
        RoundedRectangle(cornerRadius: morphingCornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        theme.ambientGlow.opacity(ambientGlowIntensity * 0.6),
                        theme.ambientGlow.opacity(ambientGlowIntensity * 0.2),
                        Color.clear,
                        theme.ambientGlow.opacity(ambientGlowIntensity * 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .blur(radius: ambientGlowIntensity * 2)
    }
    
    // MARK: - Liquid Border System
    
    private var liquidBorderOverlay: some View {
        RoundedRectangle(cornerRadius: morphingCornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        effectiveAccentColor.opacity(isHovered ? 0.4 : 0.2),
                        effectiveAccentColor.opacity(isHovered ? 0.2 : 0.1),
                        Color.clear,
                        effectiveAccentColor.opacity(isHovered ? 0.1 : 0.05)
                    ],
                    startPoint: UnitPoint(x: 0, y: 0),
                    endPoint: UnitPoint(x: 1, y: 1)
                ),
                lineWidth: isHovered ? 1.2 : 0.8
            )
    }
    
    // MARK: - Context Menu
    
    private var contextMenuContent: some View {
        Group {
            Button("Configure") {
                showingConfiguration = true
            }
            
            Divider()
            
            Menu("Resize") {
                ForEach(container.supportedSizes, id: \.self) { size in
                    Button(size.displayName) {
                        updateContainerSize(to: size)
                    }
                    .disabled(container.size == size)
                }
            }
            
            Divider()
            
            Button(container.isEnabled ? "Disable" : "Enable") {
                toggleContainerEnabled()
            }
            
            Button("Remove") {
                removeContainer()
            }
        }
    }
    
    // MARK: - Computed Properties with Contextual Intelligence
    
    private var adaptiveContentPadding: EdgeInsets {
        let basePadding = goldenRatio * 8
        switch container.size {
        case .small:
            return EdgeInsets(top: basePadding, leading: basePadding, bottom: basePadding, trailing: basePadding)
        case .medium:
            return EdgeInsets(top: basePadding, leading: basePadding, bottom: basePadding, trailing: basePadding)
        case .large:
            return EdgeInsets(top: basePadding * 1.5, leading: basePadding * 1.5, bottom: basePadding * 1.5, trailing: basePadding * 1.5)
        case .xlarge:
            return EdgeInsets(top: basePadding * 2.0, leading: basePadding * 2.0, bottom: basePadding * 2.0, trailing: basePadding * 2.0)
        }
    }
    
    private var effectiveAccentColor: Color {
        // Contextual accent that adapts based on widget importance/activity
        if container.isLoading {
            return theme.contextualAccent
        } else if container.error != nil {
            return Color.orange
        } else {
            return theme.accentColor
        }
    }
    
    private var contextualBackgroundColor: Color {
        // Background that subtly shifts based on content
        if container.isLoading {
            return theme.contextualAccent
        } else if container.error != nil {
            return Color.red
        } else {
            return theme.cardBackground
        }
    }
    
    // MARK: - Actions
    
    private func updateContainerSize(to newSize: WidgetSize) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            appState.widgetManager.updateContainerSize(id: container.id, newSize: newSize)
        }
    }
    
    private func toggleContainerEnabled() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            appState.widgetManager.toggleContainerEnabled(id: container.id)
        }
    }
    
    private func removeContainer() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            appState.widgetManager.removeContainer(id: container.id)
        }
    }
}

#Preview {
    EmptyView()
}