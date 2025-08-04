import SwiftUI
import Foundation

@MainActor
@Observable
class AppState {
    var selectedTheme: Theme = .glass
    var isKeyboardNavigationEnabled = true
    var widgetLayout: WidgetLayout = .grid(columns: 3)
    var isRefreshing = false
    
    private var widgetManager = WidgetManager()
    
    init() {
        setupInitialWidgets()
    }
    
    private func setupInitialWidgets() {
        // TODO: Register initial widgets when widget system is implemented
        // widgetManager.registerWidget(CalendarWidget())
        // widgetManager.registerWidget(RemindersWidget())
    }
    
    func refreshAllWidgets() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        // TODO: Implement widget refresh when widget system is ready
        await widgetManager.refreshAllWidgets()
    }
    
    func toggleTheme() {
        switch selectedTheme {
        case .glass:
            selectedTheme = .dark
        case .dark:
            selectedTheme = .light
        case .light:
            selectedTheme = .glass
        case .system:
            selectedTheme = .glass
        }
    }
}

// MARK: - Supporting Types

enum WidgetLayout: Equatable, CaseIterable {
    case grid(columns: Int)
    case list
    case masonry
    
    var displayName: String {
        switch self {
        case .grid(let columns):
            return "Grid (\(columns) columns)"
        case .list:
            return "List"
        case .masonry:
            return "Masonry"
        }
    }
    
    static var allCases: [WidgetLayout] {
        return [
            .grid(columns: 2),
            .grid(columns: 3),
            .grid(columns: 4),
            .list,
            .masonry
        ]
    }
}