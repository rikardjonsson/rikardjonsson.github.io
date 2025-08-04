# Issue #1: Create Core App Architecture and Project Structure

**Priority: 1** | **Label: infra** | **Milestone: v0.1**

## Description
Set up the foundational SwiftUI app structure with Swift 6.0 compliance, including the main app entry point, core data models, and modular architecture.

## Requirements
- Xcode 16+ project with Swift 6.0
- SwiftUI app lifecycle
- Core data models for widgets and settings
- Modular folder structure

## Dependencies
- macOS 15.0+ target
- Swift 6.0 strict concurrency

## Acceptance Criteria
- [ ] Xcode project created with proper structure
- [ ] Swift 6.0 strict concurrency enabled
- [ ] Basic SwiftUI app lifecycle implemented
- [ ] Core data models defined
- [ ] Folder structure follows architecture guidelines
- [ ] Project builds and runs successfully

## Implementation Notes
```swift
@main
struct PylonApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

@MainActor
@Observable
class AppState {
    var selectedTheme: Theme = .system
    var isKeyboardNavigationEnabled = true
    var widgetLayout: WidgetLayout = .grid
}
```

## Project Structure
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

## Definition of Done
- Project structure is complete and documented
- All Swift 6.0 strict concurrency warnings resolved
- Basic app launches without errors
- Architecture documentation updated
- Ready for widget system implementation