# Development Workflows & Code Examples

This guide provides practical examples and tutorials for common development workflows in Pylon.

## 🚀 Quick Development Workflows

### Setting Up Your Development Environment

```bash
# 1. Clone and setup
git clone https://github.com/rikardjonsson/Pylon.git
cd Pylon

# 2. Install development tools
make install-tools

# 3. Verify everything works
make quality && make test

# 4. Create your feature branch
git checkout -b feature/my-widget-improvement
```

### Daily Development Cycle

```bash
# Morning routine - sync with latest changes
git checkout main
git pull origin main
git checkout feature/my-widget-improvement
git rebase main

# Development work
# ... make your changes ...

# Pre-commit quality check (run frequently)
make quality

# Before committing
make pre-commit

# Commit with descriptive message
git commit -m "Add: Calendar widget EventKit integration

- Implements full WidgetContainer protocol
- Supports all 4 size configurations
- Includes comprehensive error handling
- Adds unit tests with 90% coverage

Resolves #123"
```

---

## 🧩 Widget Development Workflows

### Creating a New Widget from Scratch

#### Step 1: Create Widget Structure
```bash
# Create widget directory
mkdir -p Sources/Widgets/MyWidget
cd Sources/Widgets/MyWidget
```

#### Step 2: Implement Basic Widget Container
```swift
// Sources/Widgets/MyWidget/MyWidget.swift
import SwiftUI

@MainActor
final class MyWidget: WidgetContainer, ObservableObject {
    // MARK: - Core Properties (Required by Protocol)
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    // MARK: - Metadata
    let title = "My Widget"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // MARK: - State Management
    @Published private var data: [String] = []
    @Published private var isRefreshing = false
    @Published private var lastError: Error?
    
    var lastUpdated: Date? = nil
    var isLoading: Bool { isRefreshing }
    var error: Error? { lastError }
    
    // MARK: - Lifecycle Methods
    func refresh() async throws {
        isRefreshing = true
        lastError = nil
        defer { isRefreshing = false }
        
        do {
            // Simulate data fetching
            try await Task.sleep(for: .milliseconds(500))
            
            await MainActor.run {
                self.data = ["Item 1", "Item 2", "Item 3"]
                self.lastUpdated = Date()
            }
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
    }
    
    func configure() -> AnyView {
        AnyView(MyWidgetConfigView(widget: self))
    }
    
    // MARK: - Size-Adaptive Rendering
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                if isRefreshing {
                    loadingView(theme: theme)
                } else if let error = lastError {
                    errorView(error: error, theme: theme)
                } else {
                    contentView(theme: theme)
                }
            }
        )
    }
    
    // MARK: - Layout Implementations
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
            Image(systemName: "star.fill")
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text("\(data.count)")
                .font(.headline)
                .foregroundColor(theme.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundColor(theme.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Text("\(data.count) items")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text("\(data.count)")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)
            }
            
            Divider()
                .background(theme.textSecondary.opacity(0.3))
            
            // Content
            if data.isEmpty {
                emptyStateView(theme: theme)
            } else {
                dataList(theme: theme)
            }
        }
        .padding(12)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        HStack(spacing: 16) {
            // Main content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(theme.accentColor)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                }
                
                if data.isEmpty {
                    emptyStateView(theme: theme)
                } else {
                    dataList(theme: theme, detailed: true)
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .background(theme.textSecondary.opacity(0.3))
            
            // Side panel
            VStack(alignment: .leading, spacing: 8) {
                Text("Stats")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                statsView(theme: theme)
            }
            .frame(width: 120)
        }
        .padding(12)
    }
    
    // MARK: - Helper Views
    private func loadingView(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("Loading...")
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
            
            Text("Error")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
            
            Text(error.localizedDescription)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }
    
    private func emptyStateView(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(theme.textSecondary)
            
            Text("No data available")
                .font(.subheadline)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func dataList(theme: any Theme, detailed: Bool = false) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 6) {
                ForEach(data.indices, id: \.self) { index in
                    dataRow(item: data[index], theme: theme, detailed: detailed)
                }
            }
        }
    }
    
    private func dataRow(item: String, theme: any Theme, detailed: Bool) -> some View {
        HStack {
            Circle()
                .fill(theme.accentColor)
                .frame(width: 6, height: 6)
            
            Text(item)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
                .lineLimit(detailed ? 2 : 1)
            
            Spacer()
        }
    }
    
    private func statsView(theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Total")
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                
                Spacer()
                
                Text("\(data.count)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
            }
        }
    }
}

// MARK: - Configuration View
struct MyWidgetConfigView: View {
    @ObservedObject var widget: MyWidget
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(widget.title) Settings")
                .font(.headline)
            
            Toggle("Enable Widget", isOn: $widget.isEnabled)
            
            Button("Refresh Data") {
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

#### Step 3: Register Your Widget
```swift
// In Sources/Models/AppState.swift or wherever widgets are registered
func setupWidgets() {
    let myWidget = MyWidget()
    widgetManager.registerContainer(myWidget)
    
    // Register other widgets...
}
```

#### Step 4: Create Tests
```swift
// Tests/PylonTests/MyWidgetTests.swift
@testable import Pylon
import XCTest

