//
//  GridPerformanceOptimizer.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Performance optimizations
//

import SwiftUI
import Combine

/// Performance monitoring and optimization for the grid system
@MainActor
@Observable
class GridPerformanceOptimizer: Sendable {
    
    // MARK: - Performance Metrics
    
    struct PerformanceMetrics: Sendable {
        let renderTime: TimeInterval
        let widgetCount: Int
        let dragLatency: TimeInterval
        let memoryUsage: UInt64
        let timestamp: Date
        
        var formattedRenderTime: String {
            String(format: "%.1fms", renderTime * 1000)
        }
        
        var formattedDragLatency: String {
            String(format: "%.1fms", dragLatency * 1000)
        }
    }
    
    private(set) var currentMetrics: PerformanceMetrics?
    private(set) var isPerformanceMonitoringEnabled = true
    
    private var renderStartTime: CFTimeInterval = 0
    private var dragStartTime: CFTimeInterval = 0
    
    // MARK: - Optimization Settings
    
    /// Maximum widgets to render simultaneously
    private let maxConcurrentWidgets = 50
    
    /// Virtualization threshold (widgets off-screen)
    private let virtualizationThreshold: CGFloat = 200
    
    /// Animation reduction for performance
    private(set) var reducedAnimations = false
    
    // MARK: - Render Optimization
    
    /// Begin performance measurement for render cycle
    func beginRenderMeasurement() {
        guard isPerformanceMonitoringEnabled else { return }
        renderStartTime = CACurrentMediaTime()
    }
    
    /// End performance measurement for render cycle
    func endRenderMeasurement(widgetCount: Int) {
        guard isPerformanceMonitoringEnabled else { return }
        
        let renderTime = CACurrentMediaTime() - renderStartTime
        let memoryUsage = getMemoryUsage()
        
        currentMetrics = PerformanceMetrics(
            renderTime: renderTime,
            widgetCount: widgetCount,
            dragLatency: currentMetrics?.dragLatency ?? 0,
            memoryUsage: memoryUsage,
            timestamp: Date()
        )
        
        // Auto-adjust performance settings
        adjustPerformanceSettings()
    }
    
    /// Begin drag performance measurement
    func beginDragMeasurement() {
        guard isPerformanceMonitoringEnabled else { return }
        dragStartTime = CACurrentMediaTime()
    }
    
    /// End drag performance measurement
    func endDragMeasurement() {
        guard isPerformanceMonitoringEnabled else { return }
        
        let dragLatency = CACurrentMediaTime() - dragStartTime
        
        if let metrics = currentMetrics {
            currentMetrics = PerformanceMetrics(
                renderTime: metrics.renderTime,
                widgetCount: metrics.widgetCount,
                dragLatency: dragLatency,
                memoryUsage: metrics.memoryUsage,
                timestamp: Date()
            )
        }
    }
    
    // MARK: - Optimization Logic
    
    /// Determine if a widget should be virtualized (not rendered)
    func shouldVirtualizeWidget(at position: CGPoint, in scrollFrame: CGRect) -> Bool {
        let buffer = virtualizationThreshold
        let expandedFrame = scrollFrame.insetBy(dx: -buffer, dy: -buffer)
        return !expandedFrame.contains(position)
    }
    
    /// Get optimized animation duration based on performance
    func optimizedAnimationDuration(base: Double) -> Double {
        if reducedAnimations {
            return base * 0.5 // 50% faster animations
        }
        return base
    }
    
    /// Get optimized spring parameters for animations
    func optimizedSpringAnimation(response: Double = 0.5, dampingFraction: Double = 0.8) -> Animation {
        if reducedAnimations {
            return .easeInOut(duration: optimizedAnimationDuration(base: response))
        }
        return .spring(response: response, dampingFraction: dampingFraction)
    }
    
    /// Throttle expensive operations during drag
    func shouldThrottleOperation(during drag: Bool) -> Bool {
        return drag && reducedAnimations
    }
    
    // MARK: - Auto-Performance Adjustment
    
