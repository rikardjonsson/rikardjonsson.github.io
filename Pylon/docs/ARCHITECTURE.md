# Pylon Architecture Documentation

This document provides a comprehensive overview of Pylon's architecture, design decisions, and implementation patterns.

## Overview

Pylon is built as a modern macOS application using SwiftUI and Swift 6.0, designed for deep system integration and extensibility. The architecture emphasizes modularity, performance, and maintainability while providing a seamless user experience.

## Core Principles

### 1. Protocol-Oriented Design
Pylon uses protocols extensively to define clear interfaces and enable modularity:
- Widget protocol for extensible widget system
- Theme protocol for customizable appearance
- Service protocols for system integrations

### 2. Swift 6.0 Concurrency
Strict concurrency compliance ensures thread safety and performance:
- `@MainActor` for UI components
- `actor` types for background services
- `@unchecked Sendable` for system API bridges

### 3. Reactive UI
SwiftUI with `@Observable` provides reactive, declarative user interface:
- State changes automatically update UI
- Efficient diffing and rendering
- Accessibility built-in

### 4. Performance-First
Architecture optimized for macOS performance targets:
- Lazy loading and caching
- Background refresh scheduling
- Memory-efficient data structures

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│                    PylonApp                         │
│                 (SwiftUI App)                       │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                ContentView                          │
│              (Main Window)                          │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│               WidgetGrid                            │
│           (Layout Manager)                          │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│             WidgetManager                           │
│          (Widget Lifecycle)                         │
└─────────────────┬───────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼───┐   ┌───▼───┐   ┌───▼───┐
│Widget1│   │Widget2│   │Widget3│
│       │   │       │   │       │
└───┬───┘   └───┬───┘   └───┬───┘
    │           │           │
┌───▼───┐   ┌───▼───┐   ┌───▼───┐
│Service│   │Service│   │Service│
│  API  │   │  API  │   │  API  │
└───────┘   └───────┘   └───────┘
```

## Component Architecture

### App Layer

#### PylonApp
The main app entry point using SwiftUI App lifecycle:

```swift
@main
struct PylonApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var widgetManager = WidgetManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var menuBarManager = MenuBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(widgetManager)
                .environmentObject(themeManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
```

#### AppState
Global application state management:

```swift
@MainActor
@Observable
class AppState {
    var selectedTheme: Theme = .system
    var isKeyboardNavigationEnabled = true
    var widgetLayout: WidgetLayout = .grid
    var focusMode: FocusMode = .none
    var isMenuBarVisible = true
}
```

### Widget System

#### Widget Protocol
Core interface for all widgets:

```swift
protocol Widget: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var subtitle: String? { get }
    var isRefreshing: Bool { get }
    var lastUpdated: Date? { get }
    var refreshInterval: TimeInterval { get }
    var size: WidgetSize { get }
    
    @MainActor
    func refresh() async throws
    
    @MainActor
    func body() -> AnyView
    
    @MainActor
    func configure() -> AnyView?
}
```

#### WidgetManager
Centralized widget lifecycle management:

```swift
@MainActor
@Observable
class WidgetManager {
    private(set) var widgets: [any Widget] = []
    private(set) var refreshInProgress: Set<UUID> = []
    private var refreshTasks: [UUID: Task<Void, Never>] = [:]
    
    func registerWidget(_ widget: any Widget) {
        widgets.append(widget)
        scheduleRefresh(for: widget)
    }
    
    func refreshWidget(id: UUID) async {
        guard let widget = widgets.first(where: { $0.id == id }),
              !refreshInProgress.contains(id) else { return }
        
        refreshInProgress.insert(id)
        defer { refreshInProgress.remove(id) }
        
        do {
            try await widget.refresh()
        } catch {
            handleRefreshError(error, for: widget)
        }
    }
    
