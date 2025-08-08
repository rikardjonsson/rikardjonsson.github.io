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
