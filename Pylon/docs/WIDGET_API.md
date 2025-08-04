# Widget System API Reference

This document provides comprehensive API documentation for Pylon's container-based widget system, with practical examples and implementation guidance.

## 🧩 Widget Container Protocol

The `WidgetContainer` protocol is the foundation of Pylon's modular widget architecture.

### Protocol Definition

```swift
@MainActor
protocol WidgetContainer: Identifiable {
    // MARK: - Core Properties
    var id: UUID { get }
    var size: WidgetSize { get set }
    var theme: WidgetThemeOverride? { get set }
    var isEnabled: Bool { get set }
    var position: GridPosition { get set }
    
    // MARK: - Metadata
    var title: String { get }
    var category: WidgetCategory { get }
    var supportedSizes: [WidgetSize] { get }
    var lastUpdated: Date? { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    
    // MARK: - Lifecycle Methods
    func refresh() async throws
    func configure() -> AnyView
    
    // MARK: - Rendering
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView
}
```

### Properties Reference

#### Core Properties

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `id` | `UUID` | Unique identifier for the widget instance | ✅ |
| `size` | `WidgetSize` | Current size configuration (Small/Medium/Large/XLarge) | ✅ |
| `theme` | `WidgetThemeOverride?` | Custom theme overrides for this widget | ✅ |
| `isEnabled` | `Bool` | Whether the widget is visible in the dashboard | ✅ |
| `position` | `GridPosition` | Position in the grid layout system | ✅ |

#### Metadata Properties

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `title` | `String` | Display name for the widget | ✅ |
| `category` | `WidgetCategory` | Category for organization and filtering | ✅ |
| `supportedSizes` | `[WidgetSize]` | Array of sizes this widget supports | ✅ |
| `lastUpdated` | `Date?` | Timestamp of last successful data refresh | ✅ |
| `isLoading` | `Bool` | Whether the widget is currently refreshing data | ✅ |
| `error` | `Error?` | Current error state, if any | ✅ |

#### Lifecycle Methods

| Method | Description | Usage |
|--------|-------------|-------|
| `refresh() async throws` | Asynchronously refresh widget data | Called by widget manager or user action |
| `configure() -> AnyView` | Return configuration UI for widget settings | Called when user opens widget settings |
| `body(theme:gridUnit:spacing:) -> AnyView` | Render the widget UI with current theme and layout | Called by `WidgetContainerView` during render |

---

## 📐 Widget Sizing System

### WidgetSize Enumeration

```swift
enum WidgetSize: String, CaseIterable, Sendable, Codable {
    case small
    case medium  
    case large
    case xlarge
    
    var displayName: String { /* ... */ }
    var gridDimensions: (width: Int, height: Int) { /* ... */ }
    var recommendedContentHeight: CGFloat { /* ... */ }
}
```

### Size Specifications

| Size | Grid Units | Dimensions | Best For | Example Use Cases |
|------|------------|------------|----------|-------------------|
| **Small** | 1×1 | 120×120pt | Glanceable info | Current time, weather icon, unread count |
| **Medium** | 2×1 | 240×120pt | Compact lists | Upcoming events, quick stats, mini calendar |
| **Large** | 2×2 | 240×240pt | Rich content | Full calendar view, detailed weather, system graphs |
| **XLarge** | 4×2 | 480×240pt | Complex interfaces | Email inbox, file browser, multi-column layouts |

### Size-Adaptive Implementation Pattern

```swift
func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
    AnyView(
        Group {
            switch size {
            case .small:
                smallLayout(theme: theme)
            case .medium:
                mediumLayout(theme: theme)
            case .large:
                largeLayout(theme: theme)
            case .xlarge:
                xlargeLayout(theme: theme)
            }
        }
    )
}

private func smallLayout(theme: any Theme) -> some View {
    VStack(spacing: 4) {
        Image(systemName: "calendar")
            .font(.title2)
            .foregroundColor(theme.accentColor)
        
        Text("Today")
            .font(.caption)
            .foregroundColor(theme.textPrimary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private func mediumLayout(theme: any Theme) -> some View {
    HStack(spacing: 12) {
        Image(systemName: "calendar")
            .font(.title)
            .foregroundColor(theme.accentColor)
        
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's Events")
                .font(.headline)
                .foregroundColor(theme.textPrimary)
            
            Text("3 events")
                .font(.subheadline)
                .foregroundColor(theme.textSecondary)
        }
        
        Spacer()
    }
    .padding(.horizontal, 12)
}
```

---

## 🎨 Theme System Integration

### Theme Protocol

```swift
protocol Theme: Sendable {
    var name: String { get }
    var backgroundMaterial: Material { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var glassEffect: Material { get }
    var cardBackground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
}
```

### Widget Theme Overrides

```swift
struct WidgetThemeOverride: Sendable, Codable {
    let accentColor: String?      // Hex color string
    let backgroundOpacity: Double? // 0.0 - 1.0
    let cornerRadius: Double?     // Corner radius override
    
    init(accentColor: String? = nil, 
         backgroundOpacity: Double? = nil, 
         cornerRadius: Double? = nil) {
        self.accentColor = accentColor
        self.backgroundOpacity = backgroundOpacity  
        self.cornerRadius = cornerRadius
    }
}
```

