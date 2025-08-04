import SwiftUI
import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var selectedThemeType: ThemeType = .glass
    @Published var isKeyboardNavigationEnabled = true
    @Published var widgetLayout: WidgetLayout = .grid(columns: 3)
    @Published var isRefreshing = false
    
    var selectedTheme: any Theme {
        selectedThemeType.theme
    }
    
    var widgetManager = WidgetManager()
    
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
        
        await widgetManager.refreshAllContainers()
    }
    
    func toggleTheme() {
        switch selectedThemeType {
        case .glass:
            selectedThemeType = .dark
        case .dark:
            selectedThemeType = .light
        case .light:
            selectedThemeType = .glass
        case .system:
            selectedThemeType = .glass
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