    private func scheduleRefresh(for widget: any Widget) {
        let task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(widget.refreshInterval))
                await refreshWidget(id: widget.id)
            }
        }
        refreshTasks[widget.id] = task
    }
}
```

### Layout System

#### WidgetGrid
Responsive grid layout with drag-and-drop:

```swift
struct WidgetGrid: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @State private var draggedWidget: (any Widget)?
    @State private var gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: 600), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(widgetManager.widgets, id: \.id) { widget in
                    WidgetContainer(widget: widget)
                        .draggable(widget) {
                            WidgetDragPreview(widget: widget)
                        }
                        .dropDestination(for: Widget.self) { widgets, location in
                            handleDrop(widgets: widgets, at: location)
                        }
                }
            }
            .padding()
        }
    }
}
```

#### WidgetContainer
Individual widget wrapper with chrome and interactions:

```swift
struct WidgetContainer: View {
    let widget: any Widget
    @State private var isHovered = false
    @State private var showConfiguration = false
    
    var body: some View {
        VStack(spacing: 0) {
            WidgetHeader(widget: widget, onConfigure: {
                showConfiguration = true
            })
            
            widget.body()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Material.ultraThin, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { isHovered = $0 }
        .sheet(isPresented: $showConfiguration) {
            widget.configure()
        }
    }
}
```

### Service Layer

#### EventKit Integration
Calendar and reminders service:

```swift
actor EventKitService: @unchecked Sendable {
    private let eventStore = EKEventStore()
    private var isAuthorized = false
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            isAuthorized = try await eventStore.requestFullAccessToEvents()
        case .fullAccess:
            isAuthorized = true
        default:
            throw ServiceError.permissionDenied
        }
    }
    
    func fetchTodaysEvents() async throws -> [EKEvent] {
        guard isAuthorized else {
            try await requestAccess()
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        return eventStore.events(matching: predicate)
    }
}
```

#### AppleScript Integration
Notes and Mail service:

```swift
actor AppleScriptService: @unchecked Sendable {
    func executeScript(_ script: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", script]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            
            process.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    continuation.resume(throwing: ServiceError.scriptFailed)
                }
            }
            
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func fetchRecentNotes(limit: Int = 10) async throws -> [Note] {
        let script = """
        tell application "Notes"
            set noteList to {}
            set noteCount to count of notes
            set endIndex to (noteCount min \(limit))
            
            repeat with i from 1 to endIndex
                set currentNote to note i
                set noteList to noteList & {
                    {name of currentNote, body of currentNote, creation date of currentNote}
                }
            end repeat
            
            return noteList
        end tell
        """
        
        let output = try await executeScript(script)
        return parseNotesOutput(output)
    }
}
```

### Theme System

#### Theme Protocol
Customizable appearance system:

```swift
protocol Theme: Identifiable, Codable {
    var id: String { get }
    var name: String { get }
    var backgroundStyle: BackgroundStyle { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var textColor: Color { get }
    var glassEffect: Material { get }
    var cornerRadius: CGFloat { get }
    var shadowColor: Color { get }
    var shadowRadius: CGFloat { get }
}
```

#### ThemeManager
Theme application and persistence:

```swift
@MainActor
@Observable
class ThemeManager {
    var currentTheme: Theme = GlassTheme()
    var availableThemes: [Theme] = [
        GlassTheme(),
        DarkTheme(),
        LightTheme(),
        MinimalTheme()
    ]
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    func loadTheme() {
        if let themeData = userDefaults.data(forKey: themeKey),
           let theme = try? JSONDecoder().decode(AnyTheme.self, from: themeData) {
            currentTheme = theme.theme
        }
    }
    
    func saveTheme() {
        if let themeData = try? JSONEncoder().encode(AnyTheme(currentTheme)) {
            userDefaults.set(themeData, forKey: themeKey)
        }
    }
    
