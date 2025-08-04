//
//  WidgetContainerView.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// Universal container view that wraps all widgets with consistent styling
/// Handles theming, sizing, and common UI elements like loading states
struct WidgetContainerView: View {
    let container: any WidgetContainer
    let theme: any Theme
    let gridUnit: CGFloat
    let spacing: CGFloat

    @State private var isHovered = false
    @State private var showingConfiguration = false

    var body: some View {
        let frameSize = container.size.frameSize(gridUnit: gridUnit, spacing: spacing)

        VStack(spacing: 0) {
            // Widget header (only visible on hover or when small)
            if isHovered || container.size == .small {
                headerView
                    .transition(.move(edge: .top))
            }

            // Main widget content
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .background(backgroundView)
        .overlay(borderView)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            contextMenuContent
        }
        .disabled(!container.isEnabled)
        .opacity(container.isEnabled ? 1.0 : 0.6)
        .sheet(isPresented: $showingConfiguration) {
            WidgetConfigurationView(container: container)
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack(spacing: 8) {
            Image(systemName: container.category.iconName)
                .font(.caption)
                .foregroundColor(effectiveAccentColor)

            Text(container.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
                .lineLimit(1)

            Spacer()

            // Configuration button
            Button(action: {
                showingConfiguration = true
            }) {
                Image(systemName: "gear")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1.0 : 0.0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(theme.glassEffect.opacity(0.3))
    }

    // MARK: - Content View

    private var contentView: some View {
        Group {
            if container.isLoading {
                loadingView
            } else if let error = container.error {
                errorView(error)
            } else {
                container.body(theme: theme, gridUnit: gridUnit, spacing: spacing)
            }
        }
        .padding(contentPadding)
    }

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)

            Text("Loading...")
                .font(.caption)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)

            Text("Error")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)

            Text(error.localizedDescription)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Background & Border

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: effectiveCornerRadius)
            .fill(theme.glassEffect.opacity(effectiveBackgroundOpacity))
    }

    private var borderView: some View {
        RoundedRectangle(cornerRadius: effectiveCornerRadius)
            .stroke(effectiveAccentColor.opacity(0.3), lineWidth: 1)
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
                        // TODO: Update container size
                    }
                    .disabled(container.size == size)
                }
            }

            Divider()

            Button(container.isEnabled ? "Disable" : "Enable") {
                // TODO: Toggle container enabled state
            }

            Button("Remove") {
                // TODO: Remove widget
            }
        }
    }

    // MARK: - Computed Properties

    private var contentPadding: EdgeInsets {
        switch container.size {
        case .small:
            EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        case .medium:
            EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        case .large, .xlarge:
            EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        }
    }

    private var effectiveAccentColor: Color {
        if container.theme?.accentColor != nil {
            // TODO: Parse color string to Color
            return theme.accentColor
        }
        return theme.accentColor
    }

    private var effectiveBackgroundOpacity: Double {
        container.theme?.backgroundOpacity ?? 1.0
    }

    private var effectiveCornerRadius: Double {
        container.theme?.cornerRadius ?? 12.0
    }
}

// MARK: - Widget Configuration View

struct WidgetConfigurationView: View {
    let container: any WidgetContainer
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Widget configuration coming soon...")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Configure \(container.title)")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

// MARK: - Preview

#Preview {
    // Preview would go here with a sample widget container
    EmptyView()
}
