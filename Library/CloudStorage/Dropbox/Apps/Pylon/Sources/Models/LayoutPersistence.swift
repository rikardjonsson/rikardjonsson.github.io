//
//  LayoutPersistence.swift
//  Pylon
//
//  Created on 05.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Handles saving and loading widget layout configurations
/// Persists widget positions, sizes, themes, and enabled states
@MainActor
class LayoutPersistence: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let layoutKey = "PylonWidgetLayout"
    private let gridConfigKey = "PylonLegacyGridConfiguration"
    private let themeKey = "PylonSelectedTheme"
    private let appStateKey = "PylonAppState"
    
    // MARK: - Layout Persistence
    
    func saveLayout(_ containers: [any WidgetContainer], gridConfig: LegacyGridConfiguration) {
        let layoutData = containers.map { container in
            WidgetLayoutData(
                id: container.id.uuidString,
                title: container.title,
                category: container.category.rawValue,
                size: container.size.rawValue,
                position: GridPosition(row: container.gridPosition.row, column: container.gridPosition.column),
                isEnabled: container.isEnabled,
                theme: container.theme
            )
        }
        
        do {
            let encoded = try JSONEncoder().encode(layoutData)
            userDefaults.set(encoded, forKey: layoutKey)
            
            let gridConfigData = try JSONEncoder().encode(gridConfig)
            userDefaults.set(gridConfigData, forKey: gridConfigKey)
            
            DebugLog.success("Layout saved: \(containers.count) widgets")
        } catch {
            DebugLog.error("Failed to save layout: \(error)")
        }
    }
    
    func loadLayout() -> ([WidgetLayoutData], LegacyGridConfiguration) {
        var layoutData: [WidgetLayoutData] = []
        var gridConfig = LegacyGridConfiguration()
        
        // Load widget layout data
        if let data = userDefaults.data(forKey: layoutKey) {
            do {
                layoutData = try JSONDecoder().decode([WidgetLayoutData].self, from: data)
                DebugLog.success("Layout loaded: \(layoutData.count) widgets")
            } catch {
                DebugLog.error("Failed to load layout: \(error)")
            }
        }
        
        // Load grid configuration
        if let data = userDefaults.data(forKey: gridConfigKey) {
            do {
                gridConfig = try JSONDecoder().decode(LegacyGridConfiguration.self, from: data)
                DebugLog.success("Grid config loaded: \(gridConfig.columns) columns")
            } catch {
                DebugLog.error("Failed to load grid config: \(error)")
            }
        }
        
        return (layoutData, gridConfig)
    }
    
    func clearLayout() {
        userDefaults.removeObject(forKey: layoutKey)
        userDefaults.removeObject(forKey: gridConfigKey)
        DebugLog.success("Layout cleared")
    }
    
    // MARK: - Theme Persistence
    
    func saveTheme(_ themeType: ThemeType) {
        do {
            let encoded = try JSONEncoder().encode(themeType)
            userDefaults.set(encoded, forKey: themeKey)
            DebugLog.success("Theme saved: \(themeType)")
        } catch {
            DebugLog.error("Failed to save theme: \(error)")
        }
    }
    
    func loadTheme() -> ThemeType {
        guard let data = userDefaults.data(forKey: themeKey) else {
            DebugLog.info("No saved theme found, using default")
            return .nativeMacOS
        }
        
        do {
            let themeType = try JSONDecoder().decode(ThemeType.self, from: data)
            DebugLog.success("Theme loaded: \(themeType)")
            return themeType
        } catch {
            DebugLog.error("Failed to load theme: \(error), using default")
            return .nativeMacOS
        }
    }
    
    // MARK: - App State Persistence
    
    func saveAppState(themeType: ThemeType, widgetLayout: WidgetLayout, isKeyboardNavigationEnabled: Bool) {
        let appStateData = AppStateData(
            selectedThemeType: themeType,
            widgetLayout: widgetLayout,
            isKeyboardNavigationEnabled: isKeyboardNavigationEnabled
        )
        
        do {
            let encoded = try JSONEncoder().encode(appStateData)
            userDefaults.set(encoded, forKey: appStateKey)
            DebugLog.success("App state saved")
        } catch {
            DebugLog.error("Failed to save app state: \(error)")
        }
    }
    
    func loadAppState() -> AppStateData? {
        guard let data = userDefaults.data(forKey: appStateKey) else {
            DebugLog.info("No saved app state found")
            return nil
        }
        
        do {
            let appState = try JSONDecoder().decode(AppStateData.self, from: data)
            DebugLog.success("App state loaded")
            return appState
        } catch {
            DebugLog.error("Failed to load app state: \(error)")
            return nil
        }
    }
    
    // MARK: - Auto-save
    
    func setupAutoSave(widgetManager: WidgetManager) {
        // Save layout whenever containers change
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                self.saveLayout(widgetManager.containers, gridConfig: widgetManager.gridConfiguration)
            }
        }
    }
}

