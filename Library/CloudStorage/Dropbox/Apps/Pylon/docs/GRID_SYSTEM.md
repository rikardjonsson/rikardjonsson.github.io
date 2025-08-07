# Pylon Grid System v2.0

A next-generation, protocol-oriented grid layout system for SwiftUI built with Swift 6.0 strict concurrency compliance and modular architecture.

## 🚀 Features

- **Protocol-Oriented Architecture**: Extensible widget system with clean interfaces
- **Tetris-Style Layout**: Intelligent placement algorithm that fills gaps efficiently  
- **Swift 6.0 Compliant**: Full concurrency safety with @MainActor and Sendable
- **Drag & Drop**: Enhanced gesture handling with visual feedback and validation
- **Persistence**: Save/load layouts with JSON serialization
- **Performance Optimized**: Virtualization, reduced animations, and memory monitoring
- **Type-Safe**: Comprehensive error handling and boundary validation

## 📁 Architecture Overview

```
GridSystem/
├── Core/                   # Core data types and configuration
│   ├── GridPosition.swift     # Grid coordinate system
│   ├── GridSize.swift         # Widget size definitions
│   ├── GridBounds.swift       # Grid boundary constraints
│   └── GridConfiguration.swift # Layout configuration
├── Protocols/              # Protocol definitions
│   ├── GridWidget.swift       # Main widget protocol
│   ├── LayoutEngine.swift     # Placement algorithm interface
│   └── CollisionDetector.swift # Collision detection interface
├── Engines/                # Layout algorithms
│   ├── TetrisLayoutEngine.swift # Tetris-style placement
│   └── SimpleCollisionDetector.swift # Basic collision detection
├── Managers/               # Orchestration layer
│   └── GridManager.swift      # Central grid coordinator
├── Views/                  # SwiftUI components
│   ├── GridContainerView.swift # Main grid container
│   ├── WidgetContainerView.swift # Individual widget wrapper
│   ├── DragPreviewView.swift   # Enhanced drag feedback
│   └── LayoutManagerView.swift # Layout management UI
├── Persistence/            # Data persistence
│   └── GridLayoutPersistence.swift # Save/load layouts
├── Performance/            # Optimization tools
│   └── GridPerformanceOptimizer.swift # Performance monitoring
├── Adapters/              # Legacy compatibility
│   └── WidgetAdapter.swift    # Bridge old widgets to new system
├── Tests/                 # Test suite
│   └── GridSystemTests.swift  # Comprehensive tests
└── README.md              # This documentation
```

## 🏗️ Core Components

### Grid Coordinate System

```swift
// Position in the grid
struct GridPosition: Hashable, Codable, Sendable {
    let row: Int
    let column: Int
    static let zero = GridPosition(row: 0, column: 0)
}

// Widget dimensions
struct GridSize: Hashable, Codable, Sendable {
    let width: Int   // Number of columns
    let height: Int  // Number of rows
    
    static let small = GridSize(width: 1, height: 1)
    static let medium = GridSize(width: 2, height: 2)  
    static let large = GridSize(width: 4, height: 2)
}
```

### Widget Protocol

```swift
protocol GridWidget: Identifiable, Sendable {
    var id: UUID { get }
    var size: GridSize { get set }
    var position: GridPosition { get set }
    var title: String { get }
    var category: GridWidgetCategory { get }
    var isEnabled: Bool { get set }
    
    @MainActor func refresh() async throws
    @MainActor func body(theme: any Theme, configuration: GridConfiguration) -> AnyView
}
```

## 🎯 Usage Examples

### Creating a Custom Widget

```swift
struct MyCustomWidget: GridWidget {
    let id = UUID()
    var size: GridSize = .medium
    var position: GridPosition = .zero
    let title = "My Widget"
    let category = GridWidgetCategory.utilities
    var isEnabled: Bool = true
    
    var lastUpdated: Date?
    var isLoading: Bool = false
    var error: (any Error)? = nil
    
    @MainActor
    func refresh() async throws {
        // Refresh widget data
    }
    
    @MainActor  
    func body(theme: any Theme, configuration: GridConfiguration) -> AnyView {
        AnyView(
            VStack {
                Text("Custom Content")
                    .foregroundStyle(theme.primaryColor)
            }
        )
    }
}
```

### Setting Up the Grid