### Using Themes in Widgets

```swift
// Apply theme colors
Text("Widget Title")
    .foregroundColor(theme.textPrimary)

// Use accent color for interactive elements
Button("Refresh") {
    // Action
}
.foregroundColor(theme.accentColor)

// Apply background materials
VStack {
    // Content
}
.background(theme.glassEffect, in: RoundedRectangle(cornerRadius: 12))

// Handle theme overrides
private var effectiveAccentColor: Color {
    if let colorString = container.theme?.accentColor {
        // Parse hex color string to Color
        return Color(hex: colorString) ?? theme.accentColor
    }
    return theme.accentColor
}
```

---

## 🏗️ Complete Widget Implementation Example

### Calendar Widget Implementation

```swift
import SwiftUI
import EventKit

@MainActor
final class CalendarWidget: WidgetContainer, ObservableObject {
    // MARK: - Core Properties
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    // MARK: - Widget Content
    @Published private var events: [EKEvent] = []
    @Published private var isRefreshing = false
    @Published private var lastError: Error?
    
    // MARK: - Dependencies
    private let eventStore = EKEventStore()
    
    // MARK: - Metadata
    let title = "Calendar"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    var lastUpdated: Date?
    var isLoading: Bool { isRefreshing }
    var error: Error? { lastError }
    
    // MARK: - Initialization
    init() {
        requestCalendarAccess()
    }
    
    // MARK: - Lifecycle Methods
    func refresh() async throws {
        isRefreshing = true
        lastError = nil
        defer { isRefreshing = false }
        
        // Check authorization
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .fullAccess else {
            throw WidgetError.permissionDenied
        }
        
        // Fetch today's events
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        events = eventStore.events(matching: predicate)
        lastUpdated = Date()
    }
    
    func configure() -> AnyView {
        AnyView(CalendarConfigurationView(widget: self))
    }
    
    // MARK: - Rendering
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                if isLoading {
                    loadingView(theme: theme)
                } else if let error = lastError {
                    errorView(error: error, theme: theme)
                } else {
                    contentView(theme: theme)
                }
            }
        )
    }
    
    // MARK: - Size-Specific Layouts
    private func contentView(theme: any Theme) -> some View {
        Group {
            switch size {
            case .small:
                smallLayout(theme: theme)
            case .medium:
                mediumLayout(theme: theme)
            case .large:
                largeLayout(theme: theme)
            case .xlarge:
                xlargeLayout(theme: theme)
            }
        }
    }
    
    private func smallLayout(theme: any Theme) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundColor(effectiveAccentColor(theme: theme))
            
            Text("\\(events.count)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(theme.textPrimary)
            
            Text("events")
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.title)
                .foregroundColor(effectiveAccentColor(theme: theme))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Events")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                if events.isEmpty {
                    Text("No events")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                } else {
                    Text("\\(events.count) events")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                    
                    if let nextEvent = events.first {
                        Text(nextEvent.title)
                            .font(.caption)
                            .foregroundColor(theme.textPrimary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(effectiveAccentColor(theme: theme))
                
                Text("Today's Events")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text("\\(events.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textSecondary)
            }
            
            Divider()
                .background(theme.textSecondary.opacity(0.3))
            
            // Events list
            if events.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.largeTitle)
                        .foregroundColor(theme.textSecondary)
                    
                    Text("No events today")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(events.prefix(5), id: \\.eventIdentifier) { event in
                            eventRow(event: event, theme: theme)
                        }
                    }
                }
            }
        }
        .padding(12)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        HStack(spacing: 16) {
            // Left column: Event list
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(effectiveAccentColor(theme: theme))
                    
                    Text("Today's Events")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                }
                
                if events.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.title)
                            .foregroundColor(theme.textSecondary)
                        
                        Text("No events today")
                            .font(.subheadline)
                            .foregroundColor(theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(events, id: \\.eventIdentifier) { event in
                                eventRow(event: event, theme: theme, detailed: true)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .background(theme.textSecondary.opacity(0.3))
            
            // Right column: Mini calendar or stats
            VStack(alignment: .leading, spacing: 12) {
                Text("This Week")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                // Mini calendar or weekly stats
                weeklyStatsView(theme: theme)
            }
            .frame(width: 140)
        }
        .padding(12)
    }
    
    // MARK: - Helper Views
    private func eventRow(event: EKEvent, theme: any Theme, detailed: Bool = false) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(event.calendar.cgColor))
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(detailed ? 2 : 1)
                
                if detailed || event.isAllDay {
                    Text(event.isAllDay ? "All day" : formatEventTime(event))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    private func loadingView(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("Loading events...")
                .font(.caption)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: Error, theme: any Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Calendar Error")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
            
            if let widgetError = error as? WidgetError {
                Text(widgetError.localizedDescription)
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }
    
    private func weeklyStatsView(theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(weeklyStats(), id: \\.day) { stat in
                HStack {
                    Text(stat.day)
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                        .frame(width: 20, alignment: .leading)
                    
                    Text("\\(stat.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func effectiveAccentColor(theme: any Theme) -> Color {
        if let colorString = self.theme?.accentColor {
            return Color(hex: colorString) ?? theme.accentColor
        }
        return theme.accentColor
    }
    
    private func requestCalendarAccess() {
        eventStore.requestFullAccessToEvents { granted, error in
            if !granted {
                // Handle permission denial
            }
        }
    }
    
    private func formatEventTime(_ event: EKEvent) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
    
    private func weeklyStats() -> [(day: String, count: Int)] {
        // Implementation for weekly event statistics
        return [
            ("Mon", 2), ("Tue", 1), ("Wed", 3),
            ("Thu", 0), ("Fri", 2), ("Sat", 1), ("Sun", 0)
        ]
    }
}

// MARK: - Configuration View
struct CalendarConfigurationView: View {
    @ObservedObject var widget: CalendarWidget
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Calendar Settings")
                .font(.headline)
            
            // Configuration options
            Toggle("Show All-Day Events", isOn: .constant(true))
            Toggle("Show Event Details", isOn: .constant(true))
            
            Button("Refresh Events") {
                Task {
                    try? await widget.refresh()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
```

