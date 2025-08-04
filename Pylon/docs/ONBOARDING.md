# Developer Onboarding Guide

Welcome to Pylon! This guide will help you get up and running as a contributor to the next-generation macOS productivity dashboard.

## 🎯 Quick Start (5 minutes)

### 1. Environment Setup
```bash
# Clone and enter the project
git clone https://github.com/rikardjonsson/Pylon.git
cd Pylon

# Install development tools
make install-tools

# Verify everything works
make build && make test
```

### 2. Run Your First Build
```bash
# Option 1: Command line (Swift Package Manager)
swift run

# Option 2: Xcode (for UI development)
open Package.swift  # Opens project in Xcode
# Press ⌘+R to build and run
```

### 3. Make Your First Change
```bash
# Create a feature branch
git checkout -b feature/my-improvement

# Make a small change (try updating the slogan in ContentView.swift)
# Run quality checks
make quality

# Commit your change
git add . && git commit -m "Update: small improvement"
```

**🎉 Success!** You're now ready to contribute to Pylon.

---

## 📚 Understanding Pylon

### Project Philosophy
Pylon is built on **three core principles**:

1. **🧩 Modularity**: Everything is designed as interchangeable containers
2. **⚡ Performance**: Swift 6.0 strict concurrency for optimal responsiveness  
3. **🎨 Native Integration**: Deep macOS ecosystem integration

### Key Concepts

#### Widget Container Architecture
```swift
// Every widget in Pylon follows this pattern:
@MainActor
protocol WidgetContainer: Identifiable {
    var size: WidgetSize { get set }        // Dynamic sizing
    var theme: WidgetThemeOverride? { get set } // Custom themes
    var isEnabled: Bool { get set }         // Visibility toggle
    
    func refresh() async throws             // Data refresh
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView
}
```

#### Dynamic Sizing System
Widgets support **4 sizes** that users can switch between:
- **Small** (1×1) - Glanceable info
- **Medium** (2×1) - Lists and compact data  
- **Large** (2×2) - Rich content
- **XLarge** (4×2) - Full interfaces

#### Swift 6.0 Concurrency
All code must follow strict concurrency patterns:
- `@MainActor` for UI components
- `actor` for background services
- `Sendable` for shared data types
- Structured concurrency with `async/await`

---

## 🛠️ Development Environment

### Required Tools
- **macOS 15.0+** (macOS Sequoia)
- **Xcode 16+** with Swift 6.0 support
- **Git** for version control
- **Homebrew** (for development tools)

### Optional Tools
- **Apple Developer Account** (for WeatherKit integration)
- **GitHub CLI** (`gh` command for issue management)

### Development Tools Setup
```bash
# Install SwiftLint and SwiftFormat (automated via Makefile)
make install-tools

# Verify tools are working
swiftlint version      # Should show installed version
swiftformat --version  # Should show installed version

# Check quality gates
make quality           # Runs formatting and linting
```

### IDE Setup

#### Xcode Configuration
1. Open `Package.swift` in Xcode
2. Enable SwiftLint build phase:
   - Add "Run Script Phase" to target
   - Script: `./scripts/swiftlint-xcode.sh`
3. Set up SwiftFormat:
   - Add "Run Script Phase" (before compilation)
   - Script: `./scripts/swiftformat-xcode.sh`

#### VS Code Configuration (Optional)
```json
// .vscode/settings.json
{
    "swift.path": "/usr/bin/swift",
    "swift.buildPath": ".build",
    "files.exclude": {
        ".build": true,
        ".swiftpm": true
    }
}
```

---

## 🏗️ Project Architecture Deep Dive

### Directory Structure Walkthrough
```
Pylon/
├── Sources/                     # 🎯 Main development area
│   ├── PylonApp.swift          # App entry point
│   ├── Models/                  # 📊 Data models and business logic
│   │   ├── AppState.swift      # Central app state (@MainActor)
│   │   ├── Theme.swift         # Theme system with Material design
│   │   ├── WidgetContainer.swift # Container architecture protocols
│   │   ├── WidgetManager.swift # Widget lifecycle management
│   │   └── WidgetSize.swift    # Dynamic sizing system
│   ├── Views/                   # 🎨 SwiftUI views and UI components
│   ├── Widgets/                 # 🧩 Widget implementations
│   │   └── Sample/             # Example widget (start here!)
│   ├── Services/               # ⚙️ Background services and APIs
│   ├── Extensions/             # 🔧 Swift extensions and utilities
│   └── Themes/                 # 🎨 Additional theme definitions
├── Tests/                      # 🧪 Test suite
├── docs/                       # 📚 Project documentation
└── scripts/                    # 🔨 Development automation
```

