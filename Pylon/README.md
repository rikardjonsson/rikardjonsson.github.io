# Pylon - macOS Productivity Dashboard

A next-generation macOS productivity dashboard that transforms how you interact with your daily digital workflow. Built with SwiftUI and Swift 6.0, Pylon integrates deeply with the macOS ecosystem to provide a unified command center for your productivity data.

## Overview

Pylon aggregates information from across your Mac's ecosystem—calendar events, reminders, notes, emails, system resources, and more—into a single, beautifully designed interface. Unlike traditional productivity apps that force context-switching, Pylon brings everything to you with native macOS integration.

### Key Features

🧠 **Productivity Widgets**
- Calendar events with EventKit integration
- Reminders with real-time synchronization
- Notes integration via AppleScript
- Email overview from Mail.app
- Quick Add with natural language parsing

🌍 **Information & System Widgets**
- Weather with WeatherKit
- World Clock with multiple time zones
- RSS Feed Reader
- System Resources monitoring (CPU, RAM, Disk)
- Battery, Network, Audio status

🖥️ **Deep System Integration**
- Menu bar presence
- Full keyboard navigation
- Drag & drop support
- Notification monitoring
- Shortcuts integration
- AppleScript automation

🧩 **Modern UI/UX**
- Grid layout with resizable widgets
- Glass-style visual effects
- Focus Mode integration
- Light/Dark mode support
- Customizable themes

## Technical Specifications

- **Platform**: macOS 15.0+
- **Language**: Swift 6.0
- **Framework**: SwiftUI with App lifecycle
- **Architecture**: Protocol-based widget system with strict concurrency
- **Performance**: <2s boot, <1s refresh, <5% CPU, <100MB RAM

## Project Structure

```
Pylon/
├── Pylon.xcodeproj/
├── Pylon/
│   ├── PylonApp.swift           # Main app entry point
│   ├── Models/                  # Core data models
│   ├── Views/                   # SwiftUI views
│   ├── Widgets/                 # Widget implementations
│   ├── Services/                # Background services & APIs
│   ├── Themes/                  # Theme system
│   └── Extensions/              # Swift extensions
├── PylonTests/                  # Unit tests
├── PylonUITests/               # UI tests
├── docs/                       # Documentation
└── .github/                    # GitHub workflows and issues
```

## Development Setup

### Prerequisites
- Xcode 16+
- macOS 15.0+
- Apple Developer Account (for WeatherKit and App Store distribution)

### Getting Started
```bash
# Clone the repository
git clone https://github.com/rikardjonsson/Pylon.git
cd Pylon

# Open in Xcode
open Pylon.xcodeproj

# Build and run (⌘+R)
```

### Required Permissions
Pylon requires several system permissions for full functionality:
- **Calendar**: EventKit access for calendar and reminders
- **Automation**: AppleScript execution for Notes and Mail integration
- **Location**: Core Location for weather data
- **Notifications**: User notifications for updates and alerts

## Architecture

### Widget System
Pylon uses a protocol-based widget architecture for modularity and extensibility:

```swift
protocol Widget: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var isRefreshing: Bool { get }
    var lastUpdated: Date? { get }
    
    @MainActor func refresh() async throws
    @MainActor func body() -> AnyView
}
```

### Concurrency Model
Built with Swift 6.0 strict concurrency:
- `@MainActor` for UI components
- `actor` types for background services
- `@unchecked Sendable` for system integrations

### Integration Layers
- **EventKit**: Calendar and reminders with real-time sync
- **AppleScript**: Notes and Mail.app integration via Process execution
- **WeatherKit**: Current conditions and forecasts
- **System APIs**: CPU, memory, disk, and network monitoring

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| Cold Boot | < 2 seconds | App launch to first render |
| Widget Refresh | < 1 second | Data fetch to UI update |
| CPU Usage | < 5% idle | Background monitoring |
| Memory Usage | < 100MB | Runtime memory footprint |

## Contributing

We welcome contributions! Please see our [contributing guidelines](CONTRIBUTING.md) for details on:
- Code style and conventions
- Testing requirements
- Pull request process
- Issue reporting

## Development Roadmap

### v0.1 - Core Foundation
- [x] Project setup and architecture
- [ ] Widget protocol system
- [ ] Basic UI with grid layout
- [ ] Theme system foundation

### v0.5 - Essential Features
- [ ] Calendar and Reminders widgets
- [ ] Notes and Email integration
- [ ] Weather and system monitoring
- [ ] Keyboard navigation
- [ ] Menu bar integration

### v1.0 - Production Ready
- [ ] Plugin system
- [ ] Advanced customization
- [ ] App Store submission
- [ ] Comprehensive accessibility

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/rikardjonsson/Pylon/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rikardjonsson/Pylon/discussions)
- **Documentation**: [docs/](docs/)

---

Built with ❤️ for the macOS community