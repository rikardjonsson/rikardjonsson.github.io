import SwiftUI

/// Defines the standardized widget sizes used throughout Pylon
/// All widgets must support these sizes for consistent grid layout
enum WidgetSize: String, CaseIterable, Sendable, Codable {
    case small = "small"     // 1x1 grid units
    case medium = "medium"   // 2x1 grid units
    case large = "large"     // 2x2 grid units
    case xlarge = "xlarge"   // 4x2 grid units
    
    /// Display name for the size
    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .xlarge: return "Extra Large"
        }
    }
    
    /// Grid dimensions for this size
    var gridDimensions: (width: Int, height: Int) {
        switch self {
        case .small: return (1, 1)
        case .medium: return (2, 1)
        case .large: return (2, 2)
        case .xlarge: return (4, 2)
        }
    }
    
    /// Calculated frame size based on grid unit
    func frameSize(gridUnit: CGFloat, spacing: CGFloat) -> CGSize {
        let dims = gridDimensions
        let width = CGFloat(dims.width) * gridUnit + CGFloat(dims.width - 1) * spacing
        let height = CGFloat(dims.height) * gridUnit + CGFloat(dims.height - 1) * spacing
        return CGSize(width: width, height: height)
    }
    
    /// Minimum content area after padding
    var minContentSize: CGSize {
        switch self {
        case .small: return CGSize(width: 100, height: 100)
        case .medium: return CGSize(width: 220, height: 100)
        case .large: return CGSize(width: 220, height: 220)
        case .xlarge: return CGSize(width: 460, height: 220)
        }
    }
}