### Key Files to Understand

#### 1. `Sources/PylonApp.swift` - App Entry Point
- SwiftUI app lifecycle
- Environment setup
- Window configuration

#### 2. `Sources/Models/AppState.swift` - Central State  
- Main app state management
- Theme selection and switching
- Widget layout configuration
- `@MainActor` and `@Observable` patterns

#### 3. `Sources/Models/WidgetContainer.swift` - Architecture Core
- Protocol definitions for widget system
- Dynamic sizing enums
- Theme override structures
- Position and layout types

#### 4. `Sources/Widgets/Sample/SampleWidget.swift` - Reference Implementation
- Complete widget implementation example
- Shows all 4 size configurations
- Demonstrates proper Swift 6.0 patterns
- Perfect starting point for new widgets

---

## 🚀 Common Development Tasks

### Creating a New Widget

1. **Create Widget Directory**
   ```bash
   mkdir -p Sources/Widgets/MyWidget
   cd Sources/Widgets/MyWidget
   ```

2. **Implement Widget Protocol**
   ```swift
   // MyWidget.swift
   @MainActor
   final class MyWidget: WidgetContainer, ObservableObject {
       let id = UUID()
       @Published var size: WidgetSize = .medium
       @Published var theme: WidgetThemeOverride?
       @Published var isEnabled: Bool = true
       @Published var position: GridPosition = .zero
       
       let title = "My Widget"
       let category = WidgetCategory.productivity
       let supportedSizes: [WidgetSize] = [.small, .medium, .large]
       
       var lastUpdated: Date? { /* implementation */ }
       var isLoading: Bool { false }
       var error: Error? { nil }
       
       func refresh() async throws {
           // Async data loading
       }
       
       func configure() -> AnyView {
           AnyView(MyWidgetConfigView())
       }
       
       func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
           AnyView(MyWidgetView(widget: self, theme: theme))
       }
   }
   ```

3. **Test All Size Configurations**
   ```swift
   // Ensure your widget works in all supported sizes
   switch size {
   case .small: SmallLayoutView()
   case .medium: MediumLayoutView()  
   case .large: LargeLayoutView()
   case .xlarge: XLargeLayoutView()
   }
   ```

### Adding a New Theme

1. **Create Theme Struct**
   ```swift
   // Sources/Models/Theme.swift
   struct MyCustomTheme: Theme {
       let name = "My Theme"
       let backgroundMaterial = Material.regularMaterial
       let primaryColor = Color.purple
       let secondaryColor = Color.purple.opacity(0.6)
       let accentColor = Color.purple
       let glassEffect = Material.ultraThin
       let cardBackground = Color.clear
       let textPrimary = Color.primary
       let textSecondary = Color.secondary
   }
   ```

2. **Register Theme**
   ```swift
   // Add to Theme extension
   extension Theme {
       static let myCustom = MyCustomTheme()
   }
   ```

### Running Quality Checks

```bash
# Before committing, always run:
make quality        # Format code and run linting
make build         # Ensure project builds
make test          # Run test suite

# Or run the complete pre-commit workflow:
make pre-commit    # Does all of the above
```

### Debugging Common Issues

#### Swift 6.0 Concurrency Errors
```bash
# Build with strict concurrency to catch issues
swift build -Xswiftc -strict-concurrency=complete
```

**Common fixes:**
- Add `@MainActor` to UI classes
- Use `@Published` for observable properties
- Make shared types `Sendable`
- Use `[weak self]` in TaskGroup closures

#### Linting Failures
```bash
# Auto-fix most style issues
make lint-fix

# Check specific file
swiftlint lint --path Sources/MyFile.swift
```

---

## 🧪 Testing Guidelines

### Unit Testing
```swift
// Tests/PylonTests/MyWidgetTests.swift
@testable import Pylon
import XCTest

final class MyWidgetTests: XCTestCase {
    @MainActor
    func testWidgetRefresh() async throws {
        let widget = MyWidget()
        XCTAssertFalse(widget.isLoading)
        
        try await widget.refresh()
        
        XCTAssertNotNil(widget.lastUpdated)
    }
}
```

