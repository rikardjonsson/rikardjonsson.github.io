//
//  WidgetManagerTests.swift
//  PylonTests
//
//  Created on 09.08.25.
//  Comprehensive test suite for WidgetManager
//

import XCTest
import SwiftUI
@testable import Pylon

@MainActor
final class WidgetManagerTests: XCTestCase {
    
    var widgetManager: WidgetManager!
    fileprivate var testWidget: TestWidgetContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        widgetManager = WidgetManager()
        testWidget = TestWidgetContainer()
    }
    
    override func tearDown() async throws {
        widgetManager = nil
        testWidget = nil
        try await super.tearDown()
    }
    
    // MARK: - Container Management Tests
    
    func testRegisterContainer() {
        XCTAssertTrue(widgetManager.containers.isEmpty)
        
        widgetManager.registerContainer(testWidget)
        
        XCTAssertEqual(widgetManager.containers.count, 1)
        XCTAssertEqual(widgetManager.containers.first?.id, testWidget.id)
    }
    
    func testRegisterDuplicateContainer() {
        widgetManager.registerContainer(testWidget)
        let initialCount = widgetManager.containers.count
        
        // Try to register the same container again
        widgetManager.registerContainer(testWidget)
        
        XCTAssertEqual(widgetManager.containers.count, initialCount)
    }
    
    func testRemoveContainer() {
        widgetManager.registerContainer(testWidget)
        XCTAssertEqual(widgetManager.containers.count, 1)
        
        widgetManager.removeContainer(id: testWidget.id)
        
        XCTAssertTrue(widgetManager.containers.isEmpty)
    }
    
    func testRemoveAllContainers() {
        let widget1 = TestWidgetContainer()
        let widget2 = TestWidgetContainer()
        let widget3 = TestWidgetContainer()
        
        widgetManager.registerContainer(widget1)
        widgetManager.registerContainer(widget2)
        widgetManager.registerContainer(widget3)
        
        XCTAssertEqual(widgetManager.containers.count, 3)
        
        widgetManager.removeAllContainers()
        
        XCTAssertTrue(widgetManager.containers.isEmpty)
    }
    
    // MARK: - Container State Management Tests
    
    func testToggleContainerEnabled() {
        widgetManager.registerContainer(testWidget)
        let originalState = testWidget.isEnabled
        
        widgetManager.toggleContainerEnabled(id: testWidget.id)
        
        XCTAssertEqual(testWidget.isEnabled, !originalState)
        
        // Toggle back
        widgetManager.toggleContainerEnabled(id: testWidget.id)
        
        XCTAssertEqual(testWidget.isEnabled, originalState)
    }
    
    func testToggleNonExistentContainer() {
        let randomId = UUID()
        
        // Should not crash when toggling non-existent container
        widgetManager.toggleContainerEnabled(id: randomId)
        
        // No assertions needed - just ensuring no crash
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshSingleContainer() async {
        widgetManager.registerContainer(testWidget)
        
        let result = await widgetManager.refreshContainer(id: testWidget.id)
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.widgetId, testWidget.id)
        XCTAssertEqual(result.widgetTitle, testWidget.title)
        XCTAssertNil(result.error)
    }
    
    func testRefreshNonExistentContainer() async {
        let randomId = UUID()
        
        let result = await widgetManager.refreshContainer(id: randomId)
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.widgetId, randomId)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is WidgetError)
    }
    
    func testRefreshAllContainers() async {
        let widget1 = TestWidgetContainer()
        let widget2 = TestWidgetContainer()
        
        widgetManager.registerContainer(widget1)
        widgetManager.registerContainer(widget2)
        
        await widgetManager.refreshAllContainers()
        
        // Should complete without throwing
        XCTAssertTrue(widget1.isEnabled)
        XCTAssertTrue(widget2.isEnabled)
    }
    
    func testRefreshProgress() async {
        widgetManager.registerContainer(testWidget)
        
        XCTAssertFalse(widgetManager.isRefreshing(containerId: testWidget.id))
        
        // Start refresh asynchronously
        let refreshTask = Task {
            await widgetManager.refreshContainer(id: testWidget.id)
        }
        
        // Brief delay to allow refresh to start
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        await refreshTask.value
        
        // After completion, should not be refreshing
        XCTAssertFalse(widgetManager.isRefreshing(containerId: testWidget.id))
    }
    
    // MARK: - Error Handling Tests
    
    func testFailingWidgetRefresh() async {
        let failingWidget = FailingTestWidgetContainer()
        widgetManager.registerContainer(failingWidget)
        
        let result = await widgetManager.refreshContainer(id: failingWidget.id)
        
        XCTAssertFalse(result.success)
        XCTAssertNotNil(result.error)
    }
    
    func testRetryMechanism() async {
        let retryWidget = RetryTestWidgetContainer(failAttempts: 1)
        widgetManager.registerContainer(retryWidget)
        
        let result = await widgetManager.refreshContainer(id: retryWidget.id, maxRetries: 2)
        
        // Should succeed after retry
        XCTAssertTrue(result.success)
        XCTAssertEqual(retryWidget.attemptCount, 2)
    }
    
    // MARK: - Widget Error Tests
    
    func testWidgetErrorDescriptions() {
        XCTAssertNotNil(WidgetError.permissionDenied.errorDescription)
        XCTAssertNotNil(WidgetError.networkUnavailable.errorDescription)
        XCTAssertNotNil(WidgetError.dataCorrupted.errorDescription)
        XCTAssertNotNil(WidgetError.widgetNotFound.errorDescription)
        XCTAssertNotNil(WidgetError.widgetManagerDeallocated.errorDescription)
        XCTAssertNotNil(WidgetError.unknownRefreshError.errorDescription)
        
        let unknownError = NSError(domain: "TestDomain", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        XCTAssertNotNil(WidgetError.unknownError(unknownError).errorDescription)
    }
    
    // MARK: - Performance Tests
    
    func testManyContainersPerformance() {
        measure {
            for i in 0..<100 {
                let widget = TestWidgetContainer()
                widget.title = "Widget \(i)"
                self.widgetManager.registerContainer(widget)
            }
            self.widgetManager.removeAllContainers()
        }
    }
    
    func testRefreshManyContainersPerformance() async {
        // Add many containers
        for i in 0..<20 {
            let widget = TestWidgetContainer()
            widget.title = "Widget \(i)"
            widgetManager.registerContainer(widget)
        }
        
        do {
            try await measureAsync {
                await self.widgetManager.refreshAllContainers()
            }
        } catch {
            XCTFail("Performance test failed: \(error)")
        }
        
        widgetManager.removeAllContainers()
    }
    
    // MARK: - Filtering Tests
    
    func testContainerFiltering() {
        let productivityWidget = TestWidgetContainer()
        productivityWidget.category = .productivity
        
        let informationWidget = TestWidgetContainer()
        informationWidget.category = .information
        
        widgetManager.registerContainer(productivityWidget)
        widgetManager.registerContainer(informationWidget)
        
        let productivityContainers = widgetManager.containers(in: .productivity)
        let informationContainers = widgetManager.containers(in: .information)
        let systemContainers = widgetManager.containers(in: .system)
        
        XCTAssertEqual(productivityContainers.count, 1)
        XCTAssertEqual(informationContainers.count, 1)
        XCTAssertEqual(systemContainers.count, 0)
    }
}