```swift
struct MyGridView: View {
    @State private var gridManager = GridManager(configuration: .standard)
    
    var body: some View {
        GridContainerView(
            configuration: .standard,
            theme: MyTheme(),
            widgets: [
                MyCustomWidget(),
                AnotherWidget()
            ]
        )
    }
}
```

### Managing Layouts

```swift
struct LayoutManagementView: View {
    @State private var layoutManager: GridLayoutPersistence
    
    init() throws {
        self._layoutManager = State(initialValue: try GridLayoutPersistence())
    }
    
    var body: some View {
        VStack {
            // Save current layout
            Button("Save Layout") {
                try? layoutManager.saveLayout(gridManager, name: "My Layout")
            }
            
            // Load saved layouts
            ForEach(layoutManager.savedLayouts) { layout in
                Button("Load \(layout.name)") {
                    try? layoutManager.loadLayout(layout, into: gridManager)
                }
            }
        }
    }
}
```

## 🔧 Configuration

### Grid Configuration

```swift
struct GridConfiguration: Hashable, Codable, Sendable {
    let cellSize: CGFloat = 80          // Base cell size
    let cellSpacing: CGFloat = 12       // Space between cells
    let bounds: GridBounds              // Grid boundaries
    let padding: EdgeInsets             // Container padding
    
    static let standard = GridConfiguration(
        bounds: GridBounds(columns: 8, rows: Int.max),
        padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    )
}
```

### Performance Optimization

```swift
@Observable
class GridPerformanceOptimizer {
    // Auto-adjusts based on render performance
    private(set) var reducedAnimations = false
    
    func optimizedAnimationDuration(base: Double) -> Double {
        return reducedAnimations ? base * 0.5 : base
    }
    
    func optimizedSpringAnimation() -> Animation {
        return reducedAnimations ? 
            .easeInOut(duration: 0.25) : 
            .spring(response: 0.5, dampingFraction: 0.8)
    }
}
```

## 🎨 Theming

The grid system integrates with Pylon's theme system:

```swift
protocol Theme: Sendable {
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
    // ... additional theme properties
}
```

Widgets automatically adapt to theme changes through the `body(theme:configuration:)` method.

## 🚦 Widget Categories

```swift
enum GridWidgetCategory: String, CaseIterable, Codable, Sendable {
    case productivity = "Productivity"    // Tasks, calendars, notes
    case information = "Information"      // Weather, news, stocks  
    case communication = "Communication"  // Email, messages, social
    case entertainment = "Entertainment"  // Music, photos, videos
    case utilities = "Utilities"         // Clock, calculator, tools
    case system = "System"               // Monitoring, diagnostics
    case custom = "Custom"               // User-defined widgets
}
```

Each category has associated:
- **System Image**: SF Symbol for UI representation
- **Color Scheme**: Default gradient colors for theming
- **Behavioral Traits**: Expected refresh patterns and data sources

## 💾 Persistence System

### Auto-Save

```swift
// Enable auto-save with 2-second delay after changes
layoutPersistence.autoSaveLayout(gridManager, name: "Auto-saved Layout")
```

### Manual Save/Load

```swift
// Save current layout
try layoutPersistence.saveLayout(gridManager, name: "My Custom Layout")

// Load saved layout
if let layout = layoutPersistence.mostRecentLayout {
    try layoutPersistence.loadLayout(layout, into: gridManager)
}
```

### Import/Export

```swift
// Export to JSON
let jsonData = try layoutPersistence.exportLayout(savedLayout)

// Import from JSON
let importedLayout = try layoutPersistence.importLayout(from: jsonData)
```

## 🎮 Drag & Drop System

### Enhanced Visual Feedback

- **Drop Zone Indicators**: Visual guides showing valid placement areas
- **Collision Validation**: Real-time feedback for invalid placements  
- **Smooth Animations**: Spring-based physics for natural movement
- **Haptic Feedback**: System sound integration for macOS

### Gesture Handling

```swift
// Enhanced drag gesture with automatic grid snapping
DragGesture(coordinateSpace: .named("GridContainer"))
    .onChanged { value in
        // Update drag preview position
        let gridPosition = gridManager.gridPosition(from: value.location)
        updateDragPreview(position: gridPosition)
    }
    .onEnded { value in
        // Validate and commit placement
        if let targetPosition = calculateDropPosition(value.location),
           gridManager.canPlaceWidget(widget, at: targetPosition) {
            gridManager.moveWidget(id: widget.id, to: targetPosition)
        }
    }
```

