//
//  SampleWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Sample widget demonstrating the container architecture
/// Shows how to implement a widget with dynamic sizing and content swapping
@MainActor
final class SampleWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero

    @Published private var content: SampleContent

    // MARK: - Widget Metadata

    let title = "Sample Widget"
    let category = WidgetCategory.information
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]

    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }

    init() {
        content = SampleContent()
    }

    // MARK: - Lifecycle Methods

    func refresh() async throws {
        try await content.refresh()
    }

    func configure() -> AnyView {
        AnyView(SampleConfigurationView())
    }

    // MARK: - Main Widget View

    func body(theme: any Theme, gridUnit _: CGFloat, spacing _: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    smallLayout(theme: theme)
                case .medium:
                    mediumLayout(theme: theme)
                case .large:
                    largeLayout(theme: theme)
                case .xlarge:
                    xlargeLayout(theme: theme)
                }
            }
        )
    }

    // MARK: - Size-Specific Layouts

    private func smallLayout(theme: any Theme) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "info.circle")
                .font(.title2)
                .foregroundColor(theme.accentColor)

            Text("Sample")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)

            if let lastUpdated = content.lastUpdated {
                Text(formatTime(lastUpdated))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func mediumLayout(theme: any Theme) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle")
                .font(.title)
                .foregroundColor(theme.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text("Sample Widget")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)

                Text("This demonstrates the container architecture")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(2)

                if let lastUpdated = content.lastUpdated {
                    Text("Updated: \(formatTime(lastUpdated))")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.title)
                    .foregroundColor(theme.accentColor)

                Text("Sample Widget")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("This is a sample widget demonstrating:")
                    .font(.body)
                    .foregroundColor(theme.textPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    bulletPoint("Dynamic sizing (Small, Medium, Large, XLarge)", theme: theme)
                    bulletPoint("Container-based architecture", theme: theme)
                    bulletPoint("Theme adaptation", theme: theme)
                    bulletPoint("Content swapping capabilities", theme: theme)
                }
            }

            Spacer()

            if let lastUpdated = content.lastUpdated {
                HStack {
                    Spacer()
                    Text("Last updated: \(formatDateTime(lastUpdated))")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func xlargeLayout(theme: any Theme) -> some View {
        HStack(spacing: 24) {
            // Left side - Icon and title
            VStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.system(size: 48))
                    .foregroundColor(theme.accentColor)

                Text("Sample Widget")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120)

            // Right side - Detailed content
            VStack(alignment: .leading, spacing: 12) {
                Text("Container Architecture Demonstration")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)

                Text(
                    "This sample widget showcases the flexible container system that powers all Pylon widgets. Each widget is designed as a container where content can be dynamically swapped and resized."
                )
                .font(.body)
                .foregroundColor(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Features:")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)

                    bulletPoint("Four size configurations (Small, Medium, Large, XLarge)", theme: theme)
                    bulletPoint("Automatic theme adaptation with override support", theme: theme)
                    bulletPoint("Grid-based positioning and alignment", theme: theme)
                    bulletPoint("Swappable content architecture", theme: theme)
                    bulletPoint("Drag-and-drop reordering capabilities", theme: theme)
                }

                Spacer()

                if let lastUpdated = content.lastUpdated {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Last Updated")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                            Text(formatDateTime(lastUpdated))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(theme.textPrimary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helper Views

    private func bulletPoint(_ text: String, theme: any Theme) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .font(.caption)
                .foregroundColor(theme.accentColor)

            Text(text)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Helper Methods

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Sample Content

@MainActor
final class SampleContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?

    init() {
        lastUpdated = Date()
    }

    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil

        // Simulate network request
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        lastUpdated = Date()
        isLoading = false
    }
}

// MARK: - Configuration View

struct SampleConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Sample Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)

            Text(
                "This widget demonstrates the container architecture. Configuration options would appear here for real widgets."
            )
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}
