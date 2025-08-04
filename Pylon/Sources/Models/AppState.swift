//
//  AppState.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var selectedThemeType: ThemeType = .modern
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
        case .modern:
            selectedThemeType = .dark
        case .dark:
            selectedThemeType = .light
        case .light:
            selectedThemeType = .modern
        case .system:
            selectedThemeType = .modern
        }
    }
}

// MARK: - Supporting Types

enum WidgetLayout: Equatable, CaseIterable, Sendable {
    case grid(columns: Int)
    case list
    case masonry

    var displayName: String {
        switch self {
        case let .grid(columns):
            "Grid (\(columns) columns)"
        case .list:
            "List"
        case .masonry:
            "Masonry"
        }
    }

    static var allCases: [WidgetLayout] {
        [
            .grid(columns: 2),
            .grid(columns: 3),
            .grid(columns: 4),
            .list,
            .masonry
        ]
    }
}