## 📊 Performance Monitoring

### Real-Time Metrics

- **Render Time**: Track frame render duration  
- **Memory Usage**: Monitor system memory consumption
- **Widget Count**: Optimize based on active widgets
- **Drag Latency**: Measure gesture responsiveness

### Automatic Optimization

The system automatically enables performance mode when:
- Render time exceeds 16ms (60 FPS threshold)
- Widget count exceeds 30 active widgets
- Memory usage grows beyond optimal levels

Performance mode features:
- **Reduced Animations**: 50% faster animation durations
- **Widget Virtualization**: Off-screen widget culling
- **Optimized Redraws**: Minimal UI updates during drag operations

## 🧪 Testing

### Test Coverage

- **Unit Tests**: Core grid logic and algorithms
- **Integration Tests**: End-to-end workflows  
- **Performance Tests**: Stress testing with many widgets
- **Error Handling**: Boundary conditions and edge cases

### Running Tests

```bash
# Run all grid system tests
xcodebuild test -scheme Pylon -testPlan GridSystemTests

# Run specific test class
xcodebuild test -scheme Pylon -only-testing:PylonTests/GridSystemTests
```

## 🔄 Migration Guide

### From Legacy TetrisGrid

The new system replaces the old `TetrisGrid` with a more modular approach:

```swift
// Old approach
TetrisGrid(widgets: widgetContainers)

// New approach  
GridContainerView(
    configuration: .standard,
    theme: theme,
    widgets: adaptedWidgets
)
```

### Widget Adapter

Legacy widgets can be adapted using `WidgetContainerAdapter`:

```swift
let legacyWidgets = appState.widgetManager.enabledContainers()
let adaptedWidgets = WidgetAdapterFactory.adapt(legacyWidgets)
```

## 🛣️ Roadmap

### Planned Features

- **Multi-Grid Support**: Multiple independent grids
- **Widget Grouping**: Logical widget collections  
- **Advanced Layouts**: Masonry, waterfall, and custom algorithms
- **Cloud Sync**: Cross-device layout synchronization
- **Widget Marketplace**: Downloadable widget packages
- **Advanced Animations**: Particle effects and transitions

### Performance Goals

- **Sub-16ms Renders**: Maintain 60+ FPS with 50+ widgets
- **Memory Efficiency**: <100MB baseline memory usage
- **Cold Start**: <2 seconds from launch to first render
- **Background Efficiency**: <1% CPU usage when idle

## 🤝 Contributing

### Adding New Widgets

1. Implement `GridWidget` protocol
2. Add to widget factory in `WidgetAdapter.swift`  
3. Include in widget category mapping
4. Add comprehensive tests
5. Update documentation

### Adding New Layout Engines

1. Implement `LayoutEngine` protocol
2. Add collision detection support
3. Integrate with `GridManager`
4. Performance test with various configurations
5. Document algorithm characteristics

### Code Style

- Follow Swift API Design Guidelines
- Use `@MainActor` for UI components
- Ensure `Sendable` compliance for shared data
- Prefer composition over inheritance
- Write comprehensive tests for new features

## 📄 License

This grid system is part of the Pylon project and follows the same licensing terms.

## 🆘 Troubleshooting

### Common Issues

**Widgets not appearing:**
- Check widget `isEnabled` property
- Verify grid bounds accommodate widget size
- Ensure no collision with existing widgets

**Performance issues:**
- Enable performance monitoring overlay
- Check widget count and complexity
- Consider reducing animation complexity
- Use widget virtualization for large grids

**Drag & drop not working:**
- Verify coordinate space is set correctly
- Check collision detection is properly configured
- Ensure widgets have valid positions

**Persistence failures:**
- Check file system permissions
- Verify JSON encoding/decoding compatibility  
- Ensure widget types can be reconstructed

### Debug Tools

```swift
// Enable performance monitoring
let optimizer = GridPerformanceOptimizer()
print(optimizer.performanceDebugInfo)

// Debug grid state
print("Widgets: \(gridManager.widgets.count)")
print("Occupied positions: \(gridManager.occupiedPositions)")

// Test widget placement
let canPlace = gridManager.canPlaceWidget(widget, at: position)
print("Can place widget at \(position): \(canPlace)")
```

---

**Built with ❤️ for the Pylon project**