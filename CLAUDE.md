# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains three main projects:

1. **SuperClaude** - A Python framework that extends Claude Code with specialized commands, personas, and MCP server integration
2. **outdoor-gear-shop** - A Next.js 14 affiliate site for outdoor gear with SEO optimization and Amazon Associates API integration
3. **Pylon** - A next-generation macOS productivity dashboard built with SwiftUI and Swift 6.0 that deeply integrates with the macOS ecosystem

## Common Development Commands

### SuperClaude (Python Project)
```bash
# Installation and setup
python3 -m SuperClaude install                  # Quick setup (recommended)
python3 -m SuperClaude install --interactive    # Interactive component selection
python3 -m SuperClaude install --minimal        # Core framework only
python3 -m SuperClaude install --profile developer  # Full developer setup

# Alternative command formats
SuperClaude install
python3 SuperClaude install

# Testing
python Tests/comprehensive_test.py              # Full test suite
python Tests/task_management_test.py            # Specific component tests
python Tests/performance_test_suite.py          # Performance tests

# Backup and maintenance
python3 -m SuperClaude backup --create          # Create backup
python3 -m SuperClaude update                   # Update installation
python3 -m SuperClaude uninstall                # Remove installation
```

### Outdoor Gear Shop (Next.js Project)
```bash
# Development
npm install                                     # Install dependencies
npm run dev                                     # Start development server (uses --turbo)
npm run build                                   # Build for production (includes deploy.js)
npm start                                       # Start production server
npm run lint                                    # Run ESLint

# Environment setup
cp .env.example .env.local                      # Set up environment variables
# Add Amazon Associates API credentials to .env.local
```

### Pylon (Swift/macOS Project)
```bash
# Development
open Pylon.xcodeproj                            # Open in Xcode
# Build and run through Xcode (⌘+R)
# Test through Xcode (⌘+U)

# Code formatting and linting
swiftformat .                                   # Format Swift code (if installed)
swiftlint                                       # Lint Swift code (if installed)

# Project management
xcodebuild -project Pylon.xcodeproj -list      # List available schemes and targets
xcodebuild -scheme Pylon -configuration Debug build  # Command line build

# Performance profiling
# Use Xcode Instruments for CPU, memory, and performance analysis
```

## High-Level Architecture

### SuperClaude Framework Architecture

