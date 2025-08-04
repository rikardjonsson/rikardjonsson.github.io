#!/bin/bash

# Complete script to create all 26 GitHub issues for Pylon development roadmap
# Requires GitHub CLI (gh) to be installed and authenticated

set -e

REPO="rikardjonsson/Pylon"

echo "🚀 Creating all 26 GitHub issues for Pylon development roadmap..."
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
    
    echo "Creating: $title"
    
    # Create the issue
    local issue_url=$(gh issue create \
        --repo "$REPO" \
        --title "$title" \
        --body "$body" \
        --label "$labels")
    
    echo "✅ Created: $issue_url"
    echo ""
    sleep 1  # Rate limiting
}

# Phase 1: Core Infrastructure & App Shell (v0.1)

create_issue \
"Create Core App Architecture and Project Structure" \
"**Priority: 1** | **Label: infra** | **Milestone: v0.1**

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

## Definition of Done
- Project structure is complete and documented
- All Swift 6.0 strict concurrency warnings resolved
- Basic app launches without errors
- Architecture documentation updated
- Ready for widget system implementation" \
"infra,v0.1,priority-1"

create_issue \
"Implement Widget Protocol System and Widget Manager" \
"**Priority: 2** | **Label: feature** | **Milestone: v0.1**

## Description
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

## Definition of Done
- Widget protocol is complete and documented
- WidgetManager handles all lifecycle events
- Error handling prevents widget failures from crashing app
- Ready for concrete widget implementations
- All tests passing" \
"feature,v0.1,priority-2"

create_issue \
"Create Grid Layout System with Drag & Drop" \
"**Priority: 3** | **Label: feature** | **Milestone: v0.1**

## Description
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

## Definition of Done
- Grid layout system is fully functional
- Drag and drop works reliably
- Layout changes are persisted
- Performance meets targets
- Accessibility requirements met" \
"feature,v0.1,priority-3"

create_issue \
"Implement Theme System and Visual Design Foundation" \
"**Priority: 4** | **Label: feature** | **Milestone: v0.1**

