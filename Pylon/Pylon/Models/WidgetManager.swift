import SwiftUI
import Foundation

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
                group.addTask {
                    await self.refreshWidget(id: widget.id)
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
            return "Permission denied. Please grant access in System Preferences."
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .dataCorrupted:
            return "Data corrupted. Please try refreshing."
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}