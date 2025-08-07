//
//  GridLayoutPersistence.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Layout persistence and serialization
//

import Foundation
import SwiftUI

/// Serializable grid layout data
struct GridLayoutData: Codable, Sendable, Identifiable {
    let id: UUID
    let name: String
    let configuration: GridConfiguration
    let widgets: [SerializableWidget]
    let createdAt: Date
    let lastModified: Date
    
    init(id: UUID = UUID(), name: String, configuration: GridConfiguration, widgets: [any GridWidget]) {
        self.id = id
        self.name = name
        self.configuration = configuration
        self.widgets = widgets.map { SerializableWidget(from: $0) }
        self.createdAt = Date()
        self.lastModified = Date()
    }
}

/// Serializable widget representation
struct SerializableWidget: Codable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let size: GridSize
    let position: GridPosition
    let category: GridWidgetCategory
    let isEnabled: Bool
    let lastUpdated: Date?
    
    init(from widget: any GridWidget) {
        self.id = widget.id
        self.title = widget.title
        self.size = widget.size
        self.position = widget.position
        self.category = widget.category
        self.isEnabled = widget.isEnabled
        self.lastUpdated = widget.lastUpdated
    }
}

/// Grid layout persistence manager
@MainActor
@Observable
class GridLayoutPersistence: Sendable {
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let layoutsDirectory: URL
    
    private(set) var savedLayouts: [GridLayoutData] = []
    private(set) var currentLayoutId: UUID?
    
    /// Auto-save delay timer
    private var autoSaveTimer: Timer?
    private let autoSaveDelay: TimeInterval = 2.0 // 2 seconds after last change
    
    init() throws {
        // Setup directories
        self.documentsDirectory = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        self.layoutsDirectory = documentsDirectory.appendingPathComponent("GridLayouts", isDirectory: true)
        
        // Create layouts directory if needed
        try fileManager.createDirectory(
            at: layoutsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        // Load existing layouts
        loadSavedLayouts()
    }
    
    // MARK: - Save Operations
    
    /// Save current grid layout
    func saveLayout(_ gridManager: GridManager, name: String) throws {
        let layoutData = GridLayoutData(
            name: name,
            configuration: gridManager.configuration,
            widgets: gridManager.widgets
        )
        
        try saveLayoutData(layoutData)
        currentLayoutId = layoutData.id
        
        print("💾 Saved layout: \(name)")
    }
    
    /// Auto-save current layout (delayed)
    func autoSaveLayout(_ gridManager: GridManager, name: String = "Autosave") {
        autoSaveTimer?.invalidate()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveDelay, repeats: false) { _ in
            Task { @MainActor in
                do {
                    try self.saveLayout(gridManager, name: name)
                } catch {
                    print("❌ Auto-save failed: \(error)")
                }
            }
        }
    }
    
    /// Save layout data to disk
    private func saveLayoutData(_ layoutData: GridLayoutData) throws {
        let fileURL = layoutsDirectory.appendingPathComponent("\(layoutData.id.uuidString).json")
        let data = try JSONEncoder().encode(layoutData)
        try data.write(to: fileURL)
        
        // Update in-memory cache
        if let index = savedLayouts.firstIndex(where: { $0.id == layoutData.id }) {
            savedLayouts[index] = layoutData
        } else {
            savedLayouts.append(layoutData)
        }
        
        // Sort by last modified
        savedLayouts.sort { $0.lastModified > $1.lastModified }
    }
    
    // MARK: - Load Operations
    
    /// Load a specific grid layout
    func loadLayout(_ layoutData: GridLayoutData, into gridManager: GridManager) throws {
        // Clear current widgets
        gridManager.removeAllWidgets()
        
        // Update configuration if needed
        if layoutData.configuration != gridManager.configuration {
            gridManager.updateConfiguration(layoutData.configuration)
        }
        
        // Convert serialized widgets back to GridWidgets
        for serializedWidget in layoutData.widgets {
            let widget = try restoreWidget(from: serializedWidget)
            _ = gridManager.addWidget(widget)
        }
        
        currentLayoutId = layoutData.id
        print("📂 Loaded layout: \(layoutData.name)")
    }
    
