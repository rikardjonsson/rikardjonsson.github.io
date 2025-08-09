//
//  GridSystemTests.swift
//  PylonTests
//
//  Created on 06.08.25.
//  Grid Layout System - Comprehensive test suite
//

import XCTest
import SwiftUI
@testable import Pylon

/// Comprehensive test suite for the current grid system
@MainActor
final class GridSystemTests: XCTestCase {
    
    var gridManager: GridManager!
    fileprivate var testWidget: TestGridWidget!
    
    override func setUp() async throws {
        try await super.setUp()
        gridManager = GridManager()
        testWidget = TestGridWidget()
    }
    
    override func tearDown() async throws {
        gridManager = nil
        testWidget = nil
        try await super.tearDown()
    }
    
    // MARK: - Core Grid Position Tests
    
    func testGridPositionBasics() {
        let position = GridPosition(row: 1, column: 2)
        XCTAssertEqual(position.row, 1)
        XCTAssertEqual(position.column, 2)
        XCTAssertEqual(GridPosition.zero.row, 0)
        XCTAssertEqual(GridPosition.zero.column, 0)
    }
    
    func testGridPositionEquality() {
        let pos1 = GridPosition(row: 1, column: 2)
        let pos2 = GridPosition(row: 1, column: 2)
        let pos3 = GridPosition(row: 2, column: 1)
        
        XCTAssertEqual(pos1, pos2)
        XCTAssertNotEqual(pos1, pos3)
    }
    
    // MARK: - Widget Size Tests
    
    func testWidgetSizeDimensions() {
        XCTAssertEqual(WidgetSize.small.gridDimensions.width, 1)
        XCTAssertEqual(WidgetSize.small.gridDimensions.height, 1)
        XCTAssertEqual(WidgetSize.medium.gridDimensions.width, 2)
        XCTAssertEqual(WidgetSize.medium.gridDimensions.height, 2)
        XCTAssertEqual(WidgetSize.large.gridDimensions.width, 4)
        XCTAssertEqual(WidgetSize.large.gridDimensions.height, 2)
        XCTAssertEqual(WidgetSize.xlarge.gridDimensions.width, 4)
        XCTAssertEqual(WidgetSize.xlarge.gridDimensions.height, 4)
    }
    
    func testWidgetSizeCellCount() {
        XCTAssertEqual(WidgetSize.small.cellCount, 1)
        XCTAssertEqual(WidgetSize.medium.cellCount, 4)
        XCTAssertEqual(WidgetSize.large.cellCount, 8)
        XCTAssertEqual(WidgetSize.xlarge.cellCount, 16)
    }
    
    func testWidgetSizeOccupiedCells() {
        let position = GridPosition(row: 1, column: 1)
        
        let smallCells = WidgetSize.small.occupiedCells(at: position)
        XCTAssertEqual(smallCells.count, 1)
        XCTAssertTrue(smallCells.contains(GridPosition(row: 1, column: 1)))
        
        let mediumCells = WidgetSize.medium.occupiedCells(at: position)
        XCTAssertEqual(mediumCells.count, 4)
        XCTAssertTrue(mediumCells.contains(GridPosition(row: 1, column: 1)))
        XCTAssertTrue(mediumCells.contains(GridPosition(row: 1, column: 2)))
        XCTAssertTrue(mediumCells.contains(GridPosition(row: 2, column: 1)))
        XCTAssertTrue(mediumCells.contains(GridPosition(row: 2, column: 2)))
    }
    
    func testWidgetSizeFrameCalculation() {
        let gridUnit: CGFloat = 100
        let spacing: CGFloat = 8
        
        let smallFrame = WidgetSize.small.frameSize(gridUnit: gridUnit, spacing: spacing)
        XCTAssertEqual(smallFrame.width, 100) // 1 * 100 + 0 * 8
        XCTAssertEqual(smallFrame.height, 100)
        
        let mediumFrame = WidgetSize.medium.frameSize(gridUnit: gridUnit, spacing: spacing)
        XCTAssertEqual(mediumFrame.width, 208) // 2 * 100 + 1 * 8
        XCTAssertEqual(mediumFrame.height, 208)
    }
    
    // MARK: - Grid Manager Tests
    
    func testGridManagerInitialization() {
        XCTAssertNotNil(gridManager)
        // GridManager is initialized correctly
    }
    
    func testGridManagerExists() {
        // Basic test to ensure GridManager can be created
        let manager = GridManager()
        XCTAssertNotNil(manager)
    }
    
    // MARK: - Widget Category Tests
    
    func testWidgetCategories() {
        let categories = WidgetCategory.allCases
        XCTAssertTrue(categories.contains(.productivity))
        XCTAssertTrue(categories.contains(.information))
        XCTAssertTrue(categories.contains(.system))
        XCTAssertTrue(categories.contains(.communication))
        XCTAssertTrue(categories.contains(.entertainment))
        XCTAssertTrue(categories.contains(.health))
        
        XCTAssertEqual(WidgetCategory.productivity.iconName, "checklist")
        XCTAssertEqual(WidgetCategory.information.iconName, "info.circle")
        XCTAssertEqual(WidgetCategory.system.iconName, "cpu")
    }
    
    // MARK: - Performance Tests
    
    func testWidgetSizePerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = WidgetSize.small.frameSize(gridUnit: 100, spacing: 8)
                let _ = WidgetSize.medium.frameSize(gridUnit: 100, spacing: 8)
                let _ = WidgetSize.large.frameSize(gridUnit: 100, spacing: 8)
                let _ = WidgetSize.xlarge.frameSize(gridUnit: 100, spacing: 8)
            }
        }
    }
}

// MARK: - Test Widget

fileprivate class TestGridWidget: WidgetContainer, @unchecked Sendable {
    let id = UUID()
    var size: WidgetSize = .medium
    var theme: WidgetThemeOverride? = nil
    var title: String = "Test Grid Widget"
    var category: WidgetCategory = .system
    var supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    var isEnabled: Bool = true
    var gridPosition: GridPosition = .zero
    var lastUpdated: Date? = nil
    var isLoading: Bool = false
    var error: Error? = nil
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate refresh work
        try await Task.sleep(nanoseconds: 1_000_000) // 0.001 seconds
        
        lastUpdated = Date()
        error = nil
    }
    
    func configure() -> AnyView {
        AnyView(Text("Test Grid Configuration"))
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.3))
                .overlay(
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.primary)
                )
        )
    }
}