**Core Components:**
- **SuperClaude/Core/** - Framework documentation and behavior definitions
  - CLAUDE.md - Main entry point referencing all other components
  - ORCHESTRATOR.md - Intelligent routing and wave orchestration system
  - COMMANDS.md - 16 specialized slash commands with wave support
  - PERSONAS.md - 11 domain-specific AI personalities with auto-activation
  - FLAGS.md - Auto-activation flags and performance optimization
  - MCP.md - Model Context Protocol server integration patterns
  - PRINCIPLES.md - Core development principles and decision frameworks
  - RULES.md - Actionable operational rules
  - MODES.md - Task management, introspection, and token efficiency modes

**Key Features:**
- **Wave Orchestration**: Multi-stage command execution for complex operations (auto-activates on complexity ≥0.7)
- **Persona System**: Auto-activating domain specialists (architect, frontend, backend, security, etc.)
- **MCP Integration**: Context7 (docs), Sequential (analysis), Magic (UI), Playwright (testing)
- **Task Management**: TodoWrite integration with multi-session project management
- **Intelligent Routing**: Auto-activation of tools, personas, and strategies based on context

**Installation System:**
- **setup/operations/** - Modular installation operations (install, update, uninstall, backup)
- **setup/components/** - Individual framework components (commands, core, hooks, mcp)
- **setup/core/** - Configuration management and validation
- **profiles/** - Installation profiles (minimal, quick, developer)

### Outdoor Gear Shop Architecture

**Next.js 14 App Router Structure:**
- **src/app/** - App Router pages with layout components
- **src/components/** - Reusable UI components with Tailwind CSS
- **src/lib/** - Utility functions and API clients
- **src/content/** - MDX content for blog posts and product reviews

**Key Features:**
- **Affiliate Integration**: Amazon Associates API with multi-retailer support
- **Content Management**: MDX-powered blog and product review system
- **SEO Optimization**: Structured data, meta tags, sitemap generation
- **Performance**: Image optimization, PWA manifest, A/B testing framework
- **E-commerce**: Product comparison tables, search functionality, user reviews

**Deployment:**
- **deploy.js** - Custom deployment script (runs after build)
- **Vercel-ready** - Optimized for Vercel deployment
- **Static Generation** - Pre-rendered pages for performance

### Pylon macOS App Architecture

**SwiftUI + Swift 6.0 Structure:**
- **PylonApp.swift** - Main app entry point with SwiftUI app lifecycle
- **Models/** - Core data models and business logic with Swift 6.0 strict concurrency
- **Views/** - SwiftUI views organized by feature (Widgets, Settings, etc.)
- **Services/** - Background services and API integrations (@unchecked Sendable actors)
- **Widgets/** - Modular widget system with protocol-based architecture

**Core Systems:**
- **Widget Engine**: Protocol-based modular system with lifecycle management
- **Integration Layer**: EventKit (calendar/reminders), AppleScript (Notes/Mail), WeatherKit
- **System Monitoring**: CPU/RAM/disk monitoring with efficient background refresh
- **Theme System**: Modern material-based visuals with dark/light mode and customizable themes
- **Layout Engine**: Responsive grid with drag-and-drop and widget resizing

**Performance Targets:**
- **Cold Boot**: <2 seconds
- **Widget Refresh**: <1 second  
- **CPU Usage**: <5% idle
- **Memory Usage**: <100MB
- **Background Refresh**: NSBackgroundActivityScheduler with power efficiency

## Framework-Specific Patterns

### SuperClaude Development

**Command Structure:**
```yaml
command: "/command-name"
category: "Development|Analysis|Quality|Meta"
purpose: "Operational objective"
wave-enabled: true|false
performance-profile: "optimization|standard|complex"
```

**Persona Auto-Activation:**
- **architect**: Systems design, scalability (keywords: architecture, design, scalability)
- **frontend**: UI/UX, accessibility (keywords: component, responsive, accessibility)
- **backend**: APIs, reliability (keywords: API, database, service)
- **security**: Threat modeling (keywords: vulnerability, threat, compliance)
- **analyzer**: Root cause analysis (keywords: analyze, investigate, debug)

**Wave System:**
- Auto-activates on: complexity ≥0.7 AND files >20 AND operation_types >2
- Wave-enabled commands: /analyze, /build, /implement, /improve, /design, /task
- Strategies: progressive, systematic, adaptive, enterprise

### Next.js Development Patterns

**Component Structure:**
- Use TypeScript for all components
- Implement responsive design with Tailwind CSS mobile-first approach
- Follow accessibility best practices (WCAG 2.1 AA)
- Optimize images with Next.js Image component

**Content Management:**
- MDX files in src/content/ with frontmatter metadata
- Gray-matter for frontmatter parsing
- Reading-time calculation for blog posts
- Structured data for SEO

**API Integration:**
- Amazon Associates API in src/lib/amazon-api.ts
- Mock data fallback for development
- Error handling with graceful degradation
- Multi-affiliate network support (REI, Backcountry, Moosejaw, Evo)

### Pylon Development Patterns

**Swift 6.0 Concurrency:**
```swift
@MainActor
@Observable
class WidgetManager {
    // UI state management on main actor
}

actor DataService: @unchecked Sendable {
    // Background data operations
}
```

**Widget Protocol System:**
```swift
protocol Widget: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    @MainActor func refresh() async throws
    @MainActor func body() -> AnyView
}
```

**EventKit Integration:**
- Request calendar/reminders permissions at app launch
- Use EKEventStore for real-time synchronization
- Handle permission states gracefully with fallback UI

**AppleScript Integration:**
- Execute via Process with error handling
- Parse structured output for Notes/Mail data
- Implement timeout and retry mechanisms

**Performance Patterns:**
- Use NSBackgroundActivityScheduler for efficient background updates
- Implement caching with TTL for reduced API calls
- Monitor CPU/memory usage with built-in performance tracking

## Important Considerations

### SuperClaude
- **Installation**: Two-step process (package install → framework install)
- **Version**: v3.0.0 with breaking changes from v2.x
- **Dependencies**: Python 3.8+, Node.js 18+ for MCP servers
- **Framework Files**: Installed to ~/.claude/ directory
- **Logging**: Logs stored in install directory for debugging

### Outdoor Gear Shop
- **Environment Variables**: Amazon API credentials required for production
- **Performance Budget**: <3s load time, <500KB initial bundle
- **SEO Requirements**: Meta tags, structured data, sitemap
- **Affiliate Compliance**: Proper disclosure and tracking
- **Mobile-First**: Responsive design with Tailwind CSS

### Pylon
- **Target Platform**: macOS 15.0+ with Swift 6.0 strict concurrency
- **Performance Requirements**: <2s boot, <1s refresh, <5% CPU, <100MB RAM
- **System Integration**: EventKit, AppleScript, WeatherKit, system APIs
- **Accessibility**: Full VoiceOver support and keyboard navigation
- **App Store**: Must comply with sandboxing and App Store guidelines

## Pylon Architectural Principles

### Design Philosophy
Everything in Pylon is designed with **modularity and flexibility** in mind. As few components as possible should be hardcoded unless absolutely necessary. The architecture follows a container-based approach where widgets are interchangeable modules that can be dynamically configured, resized, and reordered.

### Core Architectural Standards

#### 1. Modularity & Flexibility
- **Widget Container Architecture**: Every widget is designed as a container where content can be swapped dynamically
- **Minimal Hardcoding**: Avoid hardcoded values; use configuration, themes, and dynamic sizing
- **Protocol-Oriented Design**: Use protocols to define interfaces, enabling easy substitution and testing
- **Dependency Injection**: Components should receive dependencies rather than creating them

#### 2. Swift 6.0 & macOS 15 Standards
- **Strict Concurrency**: All code must compile with Swift 6.0 strict concurrency enabled
- **Actor Isolation**: Use `@MainActor` for UI components, dedicated actors for background work
- **Sendable Compliance**: All shared data types must conform to `Sendable`
- **Modern SwiftUI**: Leverage `@Observable`, `@State`, and latest SwiftUI patterns
- **macOS 15 APIs**: Use latest frameworks (WeatherKit, EventKit, AppKit integration)

#### 3. File Size Limits
- **400-Line Maximum**: No file should exceed 400 lines of code
- **Preferably Smaller**: Aim for files under 200 lines when possible
- **Single Responsibility**: Each file should have one clear purpose
- **Logical Separation**: Split large components into focused, smaller modules

#### 4. Widget System Architecture

**Dynamic Container System:**
```swift
protocol WidgetContainer {
    var size: WidgetSize { get set }        // Small, Medium, Large, XLarge
    var theme: WidgetTheme { get set }      // Color scheme adaptation
    var content: any WidgetContent { get }  // Swappable content
}

enum WidgetSize: CaseIterable {
    case small    // 1x1 grid units
    case medium   // 2x1 grid units  
    case large    // 2x2 grid units
    case xlarge   // 4x2 grid units
}
```

**Size Requirements:**
- **Predefined Sizes**: Set amount of sizes (Small, Medium, Large, XLarge)
- **Dynamic Switching**: Sizes can be changed via settings without losing data
- **Grid Alignment**: All sizes align to a consistent grid system
- **Responsive Content**: Content adapts gracefully to size changes

#### 5. Grid-Based Layout System

**Grid Specifications:**
- **Consistent Grid**: All widgets follow a unified grid system (12-column base)
- **Reorderable**: Widgets can be dragged and dropped to reorder
- **Adaptive Colors**: Widgets adapt to different color schemes automatically
- **Visual Consistency**: All widgets maintain visual harmony regardless of configuration

**Layout Flexibility:**
```swift
struct WidgetLayout {
    let columns: Int                    // Grid columns (2, 3, 4)
    let spacing: CGFloat               // Inter-widget spacing
    let padding: EdgeInsets            // Container padding
    let allowedSizes: [WidgetSize]     // Permitted sizes for layout
}
```

#### 6. Theme and Color Adaptation

**Dynamic Theming:**
- **Color Harmony**: Widgets automatically adapt to active theme
- **Consistent Appearance**: Visual elements maintain consistency across themes
- **Custom Overrides**: Individual widgets can have theme customizations
- **System Integration**: Respect system appearance (light/dark mode)

### Implementation Guidelines

#### Widget Development Pattern:
1. **Create Widget Protocol**: Define the widget interface
2. **Implement Container**: Build the size-adaptive container
3. **Add Content Module**: Create swappable content component
4. **Theme Integration**: Ensure theme compatibility
5. **Size Testing**: Test all supported sizes
6. **Grid Validation**: Verify grid alignment and spacing

#### File Organization:
```
Pylon/Sources/
├── Models/           # Data models (<200 lines each)
├── Views/            # UI components (<300 lines each)
├── Widgets/          # Widget implementations
│   ├── Calendar/     # CalendarWidget + components
│   ├── Reminders/    # RemindersWidget + components
│   └── Shared/       # Shared widget components
├── Services/         # Background services (<400 lines each)
└── Themes/           # Theme definitions (<200 lines each)
```

#### Quality Checkpoints:
- [ ] File under 400 lines (preferably <200)
- [ ] Widget supports all size configurations
- [ ] Component works with all themes
- [ ] Grid alignment maintained
- [ ] Swift 6.0 strict concurrency compliance
- [ ] No hardcoded values (use configuration)
- [ ] Protocol-based interfaces used
- [ ] macOS 15 APIs leveraged appropriately

## Systematic Development Optimization Practices

### 🔍 Codebase Review Goals

When conducting code reviews and audits, identify and document detailed issues and improvement opportunities, each including:

**Required Documentation Format:**
- **Title**: Clear, concise, and actionable
- **Description**: What's wrong, why it matters, and how to fix it  
- **Priority**: High (must fix), Medium (should fix), Low (nice to fix)
- **Tags**: Use relevant labels (e.g. concurrency, architecture, style, cleanup)
- **References**: File paths and line numbers where applicable

**Focus Areas for Identification:**
- Unsafe or outdated Swift patterns
- Incorrect or inefficient use of concurrency (async/await, @MainActor, actors)
- Poor protocol design, overexposed types, or tight coupling
- Violations of Swift API Design Guidelines
- Inconsistent naming, file structure, or style
- Areas lacking modularity, testability, or dependency isolation
- Performance bottlenecks and resource inefficiencies
- Security vulnerabilities and data handling issues

### 📌 GitHub Issues Review and Management

**Regular Issue Maintenance:**
- Review all open issues in the repository systematically
- Update titles, descriptions, and priorities for clarity and consistency
- Merge duplicates or related topics into consolidated issues
- Close issues that are resolved, outdated, or no longer relevant
- Flag incomplete issues needing further clarification
- Ensure all issues have proper labels, milestones, and assignees
- Create issue templates for consistent reporting

**Issue Quality Standards:**
- Clear, actionable titles following conventional formats
- Detailed descriptions with acceptance criteria
- Proper categorization (bug, feature, enhancement, docs, etc.)
- Priority levels based on impact and urgency
- References to related issues, PRs, or documentation
- Step-by-step reproduction instructions for bugs

### 🧹 Repository Cleanup Tasks

**File System Auditing:**
- Audit the root folder for unnecessary, misnamed, or temporary files
- Remove clutter (.DS_Store, .xcuserstate, .env.example.old, unused files)
- Identify and archive obsolete documentation or code samples
- Ensure consistent file naming conventions across the repository
- Validate directory structure follows project conventions

**Proposed Clean Swift Repository Structure:**
```
ProjectName/
├── Sources/              # Main source code (SPM target)
│   ├── Models/          # Data models and business logic
│   ├── Views/           # UI components and screens
│   ├── Services/        # Background services and APIs
│   ├── Extensions/      # Swift extensions and utilities
│   └── Resources/       # Assets, localizations, configs
├── Tests/               # Test suite
│   ├── UnitTests/      # Unit tests for models/services
│   ├── UITests/        # UI automation tests
│   └── TestResources/  # Test fixtures and mocks
├── docs/                # Project documentation
├── scripts/             # Build and development scripts
├── .github/             # GitHub workflows and templates
├── Package.swift        # SPM configuration
├── .gitignore          # Git ignore rules
├── .swiftlint.yml      # Linting configuration
├── .swiftformat        # Formatting configuration
├── Makefile            # Development commands
└── README.md           # Project overview
```

### 📈 Prioritization Framework

**Base Recommendations On:**
- Code clarity, scalability, and maintainability impact
- Swift 6.0+ best practices and concurrency model compliance
- Developer productivity and onboarding experience improvement
- Avoidance of future technical debt accumulation
- Performance and resource usage optimization
- Security and privacy compliance requirements
- Accessibility and user experience considerations

**Priority Matrix:**
- **Critical**: Security vulnerabilities, build failures, data corruption risks
- **High**: Performance issues, concurrency violations, architectural debt
- **Medium**: Code style inconsistencies, documentation gaps, test coverage
- **Low**: Cosmetic improvements, optional optimizations, nice-to-have features

### 🧰 General Development Recommendations

**SwiftLint/SwiftFormat Rule Suggestions:**
- Enable strict concurrency rules for Swift 6.0 compliance
- Enforce consistent code style and naming conventions
- Set appropriate line length and file size limits
- Configure custom rules for project-specific patterns
- Enable accessibility and performance-related rules

**Modularization Opportunities:**
- Convert logical components into Swift Packages for reusability
- Separate core business logic from UI presentation layers
- Create shared libraries for common functionality
- Implement plugin architectures for extensible components
- Design framework boundaries with clear API contracts

**Testing Strategy Improvements:**
- Identify coverage gaps and create comprehensive test plans
- Optimize slow tests and eliminate test smells
- Implement proper mocking and dependency injection
- Add performance and stress testing for critical paths
- Create integration tests for external service dependencies

**Dependency Management:**
- Audit for unused packages and remove unnecessary dependencies
- Ensure proper version pinning and lock file management
- Evaluate dependency security and maintenance status
- Consider alternatives for heavy or poorly maintained packages
- Document dependency rationale and upgrade strategies

**Documentation Gaps:**
- Comprehensive README with clear setup instructions
- Public API documentation with code examples
- Onboarding guides for new contributors
- Architecture decision records (ADRs)
- Troubleshooting guides and FAQs
- Code style guides and contribution guidelines

### 📚 Reference Standards

**Swift API Design Guidelines:**
- Follow Apple's naming conventions and design patterns
- Use clear, descriptive names that convey intent
- Prefer value types over reference types where appropriate
- Design for clarity at the point of use
- Maintain API compatibility and evolution strategies

**Swift 6.0+ Concurrency Model:**
- Use @MainActor for UI components and main thread operations
- Implement proper actor boundaries for data isolation
- Ensure Sendable compliance for shared data types
- Leverage structured concurrency with async/await patterns
- Handle concurrency errors and cancellation gracefully

**Modern Architectural Patterns:**
- MVVM with SwiftUI and Combine/Observation framework
- Protocol-oriented programming for flexibility and testability
- Dependency injection for loose coupling and testing
- Repository pattern for data access abstraction
- Command pattern for undoable operations

**Clean Code Principles:**
- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **DRY**: Don't Repeat Yourself - extract common functionality
- **KISS**: Keep It Simple, Stupid - prefer simple solutions
- **YAGNI**: You Aren't Gonna Need It - avoid premature optimization
- **Composition over Inheritance**: Favor composition and protocols

**Apple Development Idioms:**
- Study Apple sample projects and development frameworks
- Follow Human Interface Guidelines for macOS applications
- Implement proper accessibility support with VoiceOver
- Use system-provided components and design patterns
- Respect user privacy and system resource constraints

### 🎯 Implementation Workflow

**Pre-Development Phase:**
1. Conduct comprehensive codebase review using above criteria
2. Create prioritized backlog of improvement tasks
3. Establish coding standards and quality gates
4. Set up development tooling and automation

**Development Phase:**
1. Follow systematic review practices for all changes
2. Apply quality checkpoints at each stage
3. Maintain documentation and issue tracking
4. Ensure all changes meet established standards

**Post-Development Phase:**
1. Conduct final review against all criteria
2. Update documentation and close related issues
3. Prepare prioritized recommendations for next iteration
4. Gather metrics and feedback for process improvement

## Testing Approaches

### SuperClaude
- **Comprehensive Tests**: Full framework validation
- **Component Tests**: Individual module testing
- **Performance Tests**: Resource usage and timing
- **Integration Tests**: Hook and MCP server coordination

### Outdoor Gear Shop
- **Manual Testing**: Component and page functionality
- **Performance Testing**: Lighthouse scores and Core Web Vitals
- **SEO Validation**: Meta tags and structured data
- **Accessibility Testing**: WCAG compliance
- **Cross-Browser**: Multi-browser compatibility

### Pylon
- **Unit Testing**: XCTest for widget logic and data services
- **UI Testing**: XCUITest for user interaction workflows
- **Performance Testing**: Xcode Instruments for CPU, memory, and responsiveness
- **Integration Testing**: EventKit and AppleScript integration validation
- **Accessibility Testing**: VoiceOver and keyboard navigation validation

## Code Style Preferences

### SuperClaude
- **Python**: PEP 8 compliance with type hints
- **Documentation**: Comprehensive inline and framework docs
- **Error Handling**: Graceful degradation with logging
- **Modularity**: Clear separation of concerns

### Outdoor Gear Shop
- **TypeScript**: Strict type checking enabled
- **Styling**: Tailwind CSS with design system approach
- **Components**: Functional components with hooks
- **Performance**: Optimized bundles and lazy loading

### Pylon
- **Swift 6.0**: Strict concurrency compliance with @MainActor and actor usage
- **SwiftUI**: Declarative UI with @Observable and @State property wrappers
- **Architecture**: Protocol-oriented design with clear separation of concerns
- **Documentation**: Comprehensive inline documentation for public APIs
- **Error Handling**: Graceful error handling with user-friendly fallbacks

## Brand Guidelines

### Outdoor Gear Shop (Trail Gear Lab Brand)
- **Voice**: Confident, technical, human, inclusive
- **Tone Adjustments**: Aspirational (homepage), clear (products), informative (editorial)
- **Messaging**: Clarity, precision, inclusivity, responsibility, simplicity
- **Forbidden Phrases**: "Lab-tested", "revolutionary", "game-changing", "best in class"
- **Preferred Language**: "Field-proven", "trusted by", "built for", "designed to"