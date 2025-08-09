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
    @Published var layoutConfiguration: LayoutConfiguration = .grid3Column
    @Published var isRefreshing = false

    var selectedTheme: any Theme {
        selectedThemeType.theme
    }
    
    // Legacy support for existing code
    var widgetLayout: WidgetLayout {
        switch layoutConfiguration.layoutType {
        case .grid:
            .grid(columns: layoutConfiguration.columns ?? 3)
        case .list:
            .list
        case .masonry:
            .masonry
        }
    }

    @Published var widgetManager = WidgetManager()
    var layoutPersistence = LayoutPersistence()

    init() {
        // Initialize WidgetManager's grid persistence system
        widgetManager.initializePersistence()
        
        loadPersistedState()
        setupInitialWidgets()
        setupAutoSave()
        setupStatePersistence()
        
        // Remove circular reference that can cause AttributeGraph crashes
        // The @Published widgetManager will automatically notify views of changes
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

        DebugLog.info("Starting refresh of all widgets...")
        await widgetManager.refreshAllContainers()
        DebugLog.info("Widget refresh cycle completed")
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
        
        // Save theme immediately when changed
        layoutPersistence.saveTheme(selectedThemeType)
    }
    
    // MARK: - State Persistence
    
    private func loadPersistedState() {
        // Load persisted app state (theme, layout, settings)
        if let savedAppState = layoutPersistence.loadAppState() {
            selectedThemeType = savedAppState.selectedThemeType
            isKeyboardNavigationEnabled = savedAppState.isKeyboardNavigationEnabled
            
            // Convert legacy WidgetLayout to new LayoutConfiguration
            layoutConfiguration = LayoutConfiguration(from: savedAppState.widgetLayout)
            
            DebugLog.success("Loaded persisted app state")
        } else {
            // Fallback to individual theme loading for backward compatibility
            selectedThemeType = layoutPersistence.loadTheme()
            DebugLog.info("Using default app state with persisted theme")
        }
        
        // Load widget layout data - legacy grid config will be merged with layout config
        let (_, legacyGridConfig) = layoutPersistence.loadLayout()
        
        // Merge legacy grid configuration with layout configuration
        if legacyGridConfig.columns != 8 || legacyGridConfig.gridUnit != 100 { // Non-default values
            layoutConfiguration = LayoutConfiguration(
                layoutType: layoutConfiguration.layoutType,
                gridUnit: legacyGridConfig.gridUnit,
                spacing: legacyGridConfig.spacing,
                padding: legacyGridConfig.padding,
                columns: layoutConfiguration.layoutType == .grid ? legacyGridConfig.columns : nil
            )
        }
        
        // Apply unified configuration to WidgetManager
        widgetManager.gridConfiguration = layoutConfiguration.legacyGridConfiguration
        
        DebugLog.success("Layout configuration applied: \(layoutConfiguration.displayName)")
    }
    
    private func setupStatePersistence() {
        // Auto-save app state when key properties change
        $selectedThemeType
            .sink { [weak self] _ in
                self?.saveAppState()
            }
            .store(in: &cancellables)
            
        $layoutConfiguration
            .sink { [weak self] _ in
                self?.saveAppState()
                self?.updateWidgetManagerConfiguration()
            }
            .store(in: &cancellables)
            
        $isKeyboardNavigationEnabled
            .sink { [weak self] _ in
                self?.saveAppState()
            }
            .store(in: &cancellables)
    }
    
    private func updateWidgetManagerConfiguration() {
        widgetManager.gridConfiguration = layoutConfiguration.legacyGridConfiguration
        DebugLog.info("Updated widget manager with layout: \(layoutConfiguration.displayName)")
    }
    
    private func saveAppState() {
        layoutPersistence.saveAppState(
            themeType: selectedThemeType,
            widgetLayout: widgetLayout, // Use legacy property for backward compatibility
            isKeyboardNavigationEnabled: isKeyboardNavigationEnabled
        )
    }
    
    private func setupAutoSave() {
        layoutPersistence.setupAutoSave(widgetManager: widgetManager)
    }
    
    func saveLayout() {
        layoutPersistence.saveLayout(widgetManager.containers, gridConfig: widgetManager.gridConfiguration)
        saveAppState() // Also save current app state
    }
    
    func clearLayout() {
        layoutPersistence.clearLayout()
        widgetManager.removeAllContainers()
        
        // Reset to default values
        selectedThemeType = .nativeMacOS
        layoutConfiguration = .grid3Column
        isKeyboardNavigationEnabled = true
        saveAppState()
    }
    
    // MARK: - Layout Management
    
    func setLayoutConfiguration(_ configuration: LayoutConfiguration) {
        layoutConfiguration = configuration
        // saveAppState() is called automatically via the publisher
    }
    
    func toggleLayoutMode() {
        let allConfigs = LayoutConfiguration.allCases
        let currentIndex = allConfigs.firstIndex(of: layoutConfiguration) ?? 0
        let nextIndex = (currentIndex + 1) % allConfigs.count
        setLayoutConfiguration(allConfigs[nextIndex])
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

// MARK: - Unified Layout Configuration

struct LayoutConfiguration: Equatable, Sendable, Codable {
    let layoutType: LayoutType
    let gridUnit: CGFloat
    let spacing: CGFloat
    let padding: EdgeInsets
    
    // Grid-specific properties
    let columns: Int?
    
    init(
        layoutType: LayoutType,
        gridUnit: CGFloat = 100,
        spacing: CGFloat = 4,
        padding: EdgeInsets = LayoutConfiguration.defaultPadding,
        columns: Int? = nil
    ) {
        self.layoutType = layoutType
        self.gridUnit = gridUnit
        self.spacing = spacing
        self.padding = padding
        self.columns = columns
    }
    
    // Default padding
    private static let defaultPadding = EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
    
    // Preset configurations
    static let grid2Column = LayoutConfiguration(layoutType: .grid, columns: 2)
    static let grid3Column = LayoutConfiguration(layoutType: .grid, columns: 3)
    static let grid4Column = LayoutConfiguration(layoutType: .grid, columns: 4)
    static let list = LayoutConfiguration(layoutType: .list)
    static let masonry = LayoutConfiguration(layoutType: .masonry)
    
    static let allCases: [LayoutConfiguration] = [
        .grid2Column, .grid3Column, .grid4Column, .list, .masonry
    ]
    
    var displayName: String {
        switch layoutType {
        case .grid:
            "Grid (\(columns ?? 3) columns)"
        case .list:
            "List"
        case .masonry:
            "Masonry"
        }
    }
}

enum LayoutType: String, CaseIterable, Sendable, Codable {
    case grid
    case list
    case masonry
    
    var displayName: String {
        switch self {
        case .grid: "Grid"
        case .list: "List"
        case .masonry: "Masonry"
        }
    }
}

// MARK: - Legacy Support

enum WidgetLayout: Equatable, CaseIterable, Sendable, Codable {
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
    
    // Convert to unified configuration
    var layoutConfiguration: LayoutConfiguration {
        switch self {
        case .grid(let columns):
            LayoutConfiguration(layoutType: .grid, columns: columns)
        case .list:
            LayoutConfiguration.list
        case .masonry:
            LayoutConfiguration.masonry
        }
    }
}

extension LayoutConfiguration {
    // Convert from legacy WidgetLayout
    init(from widgetLayout: WidgetLayout) {
        self = widgetLayout.layoutConfiguration
    }
    
    // Convert to LegacyGridConfiguration for backward compatibility
    var legacyGridConfiguration: LegacyGridConfiguration {
        var config = LegacyGridConfiguration()
        config.columns = columns ?? 8
        config.gridUnit = gridUnit
        config.spacing = spacing
        config.padding = padding
        return config
    }
}