final class MyWidgetTests: XCTestCase {
    var widget: MyWidget!
    
    override func setUp() {
        super.setUp()
        widget = MyWidget()
    }
    
    @MainActor
    func testWidgetInitialization() {
        XCTAssertEqual(widget.title, "My Widget")
        XCTAssertEqual(widget.category, .productivity)
        XCTAssertTrue(widget.supportedSizes.contains(.small))
        XCTAssertTrue(widget.supportedSizes.contains(.medium))
        XCTAssertTrue(widget.supportedSizes.contains(.large))
        XCTAssertTrue(widget.supportedSizes.contains(.xlarge))
    }
    
    @MainActor
    func testRefreshCycle() async throws {
        XCTAssertFalse(widget.isLoading)
        XCTAssertNil(widget.lastUpdated)
        
        let refreshTask = Task {
            try await widget.refresh()
        }
        
        // Verify loading state
        XCTAssertTrue(widget.isLoading)
        
        try await refreshTask.value
        
        // Verify completion state
        XCTAssertFalse(widget.isLoading)
        XCTAssertNotNil(widget.lastUpdated)
        XCTAssertNil(widget.error)
    }
    
    @MainActor
    func testAllSizeConfigurations() {
        let theme = ModernTheme()
        
        for size in widget.supportedSizes {
            widget.size = size
            XCTAssertEqual(widget.size, size)
            
            // Verify body renders without crashing
            let view = widget.body(theme: theme, gridUnit: 120, spacing: 8)
            XCTAssertNotNil(view)
        }
    }
}
```

#### Step 5: Test and Verify
```bash
# Run tests
make test

# Check quality gates
make quality

# Build and test manually
swift run
```

---

## 🎨 Theme Integration Workflows

### Creating a Custom Theme

```swift
// Sources/Themes/MyCustomTheme.swift
import SwiftUI

struct MyCustomTheme: Theme {
    let name = "My Custom Theme"
    let backgroundMaterial = Material.regularMaterial
    let primaryColor = Color.purple
    let secondaryColor = Color.purple.opacity(0.6)
    let accentColor = Color.purple
    let glassEffect = Material.ultraThin
    let cardBackground = Color.clear
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
}

// Add to Theme extensions
extension Theme {
    static let myCustom = MyCustomTheme()
}
```

### Adding Theme Support to ThemeType Enum

```swift
// In Sources/Models/Theme.swift
enum ThemeType: String, CaseIterable, Sendable, Codable {
    case modern = "modern"
    case myCustom = "myCustom"
    
    var displayName: String {
        switch self {
        case .modern:
            return "Modern"
        case .myCustom:
            return "My Custom Theme"
        }
    }
    
