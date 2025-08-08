//
//  AppState.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var selectedThemeType: ThemeType = .nativeMacOS
    @Published var isKeyboardNavigationEnabled = true
    @Published var widgetLayout: WidgetLayout = .grid(columns: 3)
    @Published var isRefreshing = false

    var selectedTheme: any Theme {
        selectedThemeType.theme
    }

    @Published var widgetManager = WidgetManager()
    var layoutPersistence = LayoutPersistence()

    init() {
        // Initialize WidgetManager's grid persistence system
        widgetManager.initializePersistence()
        
        loadPersistedLayout()
        setupInitialWidgets()
        setupAutoSave()
        
        // Observe widget manager changes
        widgetManager.objectWillChange.sink { [weak self] in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()

    private func setupInitialWidgets() {
        // Mix of regular small and tiny widgets
        
        // Mix of different widget sizes for testing
        let weatherWidget = WeatherWidget()
        weatherWidget.size = .medium // 2x2 cells
        widgetManager.registerContainer(weatherWidget)
        
        let calendarWidget = CalendarWidget()
        calendarWidget.size = .large // 2x4 cells
        widgetManager.registerContainer(calendarWidget)
        
        let systemWidget = SystemMonitorWidget()
        systemWidget.size = .medium // 2x2 cells
        widgetManager.registerContainer(systemWidget)
        
        let financeWidget = FinanceWidget()
        financeWidget.size = .medium // 2x2 cells
        widgetManager.registerContainer(financeWidget)
        
        let emailWidget = EmailWidget()
        emailWidget.size = .small // 1x1 cell
        widgetManager.registerContainer(emailWidget)
        
        // Small widgets (1x1 grid cells)
        let clockWidget = ClockWidget()
        clockWidget.size = .small
        widgetManager.registerContainer(clockWidget)
        
        let remindersWidget = RemindersWidget()
        remindersWidget.size = .small
        widgetManager.registerContainer(remindersWidget)
        
        let notesWidget = NotesWidget()
        notesWidget.size = .small
        widgetManager.registerContainer(notesWidget)
        
        let fitnessWidget = FitnessWidget()
        fitnessWidget.size = .small
        widgetManager.registerContainer(fitnessWidget)
        
        let stocksWidget = StocksWidget()
        stocksWidget.size = .small
        widgetManager.registerContainer(stocksWidget)
        
        DebugLog.success("Setup complete: \(widgetManager.containers.count) widgets")
    }

    func refreshAllWidgets() async {
        isRefreshing = true
        defer { isRefreshing = false }

        await widgetManager.refreshAllContainers()
    }

    func toggleTheme() {
        switch selectedThemeType {
        case .nativeMacOS:
            selectedThemeType = .surveillance
        case .surveillance:
            selectedThemeType = .modern
        case .modern:
            selectedThemeType = .dark
        case .dark:
            selectedThemeType = .light
        case .light:
            selectedThemeType = .system
        case .system:
            selectedThemeType = .nativeMacOS
        }
    }
    
    // MARK: - Layout Persistence
    
    private func loadPersistedLayout() {
        let (_, gridConfig) = layoutPersistence.loadLayout()
        
        // Apply grid configuration
        widgetManager.gridConfiguration = gridConfig
        
        // Layout data will be used to restore widgets when they're registered
        // Store it for later use in setupInitialWidgets
    }
    
    private func setupAutoSave() {
        layoutPersistence.setupAutoSave(widgetManager: widgetManager)
    }
    
    func saveLayout() {
        layoutPersistence.saveLayout(widgetManager.containers, gridConfig: widgetManager.gridConfiguration)
    }
    
    func clearLayout() {
        layoutPersistence.clearLayout()
        widgetManager.removeAllContainers()
    }
    
    // MARK: - Widget Creation Methods
    
    func addClockWidget() {
        DebugLog.placement("Adding clock widget...")
        let clockWidget = ClockWidget()
        widgetManager.registerContainer(clockWidget)
        DebugLog.placement("Clock widget added. Total containers: \(widgetManager.containers.count)")
    }
    
    func addWeatherWidget() {
        let weatherWidget = WeatherWidget()
        widgetManager.registerContainer(weatherWidget)
    }
    
    func addCalendarWidget() {
        let calendarWidget = CalendarWidget()
        widgetManager.registerContainer(calendarWidget)
    }
    
    func addRemindersWidget() {
        let remindersWidget = RemindersWidget()
        widgetManager.registerContainer(remindersWidget)
    }
    
    func addNotesWidget() {
        let notesWidget = NotesWidget()
        widgetManager.registerContainer(notesWidget)
    }
    
    func addSystemMonitorWidget() {
        let systemWidget = SystemMonitorWidget()
        widgetManager.registerContainer(systemWidget)
    }
    
    func addFitnessWidget() {
        let fitnessWidget = FitnessWidget()
        widgetManager.registerContainer(fitnessWidget)
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
            .masonry,
        ]
    }
}