### Running Tests
```bash
# Run all tests
make test

# Run specific test
swift test --filter MyWidgetTests

# Run with coverage (if configured)
swift test --enable-code-coverage
```

---

## 📋 Code Style Guidelines

### Swift 6.0 Patterns
```swift
// ✅ Good: Proper actor isolation
@MainActor
class UIViewModel: ObservableObject {
    @Published var data: [Item] = []
}

// ✅ Good: Background actor for data
actor DataService {
    func fetchData() async throws -> [Item] {
        // Heavy processing
    }
}

// ✅ Good: Sendable data types
struct Item: Sendable, Identifiable {
    let id: UUID
    let name: String
}
```

### File Organization
- **Single Responsibility**: One main type per file
- **400 Line Limit**: Break large files into smaller modules
- **Clear Naming**: Descriptive file and type names
- **Logical Grouping**: Related types in same directory

### Naming Conventions
```swift
// ✅ Good naming examples
protocol WidgetContainer: Identifiable { }
class CalendarWidget: WidgetContainer { }
enum WidgetSize: CaseIterable { }
struct GridPosition: Sendable { }
```

---

## 🤝 Contributing Workflow

### 1. Find or Create an Issue
- Check [existing issues](https://github.com/rikardjonsson/Pylon/issues)
- Follow issue templates for bug reports or features
- Discuss approach in issue comments before coding

### 2. Development Process
```bash
# Create feature branch
git checkout -b feature/issue-123-my-feature

# Make changes following architectural principles
# Write tests for new functionality
# Update documentation if needed

# Run quality checks
make pre-commit

# Commit with clear message
git commit -m "Add: Calendar widget with EventKit integration

- Implements WidgetContainer protocol
- Supports all 4 size configurations  
- Includes comprehensive error handling
- Adds unit tests with 90% coverage

Resolves #123"
```

### 3. Pull Request Guidelines
- **Clear Title**: Summarize the change
- **Detailed Description**: What, why, and how
- **Link Issues**: Use "Resolves #123" syntax
- **Screenshots**: For UI changes
- **Tests**: Include test coverage information

### 4. Code Review Process
- All PRs require review
- Address feedback promptly
- Keep discussions constructive
- Be open to architectural suggestions

---

## 🆘 Getting Help

### Quick Questions
- **GitHub Discussions**: For general questions and ideas
- **Issue Comments**: For specific issue-related questions
- **Code Examples**: Check `Sources/Widgets/Sample/` for patterns

### Common Resources
- **[Architecture Guide](ARCHITECTURE.md)**: Deep technical details
- **[Development Setup](DEVELOPMENT.md)**: Tooling and workflows
- **[Swift 6.0 Audit Report](SWIFT6_AUDIT.md)**: Concurrency patterns
- **[Apple Documentation](https://developer.apple.com/documentation/)**: SwiftUI and macOS APIs

### Debugging Tips
1. **Check Build Logs**: `swift build` shows compilation errors
2. **Run Quality Checks**: `make quality` catches style issues
3. **Use Xcode Debugger**: Set breakpoints for runtime debugging
4. **Check Git Status**: `git status` shows uncommitted changes

---

## 🎯 Next Steps

### For Your First Contribution
1. **Explore the Sample Widget**: Study `Sources/Widgets/Sample/SampleWidget.swift`
2. **Pick a "Good First Issue"**: Look for beginner-friendly issues
3. **Join the Discussion**: Introduce yourself in GitHub Discussions
4. **Start Small**: Documentation improvements or small bug fixes

### For Ongoing Contributors
1. **Study the Architecture**: Deep dive into container patterns
2. **Implement a Widget**: Calendar, Weather, or System Monitor
3. **Improve Developer Experience**: Better tooling or documentation
4. **Optimize Performance**: Identify and fix bottlenecks

### For Advanced Contributors
1. **Design New Architecture**: Plugin system or advanced features
2. **Mentor New Contributors**: Help with onboarding and reviews
3. **Lead Major Features**: Take ownership of complex implementations
4. **Shape Project Direction**: Participate in architectural decisions

---

**Welcome to the Pylon community! We're excited to have you aboard.** 🚀

*Questions? Don't hesitate to ask in [GitHub Discussions](https://github.com/rikardjonsson/Pylon/discussions) - we're here to help!*