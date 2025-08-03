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
- **Theme System**: Glass-style visuals with dark/light mode and customizable themes
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