//
//  WidgetManager.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class WidgetManager {
    private(set) var widgets: [any Widget] = []
    private(set) var refreshInProgress: Set<UUID> = []

    func registerWidget(_ widget: any Widget) {
        widgets.append(widget)
    }

    func removeWidget(id: UUID) {
        widgets.removeAll { $0.id == id }
    }

    func refreshWidget(id: UUID) async {
        guard let widget = widgets.first(where: { $0.id == id }),
              !refreshInProgress.contains(id) else { return }

        refreshInProgress.insert(id)
        defer { refreshInProgress.remove(id) }

        do {
            try await widget.refresh()
        } catch {
            print("Failed to refresh widget \(widget.title): \(error)")
            // TODO: Handle widget refresh errors appropriately
        }
    }

    func refreshAllWidgets() async {
        await withTaskGroup(of: Void.self) { group in
            for widget in widgets {
                group.addTask { [weak self] in
                    await self?.refreshWidget(id: widget.id)
                }
            }
        }
    }

    func isRefreshing(_ widgetId: UUID) -> Bool {
        refreshInProgress.contains(widgetId)
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
