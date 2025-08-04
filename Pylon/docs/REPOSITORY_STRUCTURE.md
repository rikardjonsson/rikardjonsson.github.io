# Repository Structure

This document outlines the organization and structure of the Pylon repository.

## Overview

Pylon is organized as a **Swift Package Manager** project with a clear separation of concerns and modular architecture.

## Directory Structure

```
Pylon/
├── README.md                     # Project overview and quick start
├── LICENSE                       # MIT License
├── Package.swift                 # Swift Package Manager configuration
├── Makefile                      # Development commands and quality gates
├── .gitignore                    # Git ignore rules
├── .swiftlint.yml               # SwiftLint configuration
├── .swiftformat                  # SwiftFormat configuration
│
├── Sources/                      # Main source code (SPM target)
│   ├── PylonApp.swift           # Main app entry point
│   ├── ContentView.swift        # Root SwiftUI view
│   ├── Assets.xcassets/         # App icons and color assets
│   ├── Pylon.entitlements       # macOS app entitlements
│   ├── Preview Content/         # SwiftUI preview assets
│   │
│   ├── Models/                  # Core data models and business logic
│   │   ├── AppState.swift       # Main app state (@MainActor)
│   │   ├── Theme.swift          # Theme system and definitions
│   │   ├── WidgetContainer.swift# Widget container architecture
│   │   ├── WidgetManager.swift  # Widget lifecycle management
│   │   └── WidgetSize.swift     # Widget sizing system
│   │
│   ├── Views/                   # SwiftUI views and UI components
│   │   └── WidgetContainerView.swift # Universal widget container view
│   │
│   ├── Widgets/                 # Widget implementations
│   │   └── Sample/              # Sample widget demonstrating architecture
│   │       └── SampleWidget.swift
│   │
│   ├── Services/                # Background services and integrations
│   ├── Extensions/              # Swift extensions and utilities
│   └── Themes/                  # Additional theme definitions
│
├── Tests/                       # Test suite
│   └── PylonTests/
│       └── PylonTests.swift     # Unit tests
│
├── docs/                        # Project documentation
│   ├── ARCHITECTURE.md          # Architectural decisions and patterns
│   ├── DEVELOPMENT.md           # Development setup and tooling
│   ├── ISSUES.md                # GitHub issues roadmap
│   ├── SWIFT6_AUDIT.md          # Swift 6.0 concurrency compliance audit
│   └── REPOSITORY_STRUCTURE.md  # This file
│
├── scripts/                     # Development and build scripts
│   ├── swiftlint-xcode.sh       # SwiftLint Xcode integration
│   └── swiftformat-xcode.sh     # SwiftFormat Xcode integration
│
├── archive/                     # Archived files (not part of build)
│   ├── create-all-issues.sh     # Initial GitHub issues creation
│   └── create-github-issues.sh  # GitHub API scripts
│
└── CONTRIBUTING.md              # Contribution guidelines

```

## Architecture Principles

### Swift Package Manager Structure
- **Single Target**: Main executable target points to `Sources/`
- **Test Integration**: Tests in `Tests/PylonTests/`
- **Resource Handling**: Assets excluded from SPM but available for Xcode integration

### Source Code Organization

#### Models Layer (`Sources/Models/`)
Contains all data models, business logic, and state management:
- `AppState.swift` - Main application state with `@MainActor` isolation
- `Theme.swift` - Theme system with Sendable protocol compliance
- `WidgetContainer.swift` - Container architecture protocol definitions
- `WidgetManager.swift` - Widget lifecycle and refresh management
- `WidgetSize.swift` - Dynamic sizing system for widgets

#### Views Layer (`Sources/Views/`)
SwiftUI views and UI components:
- Focused on presentation logic
- Proper separation from business logic
- Reusable components

#### Widgets Layer (`Sources/Widgets/`)
Widget implementations following the container architecture:
- Each widget in its own subdirectory
- Demonstrates modular, swappable content
- Size-adaptive layouts

#### Services Layer (`Sources/Services/`)
Background services and external integrations:
- Network services
- System integrations (EventKit, WeatherKit, etc.)
- Data persistence

### Documentation Structure (`docs/`)
Comprehensive project documentation:
- **ARCHITECTURE.md** - Technical architecture and design decisions
- **DEVELOPMENT.md** - Developer setup, tooling, and workflows
- **ISSUES.md** - Development roadmap and GitHub issues
- **SWIFT6_AUDIT.md** - Concurrency compliance documentation

### Development Tooling
- **Makefile** - Unified commands for building, testing, linting
- **Quality Gates** - SwiftLint, SwiftFormat with pre-commit hooks
- **Scripts** - Xcode/CI integration scripts

## File Naming Conventions

### Swift Files
- **PascalCase** for types and filenames: `AppState.swift`, `WidgetContainer.swift`
- **Descriptive names** reflecting purpose: `WidgetContainerView.swift`
- **Grouped by layer**: Models, Views, Widgets, Services

### Documentation
- **UPPERCASE.md** for major docs: `README.md`, `ARCHITECTURE.md`
- **Descriptive names**: `REPOSITORY_STRUCTURE.md`, `SWIFT6_AUDIT.md`

### Configuration
- **Dotfiles** for tool configuration: `.swiftlint.yml`, `.swiftformat`
- **Standard names** for build files: `Makefile`, `Package.swift`

## Dependencies and Build

### Package Dependencies
Currently dependency-free for maximum simplicity and performance.

### Build Configuration
- **Swift 6.0** with strict concurrency enabled
- **macOS 15.0+** minimum deployment target
- **Executable target** for standalone app distribution

### Quality Gates
- **SwiftLint** - Code style and best practices
- **SwiftFormat** - Automatic code formatting
- **Pre-commit hooks** - Automated quality checks
- **Strict Concurrency** - Swift 6.0 compliance

## Development Workflow

1. **Clone Repository**
   ```bash
   git clone https://github.com/rikardjonsson/Pylon.git
   cd Pylon
   ```

2. **Install Development Tools**
   ```bash
   make install-tools
   ```

3. **Build and Test**
   ```bash
   make build
   make test
   ```

4. **Quality Checks**
   ```bash
   make quality
   ```

5. **Pre-commit Workflow**
   ```bash
   make pre-commit
   ```

## Integration Points

### Xcode Integration
- Assets and entitlements available for Xcode projects
- Build scripts for Xcode phases
- SwiftUI previews supported

### CI/CD Integration
- Makefile commands suitable for automation
- Quality gates enforceable in CI
- Swift Package Manager compatibility

### External Tools
- GitHub CLI integration for issue management
- Homebrew for dependency installation
- SwiftLint/SwiftFormat for code quality

## Future Considerations

### Scalability
- Modular widget architecture supports plugin system
- Service layer ready for external integrations
- Documentation structure supports growth

### Maintenance
- Clear separation of concerns
- Comprehensive tooling setup
- Quality gates for consistency

---

This structure supports the project's goals of modularity, maintainability, and Swift 6.0 compliance while providing excellent developer experience.