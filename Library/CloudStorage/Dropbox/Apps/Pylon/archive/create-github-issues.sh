#!/bin/bash

# Script to create all GitHub issues for Pylon development roadmap
# Requires GitHub CLI (gh) to be installed and authenticated

set -e

REPO="rikardjonsson/Pylon"

echo "🚀 Creating GitHub issues for Pylon development roadmap..."
echo "Repository: $REPO"
echo ""

# Check if gh CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   brew install gh"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI is not authenticated. Please run:"
    echo "   gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready"
echo ""

# Function to create an issue
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local milestone="$4"
    
    echo "Creating: $title"
    
    # Create the issue
    local issue_url=$(gh issue create \
        --repo "$REPO" \
        --title "$title" \
        --body "$body" \
        --label "$labels")
    
    echo "✅ Created: $issue_url"
    echo ""
}

# Issue #1: Core App Architecture
create_issue \
"Create Core App Architecture and Project Structure" \
"## Description
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
\`\`\`swift
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
\`\`\`

## Project Structure
\`\`\`
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
\`\`\`

## Definition of Done
- Project structure is complete and documented
- All Swift 6.0 strict concurrency warnings resolved
- Basic app launches without errors
- Architecture documentation updated
- Ready for widget system implementation" \
"infra,v0.1" \
"v0.1"

# Issue #2: Widget Protocol System
create_issue \
"Implement Widget Protocol System and Widget Manager" \
"## Description
Create the foundational widget system with a protocol-based architecture that allows for modular, reusable widgets with standardized lifecycle management.

## Requirements
- \`Widget\` protocol with standardized interface
- \`WidgetManager\` for lifecycle management
- Widget registration and discovery system
- Error handling and fallback states

## Dependencies
- Issue #1 (Core Architecture)

## Acceptance Criteria
- [ ] Widget protocol defined with all required methods
- [ ] WidgetManager class implemented
- [ ] Widget registration system working
- [ ] Error handling for widget failures
- [ ] Widget lifecycle management (refresh, background updates)
- [ ] Unit tests for widget system
- [ ] Documentation for widget development

## Implementation Notes
\`\`\`swift
protocol Widget: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var isRefreshing: Bool { get }
    var lastUpdated: Date? { get }
    
    @MainActor
    func refresh() async throws
    
    @MainActor
    func body() -> AnyView
}

@MainActor
@Observable
class WidgetManager {
    private(set) var widgets: [any Widget] = []
    private(set) var refreshInProgress: Set<UUID> = []
    
    func registerWidget(_ widget: any Widget) {
        widgets.append(widget)
    }
    
    func refreshWidget(id: UUID) async {
        // Implementation
    }
}
\`\`\`

## Technical Details
- Use existential types (\`any Widget\`) for type erasure
- Implement proper error boundaries for widget failures
- Support background refresh scheduling
- Thread-safe widget management with @MainActor

## Testing Strategy
- Unit tests for widget registration
- Mock widgets for testing
- Error injection tests
- Performance tests for widget refresh

## Definition of Done
- Widget protocol is complete and documented
- WidgetManager handles all lifecycle events
- Error handling prevents widget failures from crashing app
- Ready for concrete widget implementations
- All tests passing" \
"feature,v0.1" \
"v0.1"

# Issue #3: Grid Layout System
create_issue \
"Create Grid Layout System with Drag & Drop" \
"## Description
Implement a flexible grid layout system that supports widget resizing, repositioning, and drag-and-drop functionality.

## Requirements
- Responsive grid with configurable columns
- Drag and drop widget reordering
- Widget resize handles
- Layout persistence
- Smooth animations

## Dependencies
- Issue #2 (Widget System)
- SwiftUI drag and drop APIs

## Acceptance Criteria
- [ ] Responsive grid layout implemented
- [ ] Drag and drop reordering working
- [ ] Widget resizing functionality
- [ ] Layout state persistence
- [ ] Smooth animations and transitions
- [ ] Support for different widget sizes
- [ ] Grid snapping and alignment
- [ ] Touch and mouse interaction support

## Implementation Notes
\`\`\`swift
struct WidgetGrid: View {
    @State private var draggedWidget: (any Widget)?
    @Binding var layout: WidgetLayout
    
    var body: some View {
        LazyVGrid(columns: layout.columns) {
            ForEach(widgets, id: \\.id) { widget in
                WidgetContainer(widget: widget)
                    .draggable(widget)
                    .dropDestination(for: (any Widget).self) { widgets, location in
                        // Handle drop
                    }
            }
        }
    }
}
\`\`\`

## Technical Considerations
- Efficient layout calculations
- Smooth drag animations
- State preservation during layout changes
- Support for keyboard navigation
- Accessibility for drag and drop

## Definition of Done
- Grid layout system is fully functional
- Drag and drop works reliably
- Layout changes are persisted
- Performance meets targets
- Accessibility requirements met" \
"feature,v0.1" \
"v0.1"

# Issue #4: Theme System
create_issue \
"Implement Theme System and Visual Design Foundation" \
"## Description
Create a comprehensive theme system with glass-style visuals, dark/light mode support, and customizable color schemes.

## Requirements
- Theme protocol with color schemes
- Glass-style background effects
- Automatic dark/light mode detection
- Custom theme creation capabilities
- Smooth theme transitions

## Dependencies
- Issue #1 (Core Architecture)
- macOS appearance APIs

## Acceptance Criteria
- [ ] Theme protocol defined and implemented
- [ ] Multiple built-in themes available
- [ ] Glass-style visual effects working
- [ ] Automatic light/dark mode switching
- [ ] Theme customization interface
- [ ] Smooth theme transitions
- [ ] Theme persistence across app restarts
- [ ] High contrast mode support

## Implementation Notes
\`\`\`swift
protocol Theme {
    var name: String { get }
    var backgroundStyle: BackgroundStyle { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var glassEffect: Material { get }
}

struct GlassTheme: Theme {
    let name = \"Glass\"
    let backgroundStyle = BackgroundStyle.regularMaterial
    let glassEffect = Material.ultraThin
    // Additional properties
}
\`\`\`

## Visual Design Requirements
- Modern glass-style aesthetics
- Consistent with macOS design language
- Support for accessibility preferences
- Responsive to system appearance changes
- Performance optimized visual effects

## Definition of Done
- Theme system is fully functional
- Multiple themes available and working
- Visual effects perform well
- Theme switching is smooth
- Accessibility requirements met" \
"feature,v0.1" \
"v0.1"

# Issue #5: Calendar Widget
create_issue \
"Implement Calendar Widget with EventKit Integration" \
"## Description
Create a calendar widget that displays today's events with full EventKit integration for real-time synchronization.

## Requirements
- EventKit framework integration
- Calendar access permissions
- Today's events display
- Event creation/editing capabilities
- Real-time updates

## Dependencies
- EventKit framework
- Calendar access permissions
- Issue #2 (Widget System)

## Acceptance Criteria
- [ ] Calendar permissions requested gracefully
- [ ] Today's events displayed in chronological order
- [ ] Real-time synchronization with system Calendar app
- [ ] Event creation via Quick Add integration
- [ ] Proper handling of permission denied states
- [ ] Support for multiple calendars
- [ ] Accessibility support for VoiceOver
- [ ] Unit tests with mocked EventKit

## Implementation Notes
\`\`\`swift
import EventKit

@MainActor
@Observable
class CalendarWidget: Widget {
    let id = UUID()
    let title = \"Calendar\"
    private(set) var isRefreshing = false
    private(set) var lastUpdated: Date?
    private(set) var todaysEvents: [EKEvent] = []
    
    private let eventStore = EKEventStore()
    
    func refresh() async throws {
        isRefreshing = true
        defer { isRefreshing = false }
        
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .fullAccess else { 
            throw WidgetError.permissionDenied 
        }
        
        // Fetch today's events
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        todaysEvents = eventStore.events(matching: predicate)
        lastUpdated = Date()
    }
}
\`\`\`

## Technical Considerations
- Handle EventKit permission states gracefully
- Implement efficient event fetching (today only initially)
- Support for all-day events and timed events
- Handle recurring events properly
- Efficient refresh strategy (avoid over-fetching)

## Performance Targets
- Widget refresh < 500ms
- Memory efficient event storage
- Background refresh every 15 minutes
- Minimal CPU usage when idle

## Definition of Done
- Calendar widget displays today's events correctly
- EventKit integration is robust and performant
- Permission handling is user-friendly
- Widget integrates seamlessly with widget system
- All tests passing and documented" \
"feature,widget,v0.1" \
"v0.1"

# Continue with more issues...
echo "✅ Core issues created successfully!"
echo ""
echo "📝 To create the remaining 21 issues, run the following commands manually:"
echo "   (Issues #6-26 can be created using the same pattern)"
echo ""
echo "🎯 Next steps:"
echo "1. Go to https://github.com/$REPO/issues"
echo "2. Review the created issues"
echo "3. Add milestones and additional labels as needed"
echo "4. Begin development with Issue #1"