    private func adjustPerformanceSettings() {
        guard let metrics = currentMetrics else { return }
        
        // Enable reduced animations if render time is high
        let highRenderTime = metrics.renderTime > 0.016 // >16ms (60fps threshold)
        let highWidgetCount = metrics.widgetCount > 30
        
        reducedAnimations = highRenderTime || highWidgetCount
        
        if reducedAnimations {
            print("⚡ Performance mode enabled: \(metrics.formattedRenderTime) render time, \(metrics.widgetCount) widgets")
        }
    }
    
    // MARK: - Memory Management
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    // MARK: - Debug Information
    
    var performanceDebugInfo: String {
        guard let metrics = currentMetrics else {
            return "No performance data available"
        }
        
        return """
        Performance Metrics:
        • Render Time: \(metrics.formattedRenderTime)
        • Widget Count: \(metrics.widgetCount)
        • Drag Latency: \(metrics.formattedDragLatency)
        • Memory Usage: \(ByteCountFormatter.string(fromByteCount: Int64(metrics.memoryUsage), countStyle: .binary))
        • Reduced Animations: \(reducedAnimations ? "ON" : "OFF")
        • Last Updated: \(metrics.timestamp.formatted(date: .omitted, time: .standard))
        """
    }
}

/// Optimized ScrollView with virtualization
struct OptimizedGridScrollView<Content: View>: View {
    let content: () -> Content
    let optimizer: GridPerformanceOptimizer
    
    @State private var scrollFrame: CGRect = .zero
    @State private var contentOffset: CGPoint = .zero
    
    init(optimizer: GridPerformanceOptimizer, @ViewBuilder content: @escaping () -> Content) {
        self.optimizer = optimizer
        self.content = content
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            content()
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                scrollFrame = geometry.frame(in: .global)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                                scrollFrame = newFrame
                            }
                    }
                )
        }
        .animation(optimizer.optimizedSpringAnimation(), value: contentOffset)
    }
}

/// Performance-aware widget container
struct PerformanceOptimizedWidgetView<Content: View>: View {
    let content: () -> Content
    let optimizer: GridPerformanceOptimizer
    let widgetId: UUID
    let position: CGPoint
    
    @State private var isVisible = true
    
    var body: some View {
        Group {
            if isVisible {
                content()
                    .onAppear {
                        optimizer.beginRenderMeasurement()
                    }
                    .onDisappear {
                        // Widget is no longer visible
                    }
            } else {
                // Placeholder for virtualized widgets
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 100) // Approximate size
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didChangeScreenNotification)) { _ in
            // Recalculate visibility on screen changes
            checkVisibility()
        }
    }
    
    private func checkVisibility() {
        // This would be called with scroll frame updates
        // Implementation would check if widget is in visible bounds
    }
}

// MARK: - Performance Debug View

/// Debug overlay showing performance metrics
struct PerformanceDebugOverlay: View {
    let optimizer: GridPerformanceOptimizer
    let theme: any Theme
    
    @State private var showDebugInfo = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showDebugInfo.toggle()
                } label: {
                    Image(systemName: "speedometer")
                        .foregroundStyle(theme.accentColor)
                }
                .buttonStyle(.borderless)
            }
            
            Spacer()
            
            if showDebugInfo {
                debugInfoPanel
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding()
    }
    
    private var debugInfoPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Performance Monitor")
                .font(.headline)
                .foregroundStyle(theme.primaryColor)
            
            if let metrics = optimizer.currentMetrics {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Render:")
                        Spacer()
                        Text(metrics.formattedRenderTime)
                            .foregroundStyle(
                                metrics.renderTime > 0.016 ? .red : .green
                            )
                    }
                    
                    HStack {
                        Text("Widgets:")
                        Spacer()
                        Text("\(metrics.widgetCount)")
                    }
                    
                    HStack {
                        Text("Memory:")
                        Spacer()
                        Text(ByteCountFormatter.string(
                            fromByteCount: Int64(metrics.memoryUsage),
                            countStyle: .binary
                        ))
                    }
                    
                    if optimizer.reducedAnimations {
                        HStack {
                            Image(systemName: "speedometer")
                            Text("Performance Mode")
                        }
                        .foregroundStyle(.orange)
                    }
                }
                .font(.caption)
                .foregroundStyle(theme.secondaryColor)
            } else {
                Text("Collecting data...")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryColor)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .frame(width: 180)
    }
}