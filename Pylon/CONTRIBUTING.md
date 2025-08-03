# Contributing to Pylon

Thank you for your interest in contributing to Pylon! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites
- **Xcode 16+** with Swift 6.0 support
- **macOS 15.0+** for development and testing
- **Apple Developer Account** (for WeatherKit and eventual App Store submission)

### Getting Started
```bash
# Clone the repository
git clone https://github.com/rikardjonsson/Pylon.git
cd Pylon

# Open in Xcode
open Pylon.xcodeproj

# Build and run the project (⌘+R)
```

### Project Structure
```
Pylon/
├── Pylon/
│   ├── PylonApp.swift          # Main app entry point
│   ├── Models/                 # Core data models
│   ├── Views/                  # SwiftUI views
│   ├── Widgets/               # Widget implementations
│   ├── Services/              # Background services & APIs
│   ├── Themes/                # Theme system
│   └── Extensions/            # Swift extensions
├── PylonTests/                # Unit tests
├── PylonUITests/             # UI tests
└── docs/                     # Documentation
```

## Code Style Guidelines

### Swift 6.0 Concurrency
Pylon uses Swift 6.0 with strict concurrency checking enabled. Follow these patterns:

```swift
// UI components should use @MainActor
@MainActor
@Observable
class WidgetManager {
    var widgets: [any Widget] = []
}

// Background services should use actor
actor DataService: @unchecked Sendable {
    func fetchData() async throws -> Data {
        // Implementation
    }
}

// Use @unchecked Sendable sparingly for system integrations
class EventKitService: @unchecked Sendable {
    // Only when interfacing with non-Sendable system APIs
}
```

### SwiftUI Patterns
- Use `@Observable` for view models (Swift 6.0 pattern)
- Prefer `@State` over `@StateObject` for local state
- Use `@Environment` for dependency injection
- Keep views small and focused

### Error Handling
```swift
enum WidgetError: LocalizedError {
    case permissionDenied
    case networkUnavailable
    case dataCorrupted
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission required to access this data"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .dataCorrupted:
            return "Data format is invalid"
        }
    }
}
```

### Documentation
- Use Swift documentation comments for public APIs
- Include usage examples for complex functions
- Document performance considerations
- Explain integration patterns for system APIs

```swift
/// Fetches today's calendar events from EventKit
/// 
/// This method requires calendar access permissions and will throw
/// `WidgetError.permissionDenied` if access is not granted.
/// 
/// - Returns: Array of events for today, sorted by start time
/// - Throws: `WidgetError` if permissions are denied or data is unavailable
@MainActor
func fetchTodaysEvents() async throws -> [EKEvent] {
    // Implementation
}
```

## Testing Guidelines

### Unit Tests
- Test all widget logic and data transformations
- Mock system dependencies (EventKit, AppleScript, etc.)
- Test error conditions and edge cases
- Maintain >80% code coverage for critical paths

```swift
final class CalendarWidgetTests: XCTestCase {
    @MainActor
    func testEventFetching() async throws {
        let widget = CalendarWidget(eventStore: MockEventStore())
        try await widget.refresh()
        XCTAssertFalse(widget.todaysEvents.isEmpty)
    }
}
```

### UI Tests
- Test complete user workflows
- Verify accessibility compliance
- Test keyboard navigation paths
- Validate performance benchmarks

### Performance Testing
Use Xcode Instruments to verify:
- Cold boot time < 2 seconds
- Widget refresh time < 1 second
- CPU usage < 5% when idle
- Memory usage < 100MB

## Widget Development

### Creating a New Widget
1. Implement the `Widget` protocol
2. Add to `WidgetManager` registration
3. Create SwiftUI view components
4. Add comprehensive tests
5. Update documentation

```swift
@MainActor
@Observable
class CustomWidget: Widget {
    let id = UUID()
    let title = "Custom Widget"
    private(set) var isRefreshing = false
    private(set) var lastUpdated: Date?
    
    func refresh() async throws {
        isRefreshing = true
        defer { isRefreshing = false }
        
        // Fetch data
        // Update UI state
        
        lastUpdated = Date()
    }
    
    func body() -> AnyView {
        AnyView(CustomWidgetView(widget: self))
    }
}
```

### System Integration Guidelines
- Always request permissions gracefully
- Handle permission denied states with meaningful UI
- Implement retry mechanisms for network operations
- Use background actors for system API calls
- Cache data appropriately with TTL

## Pull Request Process

### Before Submitting
1. **Run all tests**: Ensure unit and UI tests pass
2. **Performance check**: Verify performance benchmarks
3. **Accessibility**: Test with VoiceOver and keyboard navigation
4. **Code review**: Self-review for Swift 6.0 compliance
5. **Documentation**: Update relevant documentation

### PR Requirements
- **Clear title**: Summarize the change concisely
- **Detailed description**: Explain what, why, and how
- **Issue reference**: Link to related GitHub issues
- **Testing**: Describe testing performed
- **Breaking changes**: Document any breaking changes

### PR Template
```markdown
## Summary
Brief description of the changes

## Related Issues
Fixes #issue_number

## Changes Made
- [ ] Added new widget for [feature]
- [ ] Updated theme system
- [ ] Fixed performance issue

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Performance benchmarks met
- [ ] Accessibility tested

## Breaking Changes
None / List any breaking changes

## Screenshots
If applicable, add screenshots of UI changes
```

## Issue Reporting

### Bug Reports
Use the bug report template and include:
- macOS version and hardware
- Pylon version
- Steps to reproduce
- Expected vs actual behavior
- Console logs (if applicable)
- Performance impact

### Feature Requests
- Describe the problem you're trying to solve
- Explain the proposed solution
- Consider alternative approaches
- Estimate implementation complexity
- Discuss backward compatibility

## Development Roadmap

### Current Focus (v0.1)
- Core app architecture
- Widget protocol system
- Basic UI with grid layout
- Theme system foundation

### Near Term (v0.5)
- All productivity widgets
- System integration
- Keyboard navigation
- Menu bar integration

### Long Term (v1.0)
- Plugin system
- Advanced customization
- App Store submission
- Comprehensive accessibility

## Communication

### Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Requests**: Code review and collaboration

### Guidelines
- Be respectful and constructive
- Search existing issues before creating new ones
- Provide context and examples
- Follow up on your contributions

## License

By contributing to Pylon, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes for significant contributions
- Project documentation

Thank you for helping make Pylon better! 🚀