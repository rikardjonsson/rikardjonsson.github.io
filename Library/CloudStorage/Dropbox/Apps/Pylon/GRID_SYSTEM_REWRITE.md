# Complete Grid System Rewrite

**Issue Type:** Enhancement/Rewrite
**Priority:** High
**Component:** Widget Layout System

## Problem Statement

The current grid system is fundamentally broken and needs a complete rewrite. Widgets are not positioning correctly, collision detection is unreliable, and the layout system is overly complex with multiple conflicting padding sources.

## Requirements

### Core Grid Functionality
- **Grid-based layout**: Clean, visible grid cells that widgets snap to
- **Dynamic placement**: Drag and drop widgets to any valid grid position
- **Collision prevention**: Widgets cannot overlap or be placed on occupied cells
- **Real-time validation**: Visual feedback during drag operations

### Widget Sizes
1. **Small (1x1)**: Single grid cell - for simple data (clock, single metric)
2. **Medium (2x2)**: Four grid cells - for detailed widgets (charts, lists)  
3. **Large (2x4)**: Eight grid cells - for complex widgets (dashboards, tables)

### Grid Behavior (Tetris-like)
- Widgets fill available space efficiently
- No gaps or overlaps allowed
- Visual drop indicators during drag
- Automatic collision detection
- Support for mixed widget sizes in same grid

## Technical Design

### 1. Grid Model
```swift
struct GridCell: Hashable {
    let row: Int
    let column: Int
}

struct GridBounds {
    let rows: Int
    let columns: Int
}

enum WidgetSize: CaseIterable {
    case small   // 1x1
    case medium  // 2x2
    case large   // 2x4
    
    var dimensions: (width: Int, height: Int) {
        switch self {
        case .small: return (1, 1)
        case .medium: return (2, 2) 
        case .large: return (2, 4)
        }
    }
    
    func occupiedCells(at position: GridCell) -> Set<GridCell> {
        let (width, height) = dimensions
        var cells = Set<GridCell>()
        for row in 0..<height {
            for col in 0..<width {
                cells.insert(GridCell(row: position.row + row, column: position.column + col))
            }
        }
        return cells
    }
}
```

### 2. Grid State Management
```swift
@MainActor
class GridManager: ObservableObject {
    @Published private(set) var widgets: [Widget] = []
    @Published private(set) var occupiedCells: Set<GridCell> = []
    
    let gridBounds = GridBounds(rows: 12, columns: 8)
    
    // Core operations
    func canPlaceWidget(_ widget: Widget, at position: GridCell) -> Bool
    func placeWidget(_ widget: Widget, at position: GridCell) -> Bool
    func moveWidget(id: UUID, to position: GridCell) -> Bool
    func removeWidget(id: UUID)
    
    // Collision detection
    private func wouldCollide(_ widget: Widget, at position: GridCell) -> Bool
    private func isValidPosition(_ position: GridCell, for widget: Widget) -> Bool
}
```

### 3. Visual Grid Component
```swift
struct TetrisGrid: View {
    @StateObject private var gridManager = GridManager()
    @State private var draggedWidget: Widget?
    @State private var dropPreview: GridCell?
    
    var body: some View {
        ZStack {
            // Background grid cells
            GridBackground(bounds: gridManager.gridBounds)
            
            // Placed widgets
            ForEach(gridManager.widgets) { widget in
                WidgetView(widget: widget)
                    .position(gridPosition: widget.position)
                    .draggable(onDrag: handleDrag, onDrop: handleDrop)
            }
            
            // Drop preview indicator
            if let preview = dropPreview {
                DropPreviewIndicator(at: preview, size: draggedWidget?.size)
            }
        }
    }
}
```

### 4. Grid Background
```swift
struct GridBackground: View {
    let bounds: GridBounds
    let cellSize: CGFloat = 100
    let spacing: CGFloat = 2
    
    var body: some View {
        ForEach(0..<bounds.rows, id: \.self) { row in
            ForEach(0..<bounds.columns, id: \.self) { column in
                Rectangle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    .fill(Color.secondary.opacity(0.05))
                    .frame(width: cellSize, height: cellSize)
                    .position(x: CGFloat(column) * (cellSize + spacing) + cellSize/2,
                             y: CGFloat(row) * (cellSize + spacing) + cellSize/2)
            }
        }
    }
}
```