// MARK: - Layout Data Models

struct WidgetLayoutData: Codable, Identifiable {
    let id: String // UUID as string for persistence
    let title: String
    let category: String
    let size: String
    let position: GridPosition
    let isEnabled: Bool
    let theme: WidgetThemeOverride?
    
    var uuid: UUID {
        UUID(uuidString: id) ?? UUID()
    }
}

// MARK: - LegacyGridConfiguration Codable Extension

extension LegacyGridConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case columns, gridUnit, spacing, padding
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        columns = try container.decode(Int.self, forKey: .columns)
        gridUnit = try container.decode(CGFloat.self, forKey: .gridUnit)
        spacing = try container.decode(CGFloat.self, forKey: .spacing)
        padding = try container.decode(EdgeInsets.self, forKey: .padding)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columns, forKey: .columns)
        try container.encode(gridUnit, forKey: .gridUnit)
        try container.encode(spacing, forKey: .spacing)
        try container.encode(padding, forKey: .padding)
    }
}

// MARK: - App State Data Model

struct AppStateData: Codable {
    let selectedThemeType: ThemeType
    let widgetLayout: WidgetLayout
    let isKeyboardNavigationEnabled: Bool
}

// MARK: - ThemeType Codable Extension

extension ThemeType: Codable {
    enum CodingKeys: String, CodingKey {
        case nativeMacOS, surveillance, modern, dark, light, system
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        switch stringValue {
        case "nativeMacOS": self = .nativeMacOS
        case "surveillance": self = .surveillance
        case "modern": self = .modern
        case "dark": self = .dark
        case "light": self = .light
        case "system": self = .system
        default: self = .nativeMacOS
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let stringValue: String
        switch self {
        case .nativeMacOS: stringValue = "nativeMacOS"
        case .surveillance: stringValue = "surveillance"
        case .modern: stringValue = "modern"
        case .dark: stringValue = "dark"
        case .light: stringValue = "light"
        case .system: stringValue = "system"
        }
        try container.encode(stringValue)
    }
}

// MARK: - Legacy WidgetLayout Codable Implementation
// Note: WidgetLayout now conforms to Codable automatically, but keeping custom implementation for backward compatibility

extension WidgetLayout {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let columns = try? container.decode(Int.self, forKey: .columns) {
            self = .grid(columns: columns)
        } else if (try? container.decode(Bool.self, forKey: .list)) == true {
            self = .list
        } else if (try? container.decode(Bool.self, forKey: .masonry)) == true {
            self = .masonry
        } else {
            self = .grid(columns: 3) // default
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .grid(let columns):
            try container.encode(columns, forKey: .columns)
        case .list:
            try container.encode(true, forKey: .list)
        case .masonry:
            try container.encode(true, forKey: .masonry)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case grid, list, masonry, columns
    }
}

// MARK: - EdgeInsets Codable Extension

extension EdgeInsets: Codable {
    enum CodingKeys: String, CodingKey {
        case top, leading, bottom, trailing
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let top = try container.decode(CGFloat.self, forKey: .top)
        let leading = try container.decode(CGFloat.self, forKey: .leading)
        let bottom = try container.decode(CGFloat.self, forKey: .bottom)
        let trailing = try container.decode(CGFloat.self, forKey: .trailing)
        self.init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.top, forKey: .top)
        try container.encode(self.leading, forKey: .leading)
        try container.encode(self.bottom, forKey: .bottom)
        try container.encode(self.trailing, forKey: .trailing)
    }
}