    var theme: any Theme {
        switch self {
        case .modern:
            return ModernTheme()
        case .myCustom:
            return MyCustomTheme()
        }
    }
}
```

### Using Themes in Widgets

```swift
// In your widget's body method
func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
    AnyView(
        VStack {
            Text("My Widget")
                .foregroundColor(theme.textPrimary) // Use theme colors
            
            Rectangle()
                .fill(theme.accentColor) // Theme accent color
                .frame(height: 2)
        }
        .background(theme.cardBackground) // Theme background
    )
}
```

---

## 🔧 System Integration Workflows

### EventKit Integration Example

```swift
// Sources/Services/EventKitService.swift
import EventKit
import Foundation

actor EventKitService {
    private let eventStore = EKEventStore()
    private var isAuthorized = false
    
    func requestAccess() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            eventStore.requestFullAccessToEvents { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    self.isAuthorized = granted
                    if granted {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: WidgetError.permissionDenied("Calendar"))
                    }
                }
            }
        }
    }
    
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [EKEvent] {
        guard isAuthorized else {
            try await requestAccess()
        }
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )
        
        return eventStore.events(matching: predicate)
    }
}

// Usage in a widget
@MainActor
final class CalendarWidget: WidgetContainer, ObservableObject {
    private let eventService = EventKitService()
    @Published private var events: [EKEvent] = []
    
    func refresh() async throws {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let fetchedEvents = try await eventService.fetchEvents(from: today, to: tomorrow)
        
        await MainActor.run {
            self.events = fetchedEvents
            self.lastUpdated = Date()
        }
    }
}
```

### AppleScript Integration Example

```swift
// Sources/Services/AppleScriptService.swift
import Foundation

