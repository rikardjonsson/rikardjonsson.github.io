//
//  GridSystemTests.swift
//  PylonTests
//
//  Created on 06.08.25.
//  Grid Layout System - Comprehensive test suite
//

import XCTest
@testable import Pylon

/// Comprehensive test suite for the new grid system
final class GridSystemTests: XCTestCase {
    
    var gridManager: GridManager!
    var testWidget: ExampleWidget!
    
    override func setUp() {
        super.setUp()
        gridManager = GridManager(configuration: .standard)
        testWidget = ExampleWidget(title: "Test Widget", size: .medium, category: .utilities)
    }
    
    override func tearDown() {
        gridManager = nil
        testWidget = nil
        super.tearDown()
    }
    
    // MARK: - Core Grid Engine Tests
    
    func testGridPositionBasics() {
        let position = GridPosition(row: 1, column: 2)
        XCTAssertEqual(position.row, 1)
        XCTAssertEqual(position.column, 2)
        XCTAssertEqual(GridPosition.zero.row, 0)
        XCTAssertEqual(GridPosition.zero.column, 0)
    }
    
    func testGridSizePresets() {
        XCTAssertEqual(GridSize.small.width, 1)
        XCTAssertEqual(GridSize.small.height, 1)
        XCTAssertEqual(GridSize.medium.width, 2)
        XCTAssertEqual(GridSize.medium.height, 2)
        XCTAssertEqual(GridSize.large.width, 4)
        XCTAssertEqual(GridSize.large.height, 2)
    }
    
    func testGridBounds() {
        let bounds = GridBounds.standard
        XCTAssertEqual(bounds.columns, 8)
        XCTAssertEqual(bounds.rows, Int.max)
        
        XCTAssertTrue(bounds.contains(GridPosition(row: 0, column: 0)))
        XCTAssertTrue(bounds.contains(GridPosition(row: 100, column: 7)))
        XCTAssertFalse(bounds.contains(GridPosition(row: 0, column: 8)))
    }
    
    func testGridConfiguration() {
        let config = GridConfiguration.standard
        XCTAssertEqual(config.cellSize, 80)
        XCTAssertEqual(config.cellSpacing, 12)
        XCTAssertEqual(config.bounds.columns, 8)
        
        let frameSize = config.frameSize(for: .medium)
        XCTAssertEqual(frameSize.width, 172) // (80 * 2) + (12 * 1)
        XCTAssertEqual(frameSize.height, 172)
        
        let framePosition = config.framePosition(for: GridPosition(row: 1, column: 1))
        XCTAssertEqual(framePosition.x, 92) // (80 + 12) * 1
        XCTAssertEqual(framePosition.y, 92)
    }
    
    // MARK: - Widget Protocol Tests
    
    func testGridWidget() {
        XCTAssertEqual(testWidget.title, "Test Widget")
        XCTAssertEqual(testWidget.size, .medium)
        XCTAssertEqual(testWidget.category, .utilities)
        XCTAssertTrue(testWidget.isEnabled)
        XCTAssertTrue(testWidget.supportedSizes.contains(.medium))
    }
    
    func testWidgetCategories() {
        let categories = GridWidgetCategory.allCases
        XCTAssertTrue(categories.contains(.utilities))
        XCTAssertTrue(categories.contains(.information))
        XCTAssertTrue(categories.contains(.productivity))
        
        XCTAssertEqual(GridWidgetCategory.utilities.systemImage, "wrench.and.screwdriver")
        XCTAssertEqual(GridWidgetCategory.information.systemImage, "info.circle")
    }
    
    // MARK: - Layout Engine Tests
    
    func testTetrisLayoutEngine() {
        let engine = TetrisLayoutEngine()
        let config = GridConfiguration.standard
        
        // Test finding available position
        let position = engine.findAvailablePosition(
            for: testWidget,
            avoiding: [],
            configuration: config
        )
        
        XCTAssertNotNil(position)
        XCTAssertEqual(position, GridPosition(row: 0, column: 0))
    }
    
    func testCollisionDetection() {
        let detector = SimpleCollisionDetector()
        
        // Test non-overlapping positions
        XCTAssertFalse(detector.hasCollision(
            widget: testWidget,
            at: GridPosition(row: 0, column: 0),
            with: []
        ))
        
        // Test overlapping positions
        let occupiedPositions: Set<GridPosition> = [
            GridPosition(row: 0, column: 0),
            GridPosition(row: 0, column: 1),
            GridPosition(row: 1, column: 0),
            GridPosition(row: 1, column: 1)
        ]
        
        XCTAssertTrue(detector.hasCollision(
            widget: testWidget,
            at: GridPosition(row: 0, column: 0),
            with: occupiedPositions
        ))
    }
    
    // MARK: - Grid Manager Tests
    
    func testGridManagerAddWidget() {
        XCTAssertTrue(gridManager.widgets.isEmpty)
        
        let success = gridManager.addWidget(testWidget)
        XCTAssertTrue(success)
        XCTAssertEqual(gridManager.widgets.count, 1)
        XCTAssertEqual(gridManager.widgets.first?.id, testWidget.id)
    }
    
    func testGridManagerDuplicateWidget() {
        // Add widget first time
        XCTAssertTrue(gridManager.addWidget(testWidget))
        
        // Try to add same widget again
        XCTAssertFalse(gridManager.addWidget(testWidget))
        XCTAssertEqual(gridManager.widgets.count, 1)
    }
    