    /// Load all saved layouts from disk
    private func loadSavedLayouts() {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: layoutsDirectory, includingPropertiesForKeys: nil)
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            savedLayouts = jsonFiles.compactMap { url in
                do {
                    let data = try Data(contentsOf: url)
                    return try JSONDecoder().decode(GridLayoutData.self, from: data)
                } catch {
                    print("⚠️ Failed to load layout from \(url): \(error)")
                    return nil
                }
            }
            
            // Sort by last modified
            savedLayouts.sort { $0.lastModified > $1.lastModified }
            
            print("📚 Loaded \(savedLayouts.count) saved layouts")
            
        } catch {
            print("❌ Failed to load saved layouts: \(error)")
        }
    }
    
    /// Restore a GridWidget from serialized data
    private func restoreWidget(from serialized: SerializableWidget) throws -> any GridWidget {
        // Create appropriate widget type based on category and title
        // This is a simplified restoration - in a real app, you'd have a widget factory
        
        switch serialized.category {
        case .utilities:
            if serialized.title.contains("Clock") {
                // TODO: Replace with actual widget instantiation
                // var widget = ClockWidget()
                // widget.size = serialized.size
                // widget.position = serialized.position
                // return widget
                var widget = ExampleWidget(title: serialized.title, size: serialized.size, category: serialized.category)
                widget.position = serialized.position
                return widget
            } else {
                var widget = ExampleWidget(title: serialized.title, size: serialized.size, category: serialized.category)
                widget.position = serialized.position
                return widget
            }
            
        case .information:
            if serialized.title.contains("Weather") {
                // TODO: Replace with actual widget instantiation
                // var widget = WeatherWidget()
                // widget.size = serialized.size
                // widget.position = serialized.position
                // return widget
                var widget = ExampleWidget(title: serialized.title, size: serialized.size, category: serialized.category)
                widget.position = serialized.position
                return widget
            } else {
                var widget = ExampleWidget(title: serialized.title, size: serialized.size, category: serialized.category)
                widget.position = serialized.position
                return widget
            }
            
        default:
            // Generic widget for other categories
            var widget = ExampleWidget(title: serialized.title, size: serialized.size, category: serialized.category)
            widget.position = serialized.position
            return widget
        }
    }
    
    // MARK: - Management Operations
    
    /// Delete a saved layout
    func deleteLayout(_ layoutData: GridLayoutData) throws {
        let fileURL = layoutsDirectory.appendingPathComponent("\(layoutData.id.uuidString).json")
        try fileManager.removeItem(at: fileURL)
        
        savedLayouts.removeAll { $0.id == layoutData.id }
        
        if currentLayoutId == layoutData.id {
            currentLayoutId = nil
        }
        
        print("🗑️ Deleted layout: \(layoutData.name)")
    }
    
    /// Export layout to JSON data
    func exportLayout(_ layoutData: GridLayoutData) throws -> Data {
        return try JSONEncoder().encode(layoutData)
    }
    
    /// Import layout from JSON data
    func importLayout(from data: Data) throws -> GridLayoutData {
        let layoutData = try JSONDecoder().decode(GridLayoutData.self, from: data)
        try saveLayoutData(layoutData)
        return layoutData
    }
    
    // MARK: - Quick Actions
    
    /// Get the most recently saved layout
    var mostRecentLayout: GridLayoutData? {
        return savedLayouts.first
    }
    
    /// Get layouts sorted by name
    var layoutsByName: [GridLayoutData] {
        return savedLayouts.sorted { $0.name < $1.name }
    }
    
    /// Clean up old autosaves (keep only the 5 most recent)
    func cleanupAutosaves() {
        let autosaves = savedLayouts.filter { $0.name.contains("Autosave") }
        let excessAutosaves = Array(autosaves.dropFirst(5))
        
        for autosave in excessAutosaves {
            try? deleteLayout(autosave)
        }
    }
}

// MARK: - GridManager Extensions
// Note: updateConfiguration method already exists in GridManager