## Description
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
}
\`\`\`

## Definition of Done
- Theme system is fully functional
- Multiple themes available and working
- Visual effects perform well
- Theme switching is smooth
- Accessibility requirements met" \
"feature,v0.1,priority-4"

# Phase 2: Productivity Widgets

create_issue \
"Implement Calendar Widget with EventKit Integration" \
"**Priority: 5** | **Label: feature** | **Milestone: v0.1**

## Description
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
"feature,widget,v0.1,priority-5"

create_issue \
"Implement Reminders Widget with EventKit Integration" \
"**Priority: 6** | **Label: feature** | **Milestone: v0.1**

## Description
Create a reminders widget that displays due and overdue tasks with full EventKit integration.

## Requirements
- EventKit reminders access
- Due/overdue reminder filtering
- Reminder completion/creation
- Priority and date sorting
- Real-time synchronization

## Dependencies
- EventKit framework
- Reminders access permissions
- Issue #2 (Widget System)

## Acceptance Criteria
- [ ] Reminders permissions requested gracefully
- [ ] Due and overdue reminders displayed
- [ ] Reminder completion/uncomplete functionality
- [ ] Priority-based sorting and display
- [ ] Real-time sync with system Reminders app
- [ ] Support for multiple reminder lists
- [ ] Quick reminder creation
- [ ] Accessibility support

## Definition of Done
- Reminders widget shows relevant tasks
- EventKit integration works reliably
- Task management functions correctly
- Performance targets met
- Full accessibility support" \
"feature,widget,v0.1,priority-6"

create_issue \
"Implement Notes Widget with AppleScript Integration" \
"**Priority: 7** | **Label: integration** | **Milestone: v0.5**

## Description
Create a notes widget that integrates with the macOS Notes app using AppleScript for reading and creating notes.

## Requirements
- AppleScript execution via Process
- Recent notes display
- Note creation capabilities
- Search functionality
- Error handling for AppleScript failures

## Dependencies
- AppleScript support
- Process execution permissions
- Issue #2 (Widget System)

## Acceptance Criteria
- [ ] AppleScript integration working reliably
- [ ] Recent notes displayed with preview
- [ ] Note creation functionality
- [ ] Basic search capabilities
- [ ] Robust error handling
- [ ] Timeout and retry mechanisms
- [ ] Performance optimization
- [ ] Security considerations for script execution

## Implementation Notes
\`\`\`swift
actor NotesService {
    func fetchRecentNotes() async throws -> [Note] {
        let script = \"\"\"
        tell application \"Notes\"
            set noteList to {}
            repeat with i from 1 to (count of notes)
                set noteList to noteList & {name of note i, body of note i}
            end repeat
            return noteList
        end tell
        \"\"\"
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: \"/usr/bin/osascript\")
        process.arguments = [\"-e\", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        // Parse and return notes
    }
}
\`\`\`

## Definition of Done
- Notes widget integrates seamlessly with Notes app
- AppleScript execution is reliable and secure
- Performance meets targets
- Error handling is comprehensive
- Ready for production use" \
"integration,widget,v0.5,priority-7"

create_issue \
"Implement Email Widget with Mail.app Integration" \
"**Priority: 8** | **Label: integration** | **Milestone: v0.5**

## Description
Create an email widget that shows unread messages from Mail.app using AppleScript integration.

## Requirements
- AppleScript Mail.app integration
- Unread message count and preview
- Message marking capabilities
- Account filtering
- Refresh scheduling

## Dependencies
- AppleScript support
- Mail.app access
- Issue #2 (Widget System)

## Acceptance Criteria
- [ ] Unread email count display
- [ ] Message preview with sender/subject
- [ ] Mark as read/unread functionality
- [ ] Support for multiple email accounts
- [ ] Account filtering options
- [ ] Efficient refresh scheduling
- [ ] Privacy considerations
- [ ] Error handling for Mail.app unavailable

## Definition of Done
- Email widget shows accurate unread counts
- Message management works correctly
- Performance is acceptable
- Privacy requirements met
- Integration is reliable" \
"integration,widget,v0.5,priority-8"

create_issue \
"Implement Quick Add System with Natural Language Parsing" \
"**Priority: 9** | **Label: feature** | **Milestone: v0.5**

## Description
Create a natural language input system for quickly adding calendar events, reminders, and notes with intelligent parsing.

## Requirements
- Natural language date/time parsing
- Context-aware entity extraction
- Multiple output formats (event, reminder, note)
- Keyboard shortcuts for access
- Undo/redo functionality

## Dependencies
- Foundation's NSDataDetector
- Issues #5, #6, #7 (Calendar, Reminders, Notes widgets)

## Acceptance Criteria
- [ ] Natural language parsing for dates/times
- [ ] Entity extraction (location, people, etc.)
- [ ] Smart categorization (event vs reminder vs note)
- [ ] Keyboard shortcut activation
- [ ] Undo/redo support
- [ ] User feedback and confirmation
- [ ] Learning from user corrections
- [ ] Multiple language support

## Implementation Notes
\`\`\`swift
struct QuickAddProcessor {
    func parseInput(_ text: String) -> QuickAddResult {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        var dates: [Date] = []
        detector.enumerateMatches(in: text, range: range) { match, _, _ in
            if let date = match?.date {
                dates.append(date)
            }
        }
        
        return QuickAddResult(
            type: determineType(from: text),
            title: extractTitle(from: text),
            date: dates.first,
            location: extractLocation(from: text)
        )
    }
}
\`\`\`

## Definition of Done
- Natural language parsing works accurately
- Multiple output formats supported
- User experience is intuitive
- Performance is responsive
- Ready for daily use" \
"feature,v0.5,priority-9"

# Phase 3: Information & System Widgets

create_issue \
"Implement Weather Widget with WeatherKit Integration" \
"**Priority: 10** | **Label: feature** | **Milestone: v0.5**

## Description
Create a weather widget using WeatherKit for current conditions and forecasts.

## Requirements
- WeatherKit framework integration
- Location services integration
- Current conditions display
- Multi-day forecast
- Weather alerts

## Dependencies
- WeatherKit framework
- Core Location for user location
- Apple Developer Program membership

## Acceptance Criteria
- [ ] WeatherKit integration working
- [ ] Current weather conditions display
- [ ] Location-based weather data
- [ ] Multi-day forecast view
- [ ] Weather alerts and warnings
- [ ] Temperature, humidity, wind display
- [ ] Weather icons and animations
- [ ] Offline caching for last known conditions

## Definition of Done
- Weather widget displays accurate current conditions
- Location services work reliably
- WeatherKit integration is robust
- UI is informative and attractive
- Performance targets met" \
"feature,widget,v0.5,priority-10"

create_issue \
"Implement System Resources Widget" \
"**Priority: 11** | **Label: feature** | **Milestone: v0.5**

## Description
Create a system monitoring widget that displays CPU, RAM, disk usage, and other system metrics.

## Requirements
- Real-time CPU and memory monitoring
- Disk space tracking
- Network activity indicators
- Temperature monitoring (if available)
- Efficient background updates

## Dependencies
- System framework APIs
- Background refresh scheduling

## Acceptance Criteria
- [ ] CPU usage monitoring and display
- [ ] RAM usage with available/used breakdown
- [ ] Disk space monitoring for main drive
- [ ] Network activity indicators
- [ ] Battery status (for laptops)
- [ ] Temperature readings (if available)
- [ ] Historical graphs/trends
- [ ] Efficient background monitoring

## Implementation Notes
\`\`\`swift
actor SystemMonitor {
    func getCPUUsage() async -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            \$0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         \$0,
                         &count)
            }
        }
        
        return kerr == KERN_SUCCESS ? Double(info.virtual_size) : 0.0
    }
}
\`\`\`

## Definition of Done
- System monitoring is accurate and efficient
- Background updates don't impact performance
- UI clearly shows system status
- Alerts for critical resource usage
- Ready for daily monitoring use" \
"feature,widget,v0.5,priority-11"

create_issue \
"Implement World Clock Widget" \
"**Priority: 12** | **Label: feature** | **Milestone: v0.5**

## Description
Create a world clock widget displaying multiple time zones with customizable city selection.

## Requirements
- Multiple timezone display
- City search and selection
- Automatic daylight saving adjustments
- Compact and expanded views
- Time zone abbreviation display

## Dependencies
- Foundation TimeZone APIs
- Issue #2 (Widget System)

## Acceptance Criteria
- [ ] Multiple time zones displayed simultaneously
- [ ] City search and selection interface
- [ ] Automatic DST handling
- [ ] Compact and expanded view modes
- [ ] Time zone abbreviations shown
- [ ] Customizable city list
- [ ] Real-time clock updates
- [ ] Accessibility support

## Definition of Done
- World clock shows accurate times for selected cities
- Time zone management is user-friendly
- DST transitions handled correctly
- Performance is efficient
- UI is clean and readable" \
"feature,widget,v0.5,priority-12"

create_issue \
"Implement RSS Feed Reader Widget" \
"**Priority: 13** | **Label: feature** | **Milestone: v0.5**

## Description
Create an RSS feed reader widget for displaying news headlines and blog updates.

## Requirements
- RSS/Atom feed parsing
- Multiple feed support
- Article preview and full view
- Feed management interface
- Offline caching

## Dependencies
- Network framework
- XML parsing capabilities
- Issue #2 (Widget System)

## Acceptance Criteria
- [ ] RSS/Atom feed parsing working
- [ ] Multiple feeds supported
- [ ] Article list with headlines
- [ ] Article preview/summary
- [ ] Feed management (add/remove/organize)
- [ ] Offline caching for articles
- [ ] Refresh scheduling
- [ ] Error handling for failed feeds

## Definition of Done
- RSS reader parses feeds correctly
- Multiple feed support works well
- Offline reading capabilities
- Feed management is intuitive
- Performance is acceptable" \
"feature,widget,v0.5,priority-13"

# Phase 4: System Integration

create_issue \
"Implement Menu Bar Integration" \
"**Priority: 14** | **Label: integration** | **Milestone: v0.5**

## Description
Add menu bar presence with quick access to key functions and status indicators.

## Requirements
- NSStatusItem implementation
- Quick actions menu
- Status indicators (unread counts, etc.)
- Preferences access
- Show/hide main window

## Dependencies
- AppKit NSStatusItem
- Issue #1 (Core Architecture)

## Acceptance Criteria
- [ ] Menu bar icon appears when app is running
- [ ] Click to show/hide main window
- [ ] Right-click menu with quick actions
- [ ] Status indicators for unread items
- [ ] Preferences accessible from menu bar
- [ ] Quit option in menu
- [ ] Menu bar integration follows macOS guidelines
- [ ] Works with both light and dark menu bar

## Implementation Notes
\`\`\`swift
@MainActor
class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: \"rectangle.grid.2x2\", accessibilityDescription: \"Pylon\")
            button.action = #selector(menuBarButtonClicked)
            button.target = self
        }
        
        statusItem?.menu = createMenu()
    }
}
\`\`\`

## Definition of Done
- Menu bar icon appears and functions correctly
- All menu items work as expected
- Status indicators update in real-time
- Follows macOS Human Interface Guidelines
- Accessibility requirements met" \
"integration,v0.5,priority-14"

create_issue \
"Implement Comprehensive Keyboard Navigation" \
"**Priority: 15** | **Label: accessibility** | **Milestone: v0.5**

## Description
Ensure full keyboard navigation throughout the application with logical focus management.

## Requirements
- Tab navigation between widgets
- Arrow key navigation within widgets
- Keyboard shortcuts for common actions
- Focus indicators
- Screen reader compatibility

## Dependencies
- SwiftUI accessibility modifiers
- Custom FocusState management

## Acceptance Criteria
- [ ] Tab navigation between all widgets
- [ ] Arrow key navigation within widgets
- [ ] Keyboard shortcuts for common actions
- [ ] Clear focus indicators
- [ ] VoiceOver compatibility
- [ ] Escape key handling
- [ ] Enter key activation
- [ ] Logical focus order

## Implementation Notes
\`\`\`swift
struct KeyboardNavigationView: View {
    @FocusState private var focusedWidget: UUID?
    
    var body: some View {
        ForEach(widgets, id: \\.id) { widget in
            WidgetView(widget: widget)
                .focused(\$focusedWidget, equals: widget.id)
                .onKeyPress(.tab) {
                    focusNextWidget()
                    return .handled
                }
        }
    }
}
\`\`\`

## Definition of Done
- Full keyboard navigation implemented
- Focus management works correctly
- Accessibility standards met
- Keyboard shortcuts documented
- VoiceOver testing completed" \
"accessibility,v0.5,priority-15"

create_issue \
"Implement Shortcuts Integration" \
"**Priority: 16** | **Label: integration** | **Milestone: v0.5**

## Description
Add support for macOS Shortcuts app integration for automation capabilities.

## Requirements
- Shortcuts framework integration
- Intent definitions for common actions
- Siri integration capabilities
- Automation workflows
- Custom shortcut creation

## Dependencies
- Intents framework
- Shortcuts app integration

## Acceptance Criteria
- [ ] Shortcuts framework integrated
- [ ] Intent definitions created
- [ ] Common actions exposed (add event, reminder, note)
- [ ] Siri integration working
- [ ] Custom shortcuts supported
- [ ] Automation workflows possible
- [ ] Documentation for shortcut creation
- [ ] Testing with Shortcuts app

## Definition of Done
- Shortcuts integration works reliably
- Common actions are automatable
- Siri integration functions correctly
- Documentation is complete
- Ready for power user automation" \
"integration,v0.5,priority-16"

create_issue \
"Implement Notification System Integration" \
"**Priority: 17** | **Label: integration** | **Milestone: v0.5**

## Description
Integrate with macOS notification system for updates and alerts.

## Requirements
- UserNotifications framework
- Notification permissions
- Interactive notifications
- Notification scheduling
- Custom notification categories

## Dependencies
- UserNotifications framework
- Notification permissions

## Acceptance Criteria
- [ ] Notification permissions requested
- [ ] Basic notifications working
- [ ] Interactive notifications (reply, snooze)
- [ ] Notification scheduling
- [ ] Custom categories and actions
- [ ] Notification badges
- [ ] Do Not Disturb respect
- [ ] Notification settings interface

## Definition of Done
- Notification system integrated properly
- User permissions handled gracefully
- Interactive features work correctly
- Performance impact is minimal
- User control over notifications" \
"integration,v0.5,priority-17"

# Phase 5: Advanced Features

create_issue \
"Implement Plugin System Architecture" \
"**Priority: 18** | **Label: feature** | **Milestone: v1.0**

## Description
Create a plugin system allowing third-party widget development with secure sandboxing.

## Requirements
- Plugin protocol definition
- Secure plugin loading
- Plugin discovery and management
- API versioning
- Plugin store/distribution

## Dependencies
- Dynamic library loading
- Security frameworks
- Plugin SDK creation

## Acceptance Criteria
- [ ] Plugin protocol defined
- [ ] Secure plugin loading mechanism
- [ ] Plugin discovery system
- [ ] Plugin management interface
- [ ] API versioning support
- [ ] Sandboxing for security
- [ ] Plugin SDK documentation
- [ ] Example plugins created

## Definition of Done
- Plugin system is secure and functional
- Third-party development is possible
- Documentation is comprehensive
- Security requirements met
- Ready for community contributions" \
"feature,v1.0,priority-18"

create_issue \
"Implement Settings Import/Export System" \
"**Priority: 19** | **Label: feature** | **Milestone: v1.0**

## Description
Add capabilities for backing up and restoring user configurations.

## Requirements
- Settings serialization
- Import/export UI
- Version compatibility checking
- Partial setting restoration
- Cloud sync integration

## Dependencies
- JSON/Codable serialization
- File system access

## Acceptance Criteria
- [ ] Settings export to file
- [ ] Settings import from file
- [ ] Version compatibility checking
- [ ] Partial restoration options
- [ ] Cloud sync preparation
- [ ] Migration between versions
- [ ] Backup scheduling options
- [ ] User-friendly interface

## Definition of Done
- Import/export works reliably
- Version compatibility handled
- User data is preserved
- Migration paths are smooth
- Ready for cloud sync integration" \
"feature,v1.0,priority-19"

create_issue \
"Implement Focus Mode Integration" \
"**Priority: 20** | **Label: integration** | **Milestone: v1.0**

## Description
Integrate with macOS Focus modes to adapt widget visibility and behavior.

## Requirements
- Focus mode detection
- Widget filtering based on focus
- Notification suppression
- Custom focus configurations
- Automatic widget layout switching

## Dependencies
- Focus mode APIs (if available)
- System notification monitoring

## Acceptance Criteria
- [ ] Focus mode detection working
- [ ] Widget visibility adapts to focus
- [ ] Notification behavior changes
- [ ] Custom focus configurations
- [ ] Layout switching support
- [ ] Work/personal mode distinctions
- [ ] Productivity tracking integration
- [ ] User customization options

## Definition of Done
- Focus mode integration is seamless
- Widget behavior adapts appropriately
- User productivity is enhanced
- Configuration options are flexible
- Performance impact is minimal" \
"integration,v1.0,priority-20"

# Phase 6: Quality Assurance & Performance

create_issue \
"Implement Performance Monitoring and Optimization" \
"**Priority: 21** | **Label: tech-debt** | **Milestone: v1.0**

## Description
Add comprehensive performance monitoring to ensure app meets performance targets.

## Requirements
- CPU usage tracking
- Memory leak detection
- Cold boot time measurement
- Widget refresh performance
- Background activity monitoring

## Success Criteria
- Cold boot < 2 seconds
- Widget refresh < 1 second
- CPU usage < 5% idle
- RAM usage < 100MB

## Dependencies
- Instruments integration
- Performance testing framework

## Acceptance Criteria
- [ ] Performance monitoring dashboard
- [ ] CPU usage tracking and alerts
- [ ] Memory leak detection
- [ ] Boot time measurement
- [ ] Widget refresh timing
- [ ] Background activity monitoring
- [ ] Performance regression alerts
- [ ] Optimization recommendations

## Definition of Done
- All performance targets met consistently
- Monitoring system is comprehensive
- Regression detection is automatic
- Optimization opportunities identified
- Ready for production deployment" \
"tech-debt,performance,v1.0,priority-21"

create_issue \
"Implement Comprehensive Accessibility Support" \
"**Priority: 22** | **Label: accessibility** | **Milestone: v1.0**

## Description
Ensure full VoiceOver support and accessibility compliance throughout the application.

## Requirements
- VoiceOver navigation
- High contrast mode support
- Reduced motion preferences
- Font size scaling
- Color accessibility

## Dependencies
- Accessibility framework
- VoiceOver testing

## Acceptance Criteria
- [ ] Full VoiceOver support
- [ ] High contrast mode compatibility
- [ ] Reduced motion respect
- [ ] Dynamic font size support
- [ ] Color accessibility compliance
- [ ] Keyboard navigation complete
- [ ] Focus management optimized
- [ ] Accessibility audit passed

## Definition of Done
- All accessibility standards met
- VoiceOver navigation is excellent
- Accessibility audit results clean
- User testing with accessibility users
- Documentation for accessibility features" \
"accessibility,v1.0,priority-22"

create_issue \
"Implement Logging and Debugging System" \
"**Priority: 23** | **Label: infra** | **Milestone: v1.0**

## Description
Add comprehensive logging for debugging and troubleshooting.

## Requirements
- Structured logging system
- Log level configuration
- Crash reporting
- Performance metrics logging
- Privacy-compliant logging

## Dependencies
- OSLog framework
- Crash reporting service

## Acceptance Criteria
- [ ] Structured logging implemented
- [ ] Log level configuration
- [ ] Crash reporting integration
- [ ] Performance metrics logged
- [ ] Privacy compliance verified
- [ ] Log analysis tools
- [ ] Remote logging capabilities
- [ ] Debug information collection

## Definition of Done
- Logging system is comprehensive
- Debugging capabilities are excellent
- Privacy requirements met
- Crash reporting is reliable
- Support workflows improved" \
"infra,v1.0,priority-23"

create_issue \
"App Store Compliance and Submission Preparation" \
"**Priority: 24** | **Label: infra** | **Milestone: v1.0**

## Description
Ensure full App Store compliance and prepare for submission.

## Requirements
- App Store guidelines compliance
- Privacy policy creation
- App sandbox configuration
- Code signing and notarization
- App Store metadata

## Dependencies
- Apple Developer Program
- App Store guidelines review

## Acceptance Criteria
- [ ] App Store guidelines compliance verified
- [ ] Privacy policy created and integrated
- [ ] App sandbox properly configured
- [ ] Code signing working
- [ ] Notarization successful
- [ ] App Store metadata prepared
- [ ] Screenshots and descriptions ready
- [ ] App Store review preparation

## Definition of Done
- App Store submission ready
- All compliance requirements met
- Metadata and assets prepared
- Review process optimized
- Launch strategy defined" \
"infra,app-store,v1.0,priority-24"

# Supporting Infrastructure

create_issue \
"Implement Background Refresh Scheduling" \
"**Priority: 25** | **Label: infra** | **Milestone: v0.5**

## Description
Set up efficient background refresh system using NSBackgroundActivityScheduler.

## Requirements
- Background activity scheduling
- Power-efficient refresh logic
- Network availability checking
- User preference respect
- Battery level awareness

## Dependencies
- NSBackgroundActivityScheduler
- Power management APIs

## Acceptance Criteria
- [ ] Background scheduler implemented
- [ ] Power-efficient refresh logic
- [ ] Network availability checking
- [ ] User preference controls
- [ ] Battery level considerations
- [ ] Refresh interval optimization
- [ ] Background task management
- [ ] Resource usage monitoring

## Definition of Done
- Background refresh works efficiently
- Power consumption is optimized
- User control is comprehensive
- Performance impact is minimal
- Ready for 24/7 operation" \
"infra,v0.5,priority-25"

create_issue \
"Implement Caching System with TTL" \
"**Priority: 26** | **Label: infra** | **Milestone: v0.5**

## Description
Create a sophisticated caching system for widget data with time-to-live management.

## Requirements
- In-memory and persistent caching
- TTL-based expiration
- Cache size management
- Cache invalidation strategies
- Thread-safe operations

## Dependencies
- Foundation caching APIs
- File system access

## Acceptance Criteria
- [ ] In-memory caching implemented
- [ ] Persistent cache storage
- [ ] TTL-based expiration working
- [ ] Cache size limits enforced
- [ ] Invalidation strategies defined
- [ ] Thread-safe operations
- [ ] Cache performance monitoring
- [ ] Storage cleanup mechanisms

## Definition of Done
- Caching system is robust and efficient
- Memory usage is controlled
- Data freshness is maintained
- Performance improvements measured
- Ready for production load" \
"infra,v0.5,priority-26"

echo ""
echo "🎉 All 26 GitHub issues created successfully!"
echo ""
echo "📋 Summary:"
echo "   • Phase 1 (v0.1): Issues #1-4 - Core Infrastructure"
echo "   • Phase 2 (v0.1-v0.5): Issues #5-9 - Productivity Widgets"
echo "   • Phase 3 (v0.5): Issues #10-13 - Information Widgets"
echo "   • Phase 4 (v0.5): Issues #14-17 - System Integration"
echo "   • Phase 5 (v1.0): Issues #18-20 - Advanced Features"
echo "   • Phase 6 (v1.0): Issues #21-24 - Quality & Performance"
echo "   • Infrastructure: Issues #25-26 - Supporting Systems"
echo ""
echo "🎯 Next steps:"
echo "1. Go to https://github.com/$REPO/issues"
echo "2. Review all created issues"
echo "3. Set up milestones (v0.1, v0.5, v1.0)"
echo "4. Begin development with Issue #1: Core App Architecture"
echo ""
echo "🚀 Ready to start building Pylon!"