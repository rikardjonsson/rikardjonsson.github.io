//
//  PylonTests.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import XCTest
import SwiftUI
@testable import Pylon

final class PylonTests: XCTestCase {
    
    // MARK: - Theme System Tests
    
    func testThemeTypes() {
        let themes = ThemeType.allCases
        XCTAssertTrue(themes.contains(.nativeMacOS))
        XCTAssertTrue(themes.contains(.surveillance))
        XCTAssertTrue(themes.contains(.modern))
        XCTAssertTrue(themes.contains(.dark))
        XCTAssertTrue(themes.contains(.light))
        XCTAssertTrue(themes.contains(.system))
    }
    
    func testThemeProperties() {
        let nativeTheme = NativeMacOSTheme()
        XCTAssertEqual(nativeTheme.name, "Native macOS")
        XCTAssertEqual(nativeTheme.fluidCornerRadius, 12.0)
        
        let surveillanceTheme = SurveillanceTheme()
        XCTAssertEqual(surveillanceTheme.name, "SURVEILLANCE")
        XCTAssertEqual(surveillanceTheme.fluidCornerRadius, 8.0)
    }
    
    // MARK: - Widget Size Tests
    
    func testWidgetSizeProperties() {
        XCTAssertEqual(WidgetSize.small.displayName, "Small (1×1)")
        XCTAssertEqual(WidgetSize.medium.displayName, "Medium (2×2)")
        XCTAssertEqual(WidgetSize.large.displayName, "Large (4×2)")
        XCTAssertEqual(WidgetSize.xlarge.displayName, "Extra Large (4×4)")
        
        XCTAssertEqual(WidgetSize.small.cellCount, 1)
        XCTAssertEqual(WidgetSize.medium.cellCount, 4)
        XCTAssertEqual(WidgetSize.large.cellCount, 8)
        XCTAssertEqual(WidgetSize.xlarge.cellCount, 16)
    }
    
    func testWidgetSizeDimensions() {
        XCTAssertEqual(WidgetSize.small.gridDimensions.width, 1)
        XCTAssertEqual(WidgetSize.small.gridDimensions.height, 1)
        XCTAssertEqual(WidgetSize.medium.gridDimensions.width, 2)
        XCTAssertEqual(WidgetSize.medium.gridDimensions.height, 2)
        XCTAssertEqual(WidgetSize.large.gridDimensions.width, 4)
        XCTAssertEqual(WidgetSize.large.gridDimensions.height, 2)
    }
    
    // MARK: - Widget Category Tests
    
    func testWidgetCategories() {
        let categories = WidgetCategory.allCases
        XCTAssertTrue(categories.contains(.productivity))
        XCTAssertTrue(categories.contains(.information))
        XCTAssertTrue(categories.contains(.communication))
        XCTAssertTrue(categories.contains(.entertainment))
        XCTAssertTrue(categories.contains(.health))
        XCTAssertTrue(categories.contains(.system))
        
        XCTAssertEqual(WidgetCategory.productivity.iconName, "checklist")
        XCTAssertEqual(WidgetCategory.information.iconName, "info.circle")
        XCTAssertEqual(WidgetCategory.communication.iconName, "message")
    }
    
    // MARK: - Widget Layout Tests
    
    func testWidgetLayoutTypes() {
        let gridLayout = WidgetLayout.grid(columns: 3)
        let listLayout = WidgetLayout.list
        let masonryLayout = WidgetLayout.masonry
        
        XCTAssertEqual(gridLayout.displayName, "Grid (3 columns)")
        XCTAssertEqual(listLayout.displayName, "List")
        XCTAssertEqual(masonryLayout.displayName, "Masonry")
        
        let allCases = WidgetLayout.allCases
        XCTAssertEqual(allCases.count, 5) // 3 grid variants + list + masonry
    }
    
    // MARK: - Debug Configuration Tests
    
    func testDebugConfiguration() {
        // Test that debug configuration is properly set for testing
        XCTAssertTrue(DebugConfig.showCoordinateDebug)
        XCTAssertTrue(DebugConfig.showDragDebug)
        XCTAssertTrue(DebugConfig.showPlacementDebug)
        XCTAssertTrue(DebugConfig.showGridDebug)
    }
    
    // MARK: - Performance Tests
    
    func testThemeCreationPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = NativeMacOSTheme()
                let _ = SurveillanceTheme()
                let _ = ModernTheme()
            }
        }
    }
}
