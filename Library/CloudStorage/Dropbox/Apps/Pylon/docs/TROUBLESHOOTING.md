# Troubleshooting Guide

This guide helps you diagnose and resolve common issues when developing with Pylon.

## 🚨 Quick Diagnostics

### Health Check Commands
```bash
# Check project health
make build          # Does the project build?
make test           # Do tests pass?
make quality        # Are there linting issues?
swift --version     # Swift 6.0 installed?
xcodebuild -version # Xcode 16+ installed?
```

### Common Fix Commands
```bash
# Reset development environment
make clean && make build

# Fix formatting and style issues
make lint-fix && make format

# Remove and reinstall development tools
brew uninstall swiftlint swiftformat
make install-tools
```

---

## 🏗️ Build Issues

### "No such module 'Pylon'"

**Problem**: Import statements fail or module not found errors.

**Symptoms**:
```
error: no such module 'Pylon'
Cannot find 'AppState' in scope
```

**Solutions**:
1. **Check Package.swift target configuration**:
   ```swift
   // Ensure target name matches
   .executableTarget(
       name: "Pylon",  // Must match import name
       path: "Sources"
   )
   ```

2. **Verify file location**:
   ```bash
   # Files should be in Sources/ directory
   ls Sources/
   # Should show: PylonApp.swift, Models/, Views/, etc.
   ```

3. **Clean and rebuild**:
   ```bash
   make clean
   swift build
   ```

### "Cannot find swift-tools-version"

**Problem**: Package.swift version mismatch.

**Symptoms**:
```
error: package at '/path/to/Pylon' requires a minimum Swift tools version of 6.0
```

