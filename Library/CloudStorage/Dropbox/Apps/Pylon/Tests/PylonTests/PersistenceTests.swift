//
//  PersistenceTests.swift
//  PylonTests
//
//  Created on 09.08.25.
//  Comprehensive test suite for persistence functionality
//

import XCTest
import SwiftUI
@testable import Pylon

@MainActor
final class PersistenceTests: XCTestCase {
    
    var layoutPersistence: LayoutPersistence!
    fileprivate var testWidgetContainer: MockWidgetContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        layoutPersistence = LayoutPersistence()
        testWidgetContainer = MockWidgetContainer()
        
        // Clear any existing data
        layoutPersistence.clearLayout()
    }
    
    override func tearDown() async throws {
        // Clean up after each test
        layoutPersistence.clearLayout()
        layoutPersistence = nil
        testWidgetContainer = nil
        try await super.tearDown()
    }
    
    // MARK: - Theme Persistence Tests
    
    func testSaveAndLoadTheme() {
        let testTheme: ThemeType = .surveillance
        
        layoutPersistence.saveTheme(testTheme)
        let loadedTheme = layoutPersistence.loadTheme()
        
        XCTAssertEqual(loadedTheme, testTheme)
    }
    
    func testLoadThemeWithNoSavedData() {
        let defaultTheme = layoutPersistence.loadTheme()
        XCTAssertEqual(defaultTheme, .nativeMacOS)
    }
    
    func testMultipleThemeSaves() {
        let themes: [ThemeType] = [.surveillance, .modern, .dark, .light, .system, .nativeMacOS]
        
        for theme in themes {
            layoutPersistence.saveTheme(theme)
            let loaded = layoutPersistence.loadTheme()
            XCTAssertEqual(loaded, theme)
        }
    }
    
    // MARK: - App State Persistence Tests
    
    func testSaveAndLoadAppState() {
        let testTheme: ThemeType = .modern
        let testLayout: WidgetLayout = .grid(columns: 4)
        let testKeyboardNav = false
        
        layoutPersistence.saveAppState(
            themeType: testTheme,
            widgetLayout: testLayout,
            isKeyboardNavigationEnabled: testKeyboardNav
        )
        
        let loadedState = layoutPersistence.loadAppState()
        
        XCTAssertNotNil(loadedState)
        XCTAssertEqual(loadedState?.selectedThemeType, testTheme)
        XCTAssertEqual(loadedState?.widgetLayout, testLayout)
        XCTAssertEqual(loadedState?.isKeyboardNavigationEnabled, testKeyboardNav)
    }
    
    func testLoadAppStateWithNoSavedData() {
        let loadedState = layoutPersistence.loadAppState()
        XCTAssertNil(loadedState)
    }
    
    func testAppStateOverwrite() {
        // Save initial state
        layoutPersistence.saveAppState(
            themeType: .surveillance,
            widgetLayout: .list,
            isKeyboardNavigationEnabled: true
        )
        
        // Overwrite with new state
        layoutPersistence.saveAppState(
            themeType: .dark,
            widgetLayout: .masonry,
            isKeyboardNavigationEnabled: false
        )
        
        let loadedState = layoutPersistence.loadAppState()
        
        XCTAssertNotNil(loadedState)
        XCTAssertEqual(loadedState?.selectedThemeType, .dark)
        XCTAssertEqual(loadedState?.widgetLayout, .masonry)
        XCTAssertEqual(loadedState?.isKeyboardNavigationEnabled, false)
    }
    
    // MARK: - Widget Layout Persistence Tests
    
    func testSaveAndLoadWidgetLayout() {
        let testContainers: [any WidgetContainer] = [testWidgetContainer]
        var testGridConfig = LegacyGridConfiguration()
        testGridConfig.columns = 6
        testGridConfig.gridUnit = 150
        
        layoutPersistence.saveLayout(testContainers, gridConfig: testGridConfig)
        let (loadedLayout, loadedGridConfig) = layoutPersistence.loadLayout()
        
        XCTAssertEqual(loadedLayout.count, 1)
        XCTAssertEqual(loadedLayout.first?.title, testWidgetContainer.title)
        XCTAssertEqual(loadedGridConfig.columns, 6)
        XCTAssertEqual(loadedGridConfig.gridUnit, 150)
    }
    
    func testLoadLayoutWithNoSavedData() {
        let (loadedLayout, loadedGridConfig) = layoutPersistence.loadLayout()
        
        XCTAssertTrue(loadedLayout.isEmpty)
        // Should return default grid configuration
        XCTAssertEqual(loadedGridConfig.columns, 8) // Default value
    }
    
    func testSaveMultipleWidgets() {
        let widget1 = MockWidgetContainer()
        widget1.title = "Widget 1"
        widget1.size = .small
        
        let widget2 = MockWidgetContainer()
        widget2.title = "Widget 2"
        widget2.size = .large
        
        let widgets: [any WidgetContainer] = [widget1, widget2]
        let gridConfig = LegacyGridConfiguration()
        
        layoutPersistence.saveLayout(widgets, gridConfig: gridConfig)
        let (loadedLayout, _) = layoutPersistence.loadLayout()
        
        XCTAssertEqual(loadedLayout.count, 2)
        
        let titles = loadedLayout.map { $0.title }
        XCTAssertTrue(titles.contains("Widget 1"))
        XCTAssertTrue(titles.contains("Widget 2"))
    }
    
    // MARK: - Clear Layout Tests
    
    func testClearLayout() {
        // Save some data first
        layoutPersistence.saveTheme(.surveillance)
        layoutPersistence.saveAppState(themeType: .modern, widgetLayout: .list, isKeyboardNavigationEnabled: false)
        layoutPersistence.saveLayout([testWidgetContainer], gridConfig: LegacyGridConfiguration())
        
        // Clear everything
        layoutPersistence.clearLayout()
        
        // Verify data is cleared
        let loadedTheme = layoutPersistence.loadTheme()
        let loadedAppState = layoutPersistence.loadAppState()
        let (loadedLayout, _) = layoutPersistence.loadLayout()
        
        XCTAssertEqual(loadedTheme, .nativeMacOS) // Default
        XCTAssertNil(loadedAppState)
        XCTAssertTrue(loadedLayout.isEmpty)
    }
    
    // MARK: - Codable Tests
    
    func testThemeTypeCodable() throws {
        let themes: [ThemeType] = [.nativeMacOS, .surveillance, .modern, .dark, .light, .system]
        
        for theme in themes {
            let encoded = try JSONEncoder().encode(theme)
            let decoded = try JSONDecoder().decode(ThemeType.self, from: encoded)
            XCTAssertEqual(theme, decoded)
        }
    }
    
    func testWidgetLayoutCodable() throws {
        let layouts: [WidgetLayout] = [
            .grid(columns: 2),
            .grid(columns: 3),
            .grid(columns: 4),
            .list,
            .masonry
        ]
        
        for layout in layouts {
            let encoded = try JSONEncoder().encode(layout)
            let decoded = try JSONDecoder().decode(WidgetLayout.self, from: encoded)
            XCTAssertEqual(layout, decoded)
        }
    }
    
    func testAppStateDataCodable() throws {
        let appState = AppStateData(
            selectedThemeType: .surveillance,
            widgetLayout: .grid(columns: 3),
            isKeyboardNavigationEnabled: true
        )
        
        let encoded = try JSONEncoder().encode(appState)
        let decoded = try JSONDecoder().decode(AppStateData.self, from: encoded)
        
        XCTAssertEqual(decoded.selectedThemeType, appState.selectedThemeType)
        XCTAssertEqual(decoded.widgetLayout, appState.widgetLayout)
        XCTAssertEqual(decoded.isKeyboardNavigationEnabled, appState.isKeyboardNavigationEnabled)
    }
    
    func testLegacyGridConfigurationCodable() throws {
        var gridConfig = LegacyGridConfiguration()
        gridConfig.columns = 10
        gridConfig.gridUnit = 200
        gridConfig.spacing = 12
        
        let encoded = try JSONEncoder().encode(gridConfig)
        let decoded = try JSONDecoder().decode(LegacyGridConfiguration.self, from: encoded)
        
        XCTAssertEqual(decoded.columns, gridConfig.columns)
        XCTAssertEqual(decoded.gridUnit, gridConfig.gridUnit)
        XCTAssertEqual(decoded.spacing, gridConfig.spacing)
    }
    
    // MARK: - Edge Case Tests
    
    func testCorruptedDataHandling() {
        let corruptedData = "invalid json data".data(using: .utf8)!
        UserDefaults.standard.set(corruptedData, forKey: "PylonSelectedTheme")
        
        // Should return default theme when data is corrupted
        let theme = layoutPersistence.loadTheme()
        XCTAssertEqual(theme, .nativeMacOS)
    }
    
    func testEmptyContainersList() {
        let emptyContainers: [any WidgetContainer] = []
        let gridConfig = LegacyGridConfiguration()
        
        layoutPersistence.saveLayout(emptyContainers, gridConfig: gridConfig)
        let (loadedLayout, _) = layoutPersistence.loadLayout()
        
        XCTAssertTrue(loadedLayout.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testSavePerformance() {
        // Create many widgets
        var widgets: [any WidgetContainer] = []
        for i in 0..<100 {
            let widget = MockWidgetContainer()
            widget.title = "Widget \(i)"
            widgets.append(widget)
        }
        
        let gridConfig = LegacyGridConfiguration()
        
        measure {
            layoutPersistence.saveLayout(widgets, gridConfig: gridConfig)
        }
    }
    
    func testLoadPerformance() {
        // First save a lot of data
        var widgets: [any WidgetContainer] = []
        for i in 0..<100 {
            let widget = MockWidgetContainer()
            widget.title = "Widget \(i)"
            widgets.append(widget)
        }
        
        layoutPersistence.saveLayout(widgets, gridConfig: LegacyGridConfiguration())
        
        measure {
            let _ = layoutPersistence.loadLayout()
        }
    }
}

// MARK: - Mock Widget Container

fileprivate class MockWidgetContainer: WidgetContainer, @unchecked Sendable {
    let id = UUID()
    var size: WidgetSize = .medium
    var theme: WidgetThemeOverride? = nil
    var title: String = "Mock Widget"
    var category: WidgetCategory = .system
    var supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    var isEnabled: Bool = true
    var gridPosition: GridPosition = .zero
    var lastUpdated: Date? = Date()
    var isLoading: Bool = false
    var error: Error? = nil
    
    @MainActor
    func refresh() async throws {
        // Mock implementation
    }
    
    func configure() -> AnyView {
        AnyView(Text("Mock Configuration"))
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(Text("Mock Widget Body"))
    }
}