//
//  NativeWidgetContainer.swift
//  Pylon
//
//  Created on 05.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// Native macOS widget container following Apple's design guidelines
struct NativeWidgetContainer: View {
    let container: any WidgetContainer
    let gridUnit: CGFloat
    let spacing: CGFloat
    
    @State private var isHovered = false
    @State private var showingConfiguration = false
    @EnvironmentObject private var appState: AppState
    
    private let nativeTheme = NativeMacOSTheme()
    
    var body: some View {
        let frameSize = container.size.frameSize(gridUnit: gridUnit, spacing: spacing)
        
        VStack(spacing: 0) {
            // Native header (only on hover)
            if isHovered {
                nativeHeader
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Main content with native styling
            nativeContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .background(nativeBackground)
        .overlay(nativeBorder)
        .clipShape(RoundedRectangle(cornerRadius: NativeMacOSTheme.CornerRadius.md))
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onHover { hovering in
            withAnimation(.macOSEaseOut) {
                isHovered = hovering
            }
        }
        .contextMenu {
            nativeContextMenu
        }
        .disabled(!container.isEnabled)
        .opacity(container.isEnabled ? 1.0 : 0.6)
        .sheet(isPresented: $showingConfiguration) {
            NativeWidgetConfigurationSheet(container: container)
        }
    }
    
    // MARK: - Native Header
    
    private var nativeHeader: some View {
        HStack(spacing: NativeMacOSTheme.Spacing.xs) {
            // Native SF Symbol
            Image(systemName: container.category.iconName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            
            Text(container.title)
                .font(NativeMacOSTheme.Typography.caption1)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Spacer()
            
            // Native configuration button
            Button {
                showingConfiguration = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1.0 : 0.0)
        }
        .padding(.horizontal, NativeMacOSTheme.Spacing.sm)
        .padding(.vertical, NativeMacOSTheme.Spacing.xs)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: NativeMacOSTheme.CornerRadius.xs))
    }
    
    // MARK: - Native Content
    
    private var nativeContent: some View {
        Group {
            if container.isLoading {
                nativeLoadingView
            } else if let error = container.error {
                nativeErrorView(error)
            } else {
                container.body(theme: nativeTheme, gridUnit: gridUnit, spacing: spacing)
            }
        }
        .padding(nativeContentPadding)
    }
    
    private var nativeLoadingView: some View {
        VStack(spacing: NativeMacOSTheme.Spacing.sm) {
            ProgressView()
                .controlSize(.small)
                .tint(.secondary)
            
            Text("Loading...")
                .font(NativeMacOSTheme.Typography.caption1)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func nativeErrorView(_ error: Error) -> some View {
        VStack(spacing: NativeMacOSTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title3)
                .foregroundStyle(.orange)
                .symbolRenderingMode(.hierarchical)
            
            Text("Unable to Load")
                .font(NativeMacOSTheme.Typography.caption1)
                .foregroundStyle(.primary)
            
            Text("Try again later")
                .font(NativeMacOSTheme.Typography.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Native Background & Border
    
    private var nativeBackground: some View {
        RoundedRectangle(cornerRadius: NativeMacOSTheme.CornerRadius.md)
            .fill(.regularMaterial)
            .shadow(
                color: .black.opacity(0.1),
                radius: isHovered ? 8 : 4,
                x: 0,
                y: isHovered ? 4 : 2
            )
    }
    
    private var nativeBorder: some View {
        RoundedRectangle(cornerRadius: NativeMacOSTheme.CornerRadius.md)
            .strokeBorder(.separator.opacity(0.5), lineWidth: 0.5)
    }
    
    // MARK: - Native Context Menu
    
    private var nativeContextMenu: some View {
        Group {
            Button("Configure Widget") {
                showingConfiguration = true
            }
            
            Divider()
            
            Menu("Change Size") {
                ForEach(container.supportedSizes, id: \.self) { size in
                    Button(size.displayName) {
                        updateContainerSize(to: size)
                    }
                    .disabled(container.size == size)
                }
            }
            
            Divider()
            
            Button(container.isEnabled ? "Disable Widget" : "Enable Widget") {
                toggleContainerEnabled()
            }
            
            Button("Remove Widget", role: .destructive) {
                removeContainer()
            }
        }
    }
    
    // MARK: - Native Content Padding
    
    private var nativeContentPadding: EdgeInsets {
        // Native macOS spacing scale
        switch container.size {
        case .small:
            EdgeInsets(top: NativeMacOSTheme.Spacing.sm, leading: NativeMacOSTheme.Spacing.sm, 
                      bottom: NativeMacOSTheme.Spacing.sm, trailing: NativeMacOSTheme.Spacing.sm)
        case .medium:
            EdgeInsets(top: NativeMacOSTheme.Spacing.md, leading: NativeMacOSTheme.Spacing.md, 
                      bottom: NativeMacOSTheme.Spacing.md, trailing: NativeMacOSTheme.Spacing.md)
        case .large:
            EdgeInsets(top: NativeMacOSTheme.Spacing.lg, leading: NativeMacOSTheme.Spacing.lg, 
                      bottom: NativeMacOSTheme.Spacing.lg, trailing: NativeMacOSTheme.Spacing.lg)
        case .xlarge:
            EdgeInsets(top: NativeMacOSTheme.Spacing.xl, leading: NativeMacOSTheme.Spacing.xl, 
                      bottom: NativeMacOSTheme.Spacing.xl, trailing: NativeMacOSTheme.Spacing.xl)
        }
    }
    
    // MARK: - Actions
    
    private func updateContainerSize(to newSize: WidgetSize) {
        withAnimation(.macOSSpring) {
            appState.widgetManager.updateContainerSize(id: container.id, newSize: newSize)
        }
    }
    
    private func toggleContainerEnabled() {
        withAnimation(.macOSSpring) {
            appState.widgetManager.toggleContainerEnabled(id: container.id)
        }
    }
    
    private func removeContainer() {
        withAnimation(.macOSSpring) {
            appState.widgetManager.removeContainer(id: container.id)
        }
    }
}

// MARK: - Native Widget Configuration Sheet

struct NativeWidgetConfigurationSheet: View {
    let container: any WidgetContainer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: NativeMacOSTheme.Spacing.xl) {
                // Native SF Symbol
                Image(systemName: container.category.iconName)
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: NativeMacOSTheme.Spacing.sm) {
                    Text("Widget Configuration")
                        .font(NativeMacOSTheme.Typography.title3)
                        .foregroundStyle(.primary)
                    
                    Text("Configuration options for this widget will be available in a future update.")
                        .font(NativeMacOSTheme.Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(NativeMacOSTheme.Spacing.xl)
            .navigationTitle(container.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    // Preview implementation would need a sample widget
    EmptyView()
}