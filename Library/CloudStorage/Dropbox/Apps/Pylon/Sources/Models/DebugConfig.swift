import Foundation

/// Debug configuration for selective logging
struct DebugConfig {
    /// Controls coordinate and positioning debug output (essential for coordinate problems)
    static let showCoordinateDebug = true
    
    /// Controls drag and drop debug output (essential for coordinate problems)
    static let showDragDebug = true
    
    /// Controls widget placement debug output
    static let showPlacementDebug = true
    
    /// Controls grid system debug output
    static let showGridDebug = true
    
    /// Shows only critical errors and warnings
    static let showCriticalOnly = false
}

/// Debug logging utility
enum DebugLog {
    /// Log coordinate-related information
    static func coordinate(_ message: String) {
        if DebugConfig.showCoordinateDebug {
            print("🗺️ \(message)")
        }
    }
    
    /// Log drag and drop operations
    static func drag(_ message: String) {
        if DebugConfig.showDragDebug {
            print("🎯 \(message)")
        }
    }
    
    /// Log widget placement operations
    static func placement(_ message: String) {
        if DebugConfig.showPlacementDebug {
            print("🏗️ \(message)")
        }
    }
    
    /// Log grid system operations
    static func grid(_ message: String) {
        if DebugConfig.showGridDebug {
            print("📏 \(message)")
        }
    }
    
    /// Log critical errors and warnings (always shown)
    static func critical(_ message: String) {
        print("⚠️ \(message)")
    }
    
    /// Log success operations (minimal output)
    static func success(_ message: String) {
        if !DebugConfig.showCriticalOnly {
            print("✅ \(message)")
        }
    }
    
    /// Log informational messages
    static func info(_ message: String) {
        if !DebugConfig.showCriticalOnly {
            print("ℹ️ \(message)")
        }
    }
    
    /// Log errors (always shown)
    static func error(_ message: String) {
        print("❌ \(message)")
    }
    
    /// Log warnings (always shown)
    static func warning(_ message: String) {
        print("⚠️ \(message)")
    }
}