**Solutions**:
1. **Update Xcode**: Ensure Xcode 16+ is installed
2. **Select correct Xcode**:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app
   ```
3. **Verify Swift version**:
   ```bash
   swift --version
   # Should show: Swift version 6.0 or later
   ```

### "Strict concurrency checking failed"

**Problem**: Swift 6.0 concurrency violations.

**Symptoms**:
```
error: sending 'self' risks causing data races
warning: capture of 'self' with non-sendable type
```

**Solutions**:
1. **Add @MainActor to UI classes**:
   ```swift
   @MainActor
   class MyWidget: WidgetContainer, ObservableObject {
       // Implementation
   }
   ```

2. **Use weak self in closures**:
   ```swift
   group.addTask { [weak self] in
       await self?.refresh()
   }
   ```

3. **Make types Sendable**:
   ```swift
   struct MyData: Sendable {
       let value: String
   }
   ```

---

## 🔧 Development Tool Issues

### SwiftLint Not Working

**Problem**: SwiftLint commands fail or produce no output.

**Symptoms**:
```bash
make lint
# No output or "command not found"
```

**Solutions**:
1. **Reinstall SwiftLint**:
   ```bash
   brew uninstall swiftlint
   brew install swiftlint
   ```

2. **Check installation**:
   ```bash
   which swiftlint
   swiftlint version
   ```

3. **Verify configuration**:
   ```bash
   # Check .swiftlint.yml exists and is valid
   ls -la .swiftlint.yml
   swiftlint lint --config .swiftlint.yml --strict
   ```

4. **PATH issues**:
   ```bash
   # Add Homebrew to PATH
   export PATH="/opt/homebrew/bin:$PATH"
   # Or for Intel Macs:
   export PATH="/usr/local/bin:$PATH"
   ```

### SwiftFormat Not Formatting

**Problem**: Code doesn't get formatted when running `make format`.

**Symptoms**:
- No changes applied to files
- "0 files formatted" message

**Solutions**:
1. **Check SwiftFormat installation**:
   ```bash
   which swiftformat
   swiftformat --version
   ```

2. **Verify configuration**:
   ```bash
   # Test configuration
   swiftformat --config .swiftformat --lint Sources/
   ```

3. **Manual formatting test**:
   ```bash
   # Test on specific file
   swiftformat Sources/PylonApp.swift --config .swiftformat
   ```

4. **Check file permissions**:
   ```bash
   # Ensure files are writable
   ls -la Sources/
   chmod u+w Sources/*.swift
   ```

### Pre-commit Hook Not Running

**Problem**: Quality checks don't run automatically on commit.

**Symptoms**:
- Commits succeed with linting errors
- Hook script not executed

**Solutions**:
1. **Verify hook exists and is executable**:
   ```bash
   ls -la .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

2. **Check hook content**:
   ```bash
   head -n 5 .git/hooks/pre-commit
   # Should start with #!/bin/bash
   ```

3. **Test hook manually**:
   ```bash
   .git/hooks/pre-commit
   ```

4. **Bypass hook temporarily** (if needed):
   ```bash
   git commit --no-verify -m "Emergency commit"
   ```

---

## 🎨 Widget Development Issues

### Widget Not Appearing

**Problem**: Custom widget doesn't show in the dashboard.

**Symptoms**:
- Widget created but not visible
- No errors in console

**Solutions**:
1. **Check widget registration**:
   ```swift
   // In AppState.init() or setupWidgets()
   widgetManager.registerContainer(MyWidget())
   ```

2. **Verify widget is enabled**:
   ```swift
   // Check isEnabled property
   var isEnabled: Bool = true  // Should be true
   ```

3. **Check supported sizes**:
   ```swift
   let supportedSizes: [WidgetSize] = [.small, .medium, .large]
   // Must include at least one size
   ```

4. **Debug widget manager**:
   ```swift
   print("Registered widgets: \\(widgetManager.containers.count)")
   print("Enabled widgets: \\(widgetManager.enabledContainers().count)")
   ```

### Widget Crashes on Size Change

**Problem**: App crashes when changing widget size.

**Symptoms**:
```
Fatal error: Index out of range
EXC_BAD_ACCESS when switching sizes
```

**Solutions**:
1. **Handle all supported sizes**:
   ```swift
   func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
       AnyView(
           Group {
               switch size {
               case .small: smallLayout()
               case .medium: mediumLayout()
               case .large: largeLayout()
               case .xlarge: xlargeLayout()
               }
           }
       )
   }
   ```

2. **Check size support**:
   ```swift
   let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
   // Include all sizes you handle in body()
   ```

3. **Add size validation**:
   ```swift
   func updateSize(_ newSize: WidgetSize) {
       guard supportedSizes.contains(newSize) else { return }
       size = newSize
   }
   ```

### Widget Data Not Refreshing

**Problem**: Widget shows stale data or doesn't update.

**Symptoms**:
- `lastUpdated` timestamp doesn't change
- UI shows old information

**Solutions**:
1. **Check refresh implementation**:
   ```swift
   func refresh() async throws {
       // Update lastUpdated
       lastUpdated = Date()
       
       // Fetch new data
       let newData = try await fetchData()
       
       // Update published properties
       await MainActor.run {
           self.data = newData
       }
   }
   ```

2. **Verify async/await usage**:
   ```swift
   // Ensure refresh is called with await
   try await widget.refresh()
   ```

3. **Check main actor isolation**:
   ```swift
   @MainActor
   func refresh() async throws {
       // UI updates automatically happen on main thread
       self.data = newData
   }
   ```

---

## 🌐 Integration Issues

### EventKit Permission Denied

**Problem**: Calendar widget can't access calendar data.

**Symptoms**:
```
Calendar Error: Permission denied
EKEventStore authorization failed
```

**Solutions**:
1. **Request permissions properly**:
   ```swift
   private func requestCalendarAccess() {
       eventStore.requestFullAccessToEvents { granted, error in
           DispatchQueue.main.async {
               if granted {
                   // Refresh widget data
               } else {
                   // Handle permission denial
               }
           }
       }
   }
   ```

2. **Check system preferences**:
   - Go to System Preferences > Privacy & Security > Calendar
   - Ensure your app has permission

3. **Handle permission states**:
   ```swift
   func refresh() async throws {
       let status = EKEventStore.authorizationStatus(for: .event)
       
       switch status {
       case .notDetermined:
           // Request permission
       case .denied, .restricted:
           throw WidgetError.permissionDenied
       case .fullAccess:
           // Proceed with data fetch
       @unknown default:
           throw WidgetError.unknownError
       }
   }
   ```

### AppleScript Execution Failed

**Problem**: Notes/Mail integration via AppleScript doesn't work.

**Symptoms**:
```
AppleScript error: Application not found
Process execution failed
```

**Solutions**:
1. **Check automation permissions**:
   - System Preferences > Privacy & Security > Automation
   - Grant permission for your app to control other apps

2. **Verify target application**:
   ```swift
   let script = """
   tell application "Notes"
       -- Check if Notes is running
       if not (exists (processes whose name is "Notes")) then
           launch application "Notes"
           delay 1
       end if
       -- Rest of script
   end tell
   """
   ```

3. **Add error handling**:
   ```swift
   func executeAppleScript(_ script: String) async throws -> String {
       let process = Process()
       process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
       process.arguments = ["-e", script]
       
       let pipe = Pipe()
       process.standardOutput = pipe
       process.standardError = pipe
       
       try process.run()
       process.waitUntilExit()
       
       guard process.terminationStatus == 0 else {
           throw AppleScriptError.executionFailed
       }
       
       let data = pipe.fileHandleForReading.readDataToEndOfFile()
       return String(data: data, encoding: .utf8) ?? ""
   }
   ```

### WeatherKit Not Working

**Problem**: Weather widget shows no data or authentication errors.

**Symptoms**:
```
WeatherKit error: Invalid credentials
Weather data unavailable
```

**Solutions**:
1. **Verify Apple Developer Account**:
   - Ensure you have an active Apple Developer Program membership
   - WeatherKit requires paid developer account

2. **Check bundle identifier**:
   ```swift
   // Ensure bundle ID matches developer account
   // Configure in Package.swift or Xcode project settings
   ```

3. **Add WeatherKit capability**:
   - In Xcode: Signing & Capabilities > + Capability > WeatherKit

4. **Handle location permissions**:
   ```swift
   import CoreLocation
   
   func requestLocationPermission() {
       locationManager.requestWhenInUseAuthorization()
   }
   ```

---

## 🚀 Performance Issues

### App Slow to Launch

**Problem**: Cold boot time exceeds 2-second target.

**Symptoms**:
- Long delay before UI appears
- Spinning wheel on launch

**Solutions**:
1. **Profile with Instruments**:
   - Use Time Profiler to identify bottlenecks
   - Look for synchronous work on main thread

2. **Optimize widget initialization**:
   ```swift
   // Move heavy work to background
   func setupWidgets() {
       Task.detached(priority: .background) {
           // Heavy initialization work
           await self.initializeWidgets()
       }
   }
   ```

3. **Lazy load widgets**:
   ```swift
   // Register widgets without immediate data loading
   let widget = CalendarWidget()
   // Data loading happens on first refresh
   ```

### High Memory Usage

**Problem**: App exceeds 100MB memory target.

**Symptoms**:
- Activity Monitor shows high memory usage
- System memory pressure

**Solutions**:
1. **Profile with Instruments**:
   - Use Allocations instrument
   - Look for memory leaks and excessive allocations

2. **Implement data caching limits**:
   ```swift
   class DataCache {
       private var cache: [String: Any] = [:]
       private let maxEntries = 100
       
       func setValue(_ value: Any, forKey key: String) {
           if cache.count >= maxEntries {
               // Remove oldest entries
               cache.removeFirst(cache.count - maxEntries + 1)
           }
           cache[key] = value
       }
   }
   ```

3. **Use weak references**:
   ```swift
   // Avoid retain cycles
   widget.onUpdate = { [weak self] in
       self?.handleUpdate()
   }
   ```

### Excessive CPU Usage

**Problem**: App uses more than 5% CPU when idle.

**Symptoms**:
- Activity Monitor shows high CPU
- MacBook gets warm/fan spins up

**Solutions**:
1. **Profile with Instruments**:
   - Use CPU Profiler
   - Identify expensive operations

2. **Optimize refresh intervals**:
   ```swift
   // Use NSBackgroundActivityScheduler for efficient background work
   let scheduler = NSBackgroundActivityScheduler(identifier: "widget-refresh")
   scheduler.interval = 300 // 5 minutes
   scheduler.tolerance = 60  // 1 minute tolerance
   ```

3. **Reduce unnecessary updates**:
   ```swift
   // Only refresh when data actually changes
   func refresh() async throws {
       let newData = try await fetchData()
       guard newData != currentData else { return }
       
       currentData = newData
       lastUpdated = Date()
   }
   ```

---

## 🧪 Testing Issues

### Tests Not Running

**Problem**: `make test` fails or shows no tests.

**Symptoms**:
```bash
make test
# No tests found or execution fails
```

**Solutions**:
1. **Check test target configuration**:
   ```swift
   // In Package.swift
   .testTarget(
       name: "PylonTests",
       dependencies: ["Pylon"],
       path: "Tests/PylonTests"
   )
   ```

2. **Verify test file structure**:
   ```bash
   ls Tests/PylonTests/
   # Should show test files ending in Tests.swift
   ```

3. **Check test class naming**:
   ```swift
   // Test classes must inherit from XCTestCase
   final class MyWidgetTests: XCTestCase {
       func testExample() {
           // Test implementation
       }
   }
   ```

### Tests Failing with Concurrency Errors

**Problem**: Tests fail with actor isolation or concurrency warnings.

**Symptoms**:
```
error: call to main actor-isolated instance method cannot be made from a non-isolated context
```

**Solutions**:
1. **Mark test methods with @MainActor**:
   ```swift
   final class WidgetTests: XCTestCase {
       @MainActor
       func testWidgetInitialization() {
           let widget = MyWidget()
           XCTAssertEqual(widget.title, "Expected Title")
       }
   }
   ```

2. **Use async test methods**:
   ```swift
   @MainActor
   func testWidgetRefresh() async throws {
       let widget = MyWidget()
       try await widget.refresh()
       XCTAssertNotNil(widget.lastUpdated)
   }
   ```

---

## 🔍 Debugging Tips

### Enable Detailed Logging

```swift
// Add to AppState or widget classes
#if DEBUG
private let logger = Logger(subsystem: "com.pylon.app", category: "widgets")
#endif

func refresh() async throws {
    #if DEBUG
    logger.info("Starting widget refresh for \\(title)")
    #endif
    
    // Refresh logic
    
    #if DEBUG
    logger.info("Widget refresh completed in \\(duration)s")
    #endif
}
```

### Use Xcode Debugger

1. **Set breakpoints** in widget refresh methods
2. **Inspect variables** using Debug View Hierarchy
3. **Profile performance** with Instruments

### Console Commands for Debugging

```bash
# Show all log messages from your app
log stream --predicate 'subsystem LIKE "com.pylon.app"'

# Monitor memory usage
vm_stat 1

# Check CPU usage
top -pid $(pgrep Pylon)
```

---

## 🆘 Getting Help

### Before Asking for Help

1. **Search existing issues**: [GitHub Issues](https://github.com/rikardjonsson/Pylon/issues)
2. **Check documentation**: Review all docs in `docs/` directory
3. **Try debugging steps**: Follow this troubleshooting guide
4. **Test minimal example**: Create simple test case

### How to Report Issues

1. **Use issue templates** in GitHub
2. **Include system information**:
   - macOS version
   - Xcode version
   - Swift version
3. **Provide complete error messages**
4. **Share minimal reproduction steps**
5. **Include relevant code snippets**

### Community Resources

- **[GitHub Discussions](https://github.com/rikardjonsson/Pylon/discussions)** - General questions
- **[Issues](https://github.com/rikardjonsson/Pylon/issues)** - Bug reports and features
- **[Documentation](../docs/)** - Comprehensive guides

---

## 📚 Related Resources

- **[Onboarding Guide](ONBOARDING.md)** - Getting started as a developer
- **[Development Setup](DEVELOPMENT.md)** - Development environment and tools
- **[Widget API Reference](WIDGET_API.md)** - Complete API documentation
- **[Architecture Guide](ARCHITECTURE.md)** - Technical architecture details

---

**Still having issues? Don't hesitate to ask in [GitHub Discussions](https://github.com/rikardjonsson/Pylon/discussions) - the community is here to help!** 🚀