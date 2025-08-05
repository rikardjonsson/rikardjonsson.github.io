//
//  WidgetManager.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Manages widget containers with support for dynamic sizing, theming, and layout
@MainActor
class WidgetManager: ObservableObject {
    @Published private(set) var containers: [any WidgetContainer] = []
    @Published private(set) var refreshInProgress: Set<UUID> = []
    @Published var gridConfiguration = GridConfiguration()

    // MARK: - Container Management

    func registerContainer(_ container: any WidgetContainer) {
        containers.append(container)
    }

    func removeContainer(id: UUID) {
        containers.removeAll { $0.id == id }
    }

    func updateContainerSize(id: UUID, newSize: WidgetSize) {
        guard let index = containers.firstIndex(where: { $0.id == id }) else { return }
        var container = containers[index]

        // Check if the new size is supported
        guard container.supportedSizes.contains(newSize) else { return }

        container.size = newSize
        containers[index] = container

        // Recalculate layout positions if needed
        recalculateLayout()
    }

    func updateContainerTheme(id: UUID, themeOverride: WidgetThemeOverride?) {
        guard let index = containers.firstIndex(where: { $0.id == id }) else { return }
        var container = containers[index]
        container.theme = themeOverride
        containers[index] = container
    }

    func toggleContainerEnabled(id: UUID) {
        guard let index = containers.firstIndex(where: { $0.id == id }) else { return }
        var container = containers[index]
        container.isEnabled.toggle()
        containers[index] = container
    }

    // MARK: - Refresh Management

    func refreshContainer(id: UUID) async {
        guard let container = containers.first(where: { $0.id == id }),
              !refreshInProgress.contains(id) else { return }

        refreshInProgress.insert(id)
        defer { refreshInProgress.remove(id) }

        do {
            try await container.refresh()
        } catch {
            print("Failed to refresh widget \(container.title): \(error)")
            // TODO: Handle widget refresh errors appropriately
        }
    }

    func refreshAllContainers() async {
        let enabledContainerIds = containers.compactMap { container in
            container.isEnabled ? container.id : nil
        }

        await withTaskGroup(of: Void.self) { group in
            for containerId in enabledContainerIds {
                group.addTask { [weak self] in
                    await self?.refreshContainer(id: containerId)
                }
            }
        }
    }

    func isRefreshing(_ containerId: UUID) -> Bool {
        refreshInProgress.contains(containerId)
    }

    // MARK: - Layout Management

    func recalculateLayout() {
        // TODO: Implement intelligent layout recalculation
        // This should handle container positioning to avoid overlaps
        // and optimize for the current grid configuration
    }

    func moveContainer(from sourcePosition: GridPosition, to destinationPosition: GridPosition) {
        // TODO: Implement drag-and-drop reordering
        guard let index = containers.firstIndex(where: { $0.position == sourcePosition }) else { return }
        var container = containers[index]
        container.position = destinationPosition
        containers[index] = container

        recalculateLayout()
    }
    
    func moveContainer(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex,
              fromIndex >= 0, fromIndex < containers.count,
              toIndex >= 0, toIndex < containers.count else { return }
        
        let container = containers.remove(at: fromIndex)
        containers.insert(container, at: toIndex)
        
        // Update positions after reordering
        updateContainerPositions()
    }
    
    private func updateContainerPositions() {
        for (index, _) in containers.enumerated() {
            let row = index / gridConfiguration.columns
            let column = index % gridConfiguration.columns
            containers[index].position = GridPosition(row: row, column: column)
        }
    }

    // MARK: - Filtering and Organization

    func containers(in category: WidgetCategory) -> [any WidgetContainer] {
        containers.filter { $0.category == category }
    }

    func enabledContainers() -> [any WidgetContainer] {
        containers.filter(\.isEnabled)
    }
}

// MARK: - Grid Configuration

struct GridConfiguration: Sendable {
    var columns: Int = 4
    var gridUnit: CGFloat = 120
    var spacing: CGFloat = 16
    var padding: EdgeInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)

    var totalWidth: CGFloat {
        CGFloat(columns) * gridUnit + CGFloat(columns - 1) * spacing + padding.leading + padding.trailing
    }
}

// MARK: - Widget Protocol

protocol Widget: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var isRefreshing: Bool { get }
    var lastUpdated: Date? { get }

    @MainActor
    func refresh() async throws

    @MainActor
    func body() -> AnyView
}

// MARK: - Widget Errors

enum WidgetError: Error, LocalizedError {
    case permissionDenied
    case networkUnavailable
    case dataCorrupted
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Permission denied. Please grant access in System Preferences."
        case .networkUnavailable:
            "Network unavailable. Please check your connection."
        case .dataCorrupted:
            "Data corrupted. Please try refreshing."
        case let .unknownError(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}