## Implementation Plan

### Phase 1: Core Grid Infrastructure
- [ ] Create new `GridCell` and `GridBounds` models
- [ ] Implement `GridManager` with collision detection
- [ ] Build `GridBackground` with visible cells
- [ ] Add basic widget positioning

### Phase 2: Drag & Drop System  
- [ ] Implement drag gesture handling
- [ ] Add real-time collision validation
- [ ] Create drop preview indicators
- [ ] Handle drag cancellation/snap-back

### Phase 3: Widget Integration
- [ ] Update existing widgets to use new sizes
- [ ] Implement widget resize functionality  
- [ ] Add widget removal/deletion
- [ ] Create widget palette for adding new widgets

### Phase 4: Polish & Testing
- [ ] Smooth animations for all transitions
- [ ] Accessibility support (VoiceOver, keyboard navigation)
- [ ] Persistence of grid layout
- [ ] Performance optimization for large grids

## Success Criteria

### Functional Requirements
- ✅ Widgets snap cleanly to grid positions
- ✅ No overlapping widgets possible
- ✅ Smooth drag and drop interactions
- ✅ Visual feedback during placement
- ✅ Support for all three widget sizes
- ✅ Efficient collision detection

### Visual Requirements  
- ✅ Clearly visible grid structure
- ✅ Consistent spacing and alignment
- ✅ Native macOS look and feel
- ✅ Responsive to window resizing
- ✅ Proper visual hierarchy

### Performance Requirements
- ✅ Smooth 60fps drag operations
- ✅ Instant collision feedback
- ✅ No layout jitter or jumpiness
- ✅ Memory efficient for 50+ widgets

## Files to Create/Modify

### New Files
- `Sources/Models/GridSystem/GridCell.swift`
- `Sources/Models/GridSystem/GridManager.swift` 
- `Sources/Models/GridSystem/GridBounds.swift`
- `Sources/Views/GridSystem/TetrisGrid.swift`
- `Sources/Views/GridSystem/GridBackground.swift`
- `Sources/Views/GridSystem/DropPreviewIndicator.swift`

### Modified Files
- `Sources/Models/WidgetSize.swift` - Simplify to three sizes
- `Sources/Models/WidgetContainer.swift` - Add grid position property
- `Sources/Views/NativeContentView.swift` - Replace current grid with TetrisGrid
- `Sources/Models/AppState.swift` - Update to use GridManager

### Deprecated Files
- `Sources/Views/DraggableGridView.swift` - Replace entirely
- `Sources/Models/WidgetManager.swift` - Replace with GridManager
- `Sources/Models/LayoutPersistence.swift` - Update for new grid system

## Testing Strategy

### Unit Tests
- GridManager collision detection
- Widget size calculations  
- Grid bounds validation
- Position conversion utilities

### Integration Tests
- Drag and drop workflows
- Widget placement scenarios
- Grid state persistence
- Multiple widget interactions

### Visual Tests
- Grid alignment across window sizes
- Widget positioning accuracy
- Animation smoothness
- Accessibility compliance

## Risk Mitigation

### Technical Risks
- **Performance**: Use efficient Set-based collision detection
- **Complexity**: Keep grid logic separate from widget logic  
- **Compatibility**: Maintain existing widget API where possible

### User Experience Risks
- **Learning curve**: Provide clear visual feedback
- **Accessibility**: Full keyboard and VoiceOver support
- **Data loss**: Robust grid state persistence

## Definition of Done

This rewrite is complete when:
1. All widgets can be placed in a clean, visible grid
2. Drag and drop works smoothly with collision prevention
3. All three widget sizes work correctly
4. Grid state persists across app restarts
5. Performance meets the specified criteria
6. Full test coverage is achieved
7. Documentation is updated

---

**Estimated Effort**: 3-4 development days
**Dependencies**: None (complete rewrite)
**Breaking Changes**: Yes (new grid system API)