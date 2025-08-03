# Issue #14: Implement Menu Bar Integration

**Priority: 14** | **Label: integration** | **Milestone: v0.5**

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
```swift
@MainActor
class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "rectangle.grid.2x2", accessibilityDescription: "Pylon")
            button.action = #selector(menuBarButtonClicked)
            button.target = self
        }
        
        statusItem?.menu = createMenu()
    }
    
    @objc private func menuBarButtonClicked() {
        // Toggle main window
    }
}
```

## Menu Structure
```
Pylon
├── Show/Hide Dashboard
├── ──────────────────
├── Quick Add...        ⌘N
├── Refresh All         ⌘R
├── ──────────────────
├── Unread Items        ● 5
├── Today's Events      ● 3
├── ──────────────────
├── Preferences...      ⌘,
├── About Pylon
├── ──────────────────
└── Quit Pylon          ⌘Q
```

## Technical Requirements
- Efficient status updates without polling
- Badge updates based on widget data
- Keyboard shortcuts working from menu bar
- Proper memory management for menu items
- Integration with app lifecycle

## Status Indicators
- Unread email count
- Overdue reminders count
- Today's upcoming events
- System alerts (low battery, etc.)
- Visual indicators (dots, numbers, colors)

## Accessibility
- VoiceOver support for menu items
- Keyboard navigation through menu
- Clear descriptions for status indicators
- Support for reduced motion preferences

## Performance Considerations
- Minimal overhead for status updates
- Efficient badge calculation
- No blocking operations on main thread
- Memory efficient menu creation

## Testing Strategy
- Unit tests for menu creation
- Integration tests for status updates
- Accessibility testing with VoiceOver
- Performance tests for badge updates
- Manual testing across macOS versions

## Definition of Done
- Menu bar icon appears and functions correctly
- All menu items work as expected
- Status indicators update in real-time
- Follows macOS Human Interface Guidelines
- Accessibility requirements met
- Performance targets achieved