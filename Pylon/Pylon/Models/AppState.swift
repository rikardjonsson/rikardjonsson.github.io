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
@Observable
class AppState {
    var selectedTheme: Theme = .modern
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
        case .modern:
            selectedTheme = .dark
        case .dark:
            selectedTheme = .light
        case .light:
            selectedTheme = .modern
        case .system:
            selectedTheme = .modern
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