actor AppleScriptService {
    func executeScript(_ script: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                let pipe = Pipe()
                
                process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
                process.arguments = ["-e", script]
                process.standardOutput = pipe
                process.standardError = pipe
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    
                    if process.terminationStatus == 0 {
                        continuation.resume(returning: output)
                    } else {
                        continuation.resume(throwing: WidgetError.systemIntegrationFailed("AppleScript"))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getUnreadEmailCount() async throws -> Int {
        let script = """
        tell application "Mail"
            set unreadCount to unread count of inbox
            return unreadCount
        end tell
        """
        
        let result = try await executeScript(script)
        return Int(result.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }
}
```

---

## 📊 Performance Optimization Workflows

### Memory Management

```swift
// Proper memory management in widgets
@MainActor
final class PerformantWidget: WidgetContainer, ObservableObject {
    // Use weak references to avoid retain cycles
    private weak var delegate: WidgetDelegate?
    
    // Limit cache size
    private var cache: LRUCache<String, Data> = LRUCache(capacity: 50)
    
    // Cancel ongoing tasks when deinitialized
    private var refreshTask: Task<Void, Never>?
    
    deinit {
        refreshTask?.cancel()
    }
    
    func refresh() async throws {
        // Cancel previous refresh to avoid overlapping operations
        refreshTask?.cancel()
        
        refreshTask = Task {
            // Actual refresh implementation
        }
        
        try await refreshTask?.value
    }
}

// Simple LRU Cache implementation
class LRUCache<Key: Hashable, Value> {
    private let capacity: Int
    private var cache: [Key: Value] = [:]
    private var order: [Key] = []
    
    init(capacity: Int) {
        self.capacity = capacity
    }
    
    func get(_ key: Key) -> Value? {
        guard let value = cache[key] else { return nil }
        
        // Move to end (most recently used)
        order.removeAll { $0 == key }
        order.append(key)
        
        return value
    }
    
    func set(_ key: Key, _ value: Value) {
        if cache[key] != nil {
            // Update existing
            cache[key] = value
            order.removeAll { $0 == key }
            order.append(key)
        } else {
            // Add new
            if cache.count >= capacity {
                // Remove least recently used
                let lru = order.removeFirst()
                cache.removeValue(forKey: lru)
            }
            
            cache[key] = value
            order.append(key)
        }
    }
}
```

### Background Processing

```swift
// Efficient background processing
actor BackgroundProcessor {
    private let scheduler = TaskScheduler()
    
    func scheduleWidgetRefresh(for widgets: [any WidgetContainer]) async {
        // Group widgets by refresh priority
        let highPriority = widgets.filter { $0.category == .system }
        let normalPriority = widgets.filter { $0.category != .system }
        
        // Process high priority widgets first
        await processWidgets(highPriority, priority: .high)
        
        // Process normal priority widgets with delay
        try? await Task.sleep(for: .milliseconds(100))
        await processWidgets(normalPriority, priority: .utility)
    }
    
    private func processWidgets(_ widgets: [any WidgetContainer], priority: TaskPriority) async {
        await withTaskGroup(of: Void.self) { group in
            for widget in widgets {
                group.addTask(priority: priority) {
                    try? await widget.refresh()
                }
            }
        }
    }
}
```

---

## 🧪 Testing Workflows

### Test-Driven Development Workflow

```bash
# 1. Write failing test first
# Tests/PylonTests/MyWidgetTests.swift

# 2. Run tests to see failure
make test

# 3. Implement minimum code to pass test
# Sources/Widgets/MyWidget/MyWidget.swift

# 4. Run tests again
make test

# 5. Refactor while keeping tests green
# Improve implementation

# 6. Final verification
make quality && make test
```

### Mock System Dependencies

```swift
// Tests/PylonTests/Mocks/MockEventStore.swift
@testable import Pylon
import EventKit

class MockEventStore: EKEventStore {
    var shouldGrantAccess = true
    var mockEvents: [EKEvent] = []
    var shouldFail = false
    
    override func requestFullAccessToEvents(completion: @escaping (Bool, Error?) -> Void) {
        DispatchQueue.main.async {
            if self.shouldFail {
                completion(false, WidgetError.permissionDenied("Calendar"))
            } else {
                completion(self.shouldGrantAccess, nil)
            }
        }
    }
    
    override func events(matching predicate: NSPredicate) -> [EKEvent] {
        if shouldFail {
            return []
        }
        return mockEvents
    }
}

// Usage in tests
final class CalendarWidgetTests: XCTestCase {
    var widget: CalendarWidget!
    var mockEventStore: MockEventStore!
    
    override func setUp() {
        super.setUp()
        mockEventStore = MockEventStore()
        widget = CalendarWidget(eventStore: mockEventStore)
    }
    
    @MainActor
    func testSuccessfulRefresh() async throws {
        // Setup mock data
        mockEventStore.mockEvents = [createMockEvent()]
        mockEventStore.shouldGrantAccess = true
        
        try await widget.refresh()
        
        XCTAssertFalse(widget.isLoading)
        XCTAssertNotNil(widget.lastUpdated)
        XCTAssertNil(widget.error)
    }
    
    @MainActor
    func testPermissionDenied() async {
        mockEventStore.shouldGrantAccess = false
        
        do {
            try await widget.refresh()
            XCTFail("Expected permission error")
        } catch {
            XCTAssertTrue(error is WidgetError)
            XCTAssertNotNil(widget.error)
        }
    }
}
```

---

## 🔄 Git Workflow Patterns

### Feature Branch Workflow

```bash
# Start new feature
git checkout main
git pull origin main
git checkout -b feature/calendar-widget-improvements

# Make changes with frequent commits
git add Sources/Widgets/Calendar/
git commit -m "Add: EventKit permission handling

- Implements graceful permission request flow
- Adds error state for permission denied
- Updates configuration UI with permissions info

Part of #123"

# Continue development
# ... more commits ...

# Before pushing, ensure quality
make pre-commit

# Push feature branch
git push -u origin feature/calendar-widget-improvements

# Create pull request via GitHub UI or CLI
gh pr create --title "Add: Calendar widget EventKit integration" --body "$(cat <<'EOF'
## Summary
Implements full EventKit integration for Calendar widget with proper permission
handling and error states.

## Related Issues
Resolves #123

## Testing
- [ ] Unit tests pass
- [ ] Manual testing with permissions granted/denied
- [ ] All widget sizes render correctly
EOF
)"
```

### Hotfix Workflow

```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/widget-crash-on-size-change

# Fix the issue
git add Sources/Models/WidgetSize.swift
git commit -m "Fix: Widget crash when changing sizes

- Add bounds checking in size change handler
- Prevent invalid size transitions
- Add defensive programming in layout switch

Fixes #456"

# Test the fix
make pre-commit

# Push and create PR
git push -u origin hotfix/widget-crash-on-size-change
gh pr create --title "Fix: Widget crash on size change" --body "Emergency fix for widget crash reported in #456"
```

---

## 📚 Documentation Workflows

### API Documentation

```swift
/// Fetches calendar events from EventKit with proper error handling
/// 
/// This method requires calendar access permissions and will throw
/// `WidgetError.permissionDenied` if access is not granted.
/// 
/// ## Usage
/// ```swift
/// let events = try await fetchEvents(from: startDate, to: endDate)
/// ```
/// 
/// ## Performance Notes
/// - Results are cached for 5 minutes to reduce EventKit calls
/// - Maximum 100 events returned to prevent memory issues
/// - Background thread execution to avoid UI blocking
/// 
/// - Parameters:
///   - startDate: Beginning of the date range
///   - endDate: End of the date range
/// - Returns: Array of events sorted by start date
/// - Throws: `WidgetError` if permissions denied or data unavailable
@MainActor
func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [EKEvent] {
    // Implementation
}
```

### README Updates

```bash
# When adding new features, update README
# Add to feature list, update roadmap, include examples

# Example commit for README updates
git add README.md
git commit -m "Docs: Update README with Calendar widget features

- Add EventKit integration to features list
- Update performance targets with actual metrics
- Include Calendar widget in quick start example
- Move Calendar widget from planned to completed in roadmap"
```

---

## 🎯 Common Problem-Solving Patterns

### Debugging Concurrency Issues

```swift
// Use this pattern to debug concurrency violations
func debugConcurrencyIssue() {
    // Add explicit MainActor annotations
    @MainActor
    func updateUI() {
        // UI updates here
    }
    
    // Use Task to bridge async contexts
    Task { @MainActor in
        updateUI()
    }
    
    // Check actor isolation in console
    #if DEBUG
    print("Current actor: \\(Thread.isMainThread ? "MainActor" : "Background")")
    #endif
}
```

### Performance Profiling Workflow

```bash
# Build for profiling
swift build -c release

# Use Instruments for profiling
# 1. Open Instruments
# 2. Choose Time Profiler or Allocations
# 3. Target your built Pylon binary
# 4. Look for hot paths and memory leaks

# Fix issues and re-profile
# Measure before/after performance
```

### Handling System Integration Failures

```swift
// Robust error handling pattern
func handleSystemIntegration() async {
    do {
        let result = try await systemService.fetchData()
        await updateUI(with: result)
    } catch let error as WidgetError {
        // Handle known widget errors
        await showError(error)
    } catch {
        // Handle unexpected errors
        await showError(WidgetError.systemIntegrationFailed("Unknown system error"))
    }
}

@MainActor
func showError(_ error: WidgetError) {
    self.lastError = error
    
    // Log for debugging
    #if DEBUG
    print("Widget error: \\(error.localizedDescription)")
    if let recovery = error.recoverySuggestion {
        print("Recovery: \\(recovery)")
    }
    #endif
}
```

---

## 🚀 Deployment & Release Workflows

### Pre-Release Checklist

```bash
# 1. Final quality check
make pre-commit

# 2. Run full test suite
make test

# 3. Performance verification
# Run performance tests and validate targets

# 4. Documentation review
# Ensure all docs are up to date

# 5. Version bump
# Update version numbers in Package.swift

# 6. Create release branch
git checkout -b release/v0.2.0

# 7. Final testing
# Manual testing of all features

# 8. Tag release
git tag -a v0.2.0 -m "Release v0.2.0: Calendar and System Monitor widgets"

# 9. Push release
git push origin release/v0.2.0
git push origin v0.2.0
```

---

This comprehensive guide covers the most common development workflows in Pylon. For additional help, see the [Troubleshooting Guide](TROUBLESHOOTING.md) or ask in [GitHub Discussions](https://github.com/rikardjonsson/Pylon/discussions).