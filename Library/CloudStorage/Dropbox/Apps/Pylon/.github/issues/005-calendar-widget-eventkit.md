# Issue #5: Implement Calendar Widget with EventKit Integration

**Priority: 5** | **Label: feature** | **Milestone: v0.1**

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

## Implementation Notes
```swift
import EventKit

@MainActor
@Observable
class CalendarWidget: Widget {
    let id = UUID()
    let title = "Calendar"
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
```

## Technical Considerations
- Handle EventKit permission states gracefully
- Implement efficient event fetching (today only initially)
- Support for all-day events and timed events
- Handle recurring events properly
- Efficient refresh strategy (avoid over-fetching)

## UI/UX Requirements
- Clean, scannable list of today's events
- Show event time, title, and calendar color
- Indicate current/upcoming events
- Handle empty state (no events today)
- Loading and error states
- Support for event details on hover/click

## Permission Handling
- Request calendar access on first use
- Graceful fallback when permission denied
- Clear explanation of why permission is needed
- Link to system preferences for permission changes

## Performance Targets
- Widget refresh < 500ms
- Memory efficient event storage
- Background refresh every 15 minutes
- Minimal CPU usage when idle

## Testing Strategy
- Mock EventKit for unit tests
- Test permission flows
- Test event parsing and display
- Integration tests with real calendar data
- Performance tests for large event sets

## Definition of Done
- Calendar widget displays today's events correctly
- EventKit integration is robust and performant
- Permission handling is user-friendly
- Widget integrates seamlessly with widget system
- All tests passing and documented