---

## 🔧 Widget Registration & Management

### Registering Widgets

```swift
// In AppState or WidgetManager
func setupWidgets() {
    let calendarWidget = CalendarWidget()
    let weatherWidget = WeatherWidget()
    let systemWidget = SystemMonitorWidget()
    
    widgetManager.registerContainer(calendarWidget)
    widgetManager.registerContainer(weatherWidget)
    widgetManager.registerContainer(systemWidget)
}
```

### Widget Lifecycle Management

```swift
// Refresh all widgets
await widgetManager.refreshAllContainers()

// Refresh specific widget
await widgetManager.refreshContainer(id: widget.id)

// Update widget size
widgetManager.updateContainerSize(id: widget.id, newSize: .large)

// Toggle widget visibility
widgetManager.toggleContainerEnabled(id: widget.id)
```

---

## 🧪 Testing Widget Implementations

### Unit Testing Example

```swift
@testable import Pylon
import XCTest

final class CalendarWidgetTests: XCTestCase {
    var widget: CalendarWidget!
    
    override func setUp() {
        super.setUp()
        widget = CalendarWidget()
    }
    
    @MainActor
    func testWidgetInitialization() {
        XCTAssertEqual(widget.title, "Calendar")
        XCTAssertEqual(widget.category, .productivity)
        XCTAssertTrue(widget.supportedSizes.contains(.small))
        XCTAssertTrue(widget.supportedSizes.contains(.medium))
        XCTAssertTrue(widget.supportedSizes.contains(.large))
        XCTAssertTrue(widget.supportedSizes.contains(.xlarge))
    }
    
    @MainActor
    func testWidgetSizeConfiguration() {
        // Test size switching
        widget.size = .small
        XCTAssertEqual(widget.size, .small)
        
        widget.size = .large
        XCTAssertEqual(widget.size, .large)
    }
    
    @MainActor
    func testWidgetRefresh() async throws {
        // Test refresh functionality
        XCTAssertFalse(widget.isLoading)
        
        let refreshTask = Task {
            try await widget.refresh()
        }
        
        // Widget should be loading during refresh
        XCTAssertTrue(widget.isLoading)
        
        try await refreshTask.value
        
        // Widget should no longer be loading
        XCTAssertFalse(widget.isLoading)
        XCTAssertNotNil(widget.lastUpdated)
    }
    
    @MainActor
    func testThemeOverrides() {
        let override = WidgetThemeOverride(
            accentColor: "#FF6B6B",
            backgroundOpacity: 0.8,
            cornerRadius: 16.0
        )
        
        widget.theme = override
        
        XCTAssertEqual(widget.theme?.accentColor, "#FF6B6B")
        XCTAssertEqual(widget.theme?.backgroundOpacity, 0.8)
        XCTAssertEqual(widget.theme?.cornerRadius, 16.0)
    }
}
```

---

## 📚 Additional Resources

### Related Documentation
- **[Architecture Guide](ARCHITECTURE.md)** - Overall system design
- **[Development Setup](DEVELOPMENT.md)** - Development environment  
- **[Onboarding Guide](ONBOARDING.md)** - Getting started as a contributor
- **[Repository Structure](REPOSITORY_STRUCTURE.md)** - Project organization

### Apple Documentation
- **[SwiftUI](https://developer.apple.com/documentation/swiftui)** - UI framework reference
- **[EventKit](https://developer.apple.com/documentation/eventkit)** - Calendar and reminders
- **[WeatherKit](https://developer.apple.com/documentation/weatherkit)** - Weather data access
- **[Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)** - Async/await patterns

### Community Resources
- **[GitHub Issues](https://github.com/rikardjonsson/Pylon/issues)** - Bug reports and feature requests
- **[GitHub Discussions](https://github.com/rikardjonsson/Pylon/discussions)** - Community questions and ideas

---

**This API reference provides the foundation for creating robust, performant widgets that integrate seamlessly with Pylon's container architecture.** 🚀