    func testGridManagerRemoveWidget() {
        gridManager.addWidget(testWidget)
        XCTAssertEqual(gridManager.widgets.count, 1)
        
        let removed = gridManager.removeWidget(id: testWidget.id)
        XCTAssertTrue(removed)
        XCTAssertTrue(gridManager.widgets.isEmpty)
    }
    
    func testGridManagerMoveWidget() {
        gridManager.addWidget(testWidget)
        let originalPosition = testWidget.position
        let newPosition = GridPosition(row: 2, column: 2)
        
        let moved = gridManager.moveWidget(id: testWidget.id, to: newPosition)
        XCTAssertTrue(moved)
        
        let movedWidget = gridManager.widgets.first { $0.id == testWidget.id }
        XCTAssertNotNil(movedWidget)
        XCTAssertEqual(movedWidget?.position, newPosition)
        XCTAssertNotEqual(movedWidget?.position, originalPosition)
    }
    
    func testGridManagerCanPlaceWidget() {
        // Empty grid should allow placement anywhere valid
        XCTAssertTrue(gridManager.canPlaceWidget(testWidget, at: GridPosition(row: 0, column: 0)))
        XCTAssertTrue(gridManager.canPlaceWidget(testWidget, at: GridPosition(row: 5, column: 5)))
        
        // Out of bounds should fail
        XCTAssertFalse(gridManager.canPlaceWidget(testWidget, at: GridPosition(row: 0, column: 10)))
        
        // Add a widget and test collision
        gridManager.addWidget(testWidget)
        let overlappingWidget = ExampleWidget(title: "Overlap", size: .medium, category: .utilities)
        
        XCTAssertFalse(gridManager.canPlaceWidget(overlappingWidget, at: GridPosition(row: 0, column: 0)))
        XCTAssertTrue(gridManager.canPlaceWidget(overlappingWidget, at: GridPosition(row: 3, column: 3)))
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithManyWidgets() {
        measure {
            // Add many widgets to test performance
            for i in 0..<20 {
                let widget = ExampleWidget(
                    title: "Widget \(i)",
                    size: .small,
                    category: .utilities
                )
                _ = gridManager.addWidget(widget)
            }
            
            // Clear for next iteration
            gridManager.removeAllWidgets()
        }
    }
    
    func testLayoutEnginePerformance() {
        // Fill grid with many widgets first
        for i in 0..<30 {
            let widget = ExampleWidget(
                title: "Widget \(i)",
                size: .small,
                category: .utilities
            )
            _ = gridManager.addWidget(widget)
        }
        
        measure {
            // Test finding available position in crowded grid
            let newWidget = ExampleWidget(title: "New", size: .medium, category: .utilities)
            _ = gridManager.layoutEngine.findAvailablePosition(
                for: newWidget,
                avoiding: gridManager.occupiedPositions,
                configuration: gridManager.configuration
            )
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidPositions() {
        let invalidWidget = ExampleWidget(title: "Invalid", size: .large, category: .utilities)
        
        // Try to place large widget where it won't fit
        let success = gridManager.canPlaceWidget(invalidWidget, at: GridPosition(row: 0, column: 6))
        XCTAssertFalse(success)
    }
    
    func testGridBoundaryConditions() {
        // Test widget exactly at boundary
        let boundaryWidget = ExampleWidget(title: "Boundary", size: .small, category: .utilities)
        boundaryWidget.position = GridPosition(row: 0, column: 7) // Last valid column
        
        XCTAssertTrue(gridManager.addWidget(boundaryWidget))
        
        // Test widget beyond boundary
        let beyondWidget = ExampleWidget(title: "Beyond", size: .small, category: .utilities)
        beyondWidget.position = GridPosition(row: 0, column: 8) // Invalid column
        
        XCTAssertFalse(gridManager.addWidget(beyondWidget))
    }
    
    // MARK: - Integration Tests
    
    func testFullWorkflow() {
        // Test complete workflow: add, move, remove
        
        // 1. Add multiple widgets
        let widget1 = ExampleWidget(title: "Widget 1", size: .small, category: .utilities)
        let widget2 = ExampleWidget(title: "Widget 2", size: .medium, category: .information)
        let widget3 = ExampleWidget(title: "Widget 3", size: .large, category: .productivity)
        
        XCTAssertTrue(gridManager.addWidget(widget1))
        XCTAssertTrue(gridManager.addWidget(widget2))
        XCTAssertTrue(gridManager.addWidget(widget3))
        XCTAssertEqual(gridManager.widgets.count, 3)
        
        // 2. Move widgets around
        XCTAssertTrue(gridManager.moveWidget(id: widget1.id, to: GridPosition(row: 5, column: 0)))
        XCTAssertTrue(gridManager.moveWidget(id: widget2.id, to: GridPosition(row: 5, column: 2)))
        
        // 3. Verify positions
        let movedWidget1 = gridManager.widgets.first { $0.id == widget1.id }
        XCTAssertEqual(movedWidget1?.position, GridPosition(row: 5, column: 0))
        
        // 4. Remove widgets
        XCTAssertTrue(gridManager.removeWidget(id: widget2.id))
        XCTAssertEqual(gridManager.widgets.count, 2)
        
        // 5. Clear all
        gridManager.removeAllWidgets()
        XCTAssertTrue(gridManager.widgets.isEmpty)
    }
}