// MARK: - Test Widget Containers

private class TestWidgetContainer: WidgetContainer, @unchecked Sendable {
    let id = UUID()
    var size: WidgetSize = .medium
    var theme: WidgetThemeOverride? = nil
    var title: String = "Test Widget"
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
        
        // Simulate some work
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        lastUpdated = Date()
        error = nil
    }
    
    func configure() -> AnyView {
        AnyView(Text("Test Configuration"))
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(Text("Test Widget Body"))
    }
}

fileprivate class FailingTestWidgetContainer: TestWidgetContainer, @unchecked Sendable {
    @MainActor
    override func refresh() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let testError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated test failure"])
        error = testError
        throw testError
    }
}

fileprivate class RetryTestWidgetContainer: TestWidgetContainer, @unchecked Sendable {
    private let failAttempts: Int
    private(set) var attemptCount: Int = 0
    
    init(failAttempts: Int) {
        self.failAttempts = failAttempts
        super.init()
    }
    
    @MainActor
    override func refresh() async throws {
        isLoading = true
        defer { isLoading = false }
        
        attemptCount += 1
        
        if attemptCount <= failAttempts {
            let testError = NSError(domain: "RetryTest", code: 500, userInfo: [NSLocalizedDescriptionKey: "Attempt \(attemptCount) failed"])
            error = testError
            throw testError
        }
        
        lastUpdated = Date()
        error = nil
    }
}

// MARK: - Async Test Helpers

extension XCTestCase {
    func measureAsync<T>(_ block: @escaping () async throws -> T) async rethrows {
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = try await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Basic performance assertion - adjust as needed
        XCTAssertLessThan(timeElapsed, 5.0, "Async operation took too long: \(timeElapsed)s")
    }
}