    func applyTheme(_ theme: Theme) {
        currentTheme = theme
        saveTheme()
    }
}
```

### Performance Optimizations

#### Background Refresh
Efficient data updates using NSBackgroundActivityScheduler:

```swift
actor BackgroundRefreshManager {
    private var scheduledActivities: [String: NSBackgroundActivityScheduler] = [:]
    
    func scheduleRefresh(for widgetID: String, interval: TimeInterval) {
        let scheduler = NSBackgroundActivityScheduler(identifier: "com.pylon.refresh.\(widgetID)")
        
        scheduler.interval = interval
        scheduler.repeats = true
        scheduler.qualityOfService = .utility
        
        scheduler.schedule { completion in
            Task {
                await NotificationCenter.default.post(
                    name: .widgetRefreshRequested,
                    object: widgetID
                )
                completion(.finished)
            }
        }
        
        scheduledActivities[widgetID] = scheduler
    }
}
```

#### Caching System
TTL-based caching for widget data:

```swift
actor CacheManager {
    private var cache: [String: CacheEntry] = [:]
    private let defaultTTL: TimeInterval = 300 // 5 minutes
    
    struct CacheEntry {
        let data: Any
        let expiry: Date
    }
    
    func set<T>(_ value: T, forKey key: String, ttl: TimeInterval? = nil) {
        let expiry = Date().addingTimeInterval(ttl ?? defaultTTL)
        cache[key] = CacheEntry(data: value, expiry: expiry)
    }
    
    func get<T>(_ type: T.Type, forKey key: String) -> T? {
        guard let entry = cache[key],
              entry.expiry > Date(),
              let value = entry.data as? T else {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return value
    }
    
    func cleanup() {
        let now = Date()
        cache = cache.filter { $0.value.expiry > now }
    }
}
```

## Integration Patterns

### System Permissions
Graceful permission handling across all integrations:

```swift
enum PermissionState {
    case notDetermined
    case denied
    case granted
    case restricted
}

protocol PermissionManager {
    func requestPermission() async -> PermissionState
    func checkPermission() -> PermissionState
}

@MainActor
class PermissionCoordinator: ObservableObject {
    @Published var calendarPermission: PermissionState = .notDetermined
    @Published var locationPermission: PermissionState = .notDetermined
    @Published var notificationPermission: PermissionState = .notDetermined
    
    func requestAllPermissions() async {
        async let calendar = requestCalendarPermission()
        async let location = requestLocationPermission()
        async let notifications = requestNotificationPermission()
        
        calendarPermission = await calendar
        locationPermission = await location
        notificationPermission = await notifications
    }
}
```

### Error Handling
Consistent error handling across the application:

```swift
enum PylonError: LocalizedError, Identifiable {
    case permissionDenied(String)
    case networkUnavailable
    case dataCorrupted
    case serviceUnavailable(String)
    case scriptExecutionFailed(String)
    
    var id: String { localizedDescription }
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied(let service):
            return "Permission required to access \(service)"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .dataCorrupted:
            return "Data format is invalid"
        case .serviceUnavailable(let service):
            return "\(service) is currently unavailable"
        case .scriptExecutionFailed(let error):
            return "Script execution failed: \(error)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Grant permission in System Preferences"
        case .networkUnavailable:
            return "Check your internet connection"
        case .dataCorrupted:
            return "Try refreshing the data"
        case .serviceUnavailable:
            return "Try again later"
        case .scriptExecutionFailed:
            return "Restart the application"
        }
    }
}
```

## Testing Architecture

### Unit Testing Strategy
```swift
final class WidgetManagerTests: XCTestCase {
    @MainActor
    func testWidgetRegistration() {
        let manager = WidgetManager()
        let widget = MockWidget()
        
        manager.registerWidget(widget)
        
        XCTAssertEqual(manager.widgets.count, 1)
        XCTAssertEqual(manager.widgets.first?.id, widget.id)
    }
    
    @MainActor
    func testWidgetRefresh() async throws {
        let manager = WidgetManager()
        let widget = MockWidget()
        manager.registerWidget(widget)
        
        await manager.refreshWidget(id: widget.id)
        
        XCTAssertNotNil(widget.lastUpdated)
        XCTAssertFalse(widget.isRefreshing)
    }
}
```

### Performance Testing
```swift
final class PerformanceTests: XCTestCase {
    func testColdBootTime() {
        measure {
            // Simulate app launch
            let app = PylonApp()
            // Measure time to first render
        }
    }
    
    func testWidgetRefreshTime() async {
        let widget = CalendarWidget()
        
        await measure {
            try? await widget.refresh()
        }
    }
}
```

## Security Considerations

### Sandboxing
Pylon is designed for App Store distribution with appropriate entitlements:
- Calendar access for EventKit integration
- Automation access for AppleScript execution
- Network access for weather and RSS feeds
- Location access for weather data

### Privacy
- No user data is transmitted to external servers
- All data remains on the user's device
- Clear permission requests with explanations
- Minimal data collection for functionality

This architecture provides a solid foundation for Pylon's development while maintaining flexibility for future enhancements and extensions.