import SwiftUI

protocol Theme: Sendable {
    var name: String { get }
    var backgroundMaterial: Material { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var glassEffect: Material { get }
    var cardBackground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
}

// MARK: - Theme Concrete Types
enum ThemeType: CaseIterable, Sendable {
    case modern
    case dark  
    case light
    case system
    
    var theme: any Theme {
        switch self {
        case .modern: return ModernTheme()
        case .dark: return DarkTheme()
        case .light: return LightTheme()
        case .system: return SystemTheme()
        }
    }
}

// MARK: - Modern Theme
struct ModernTheme: Theme {
    let name = "Modern"
    let backgroundMaterial = Material.regularMaterial
    let primaryColor = Color.blue
    let secondaryColor = Color.blue.opacity(0.6)
    let accentColor = Color.blue
    let glassEffect = Material.ultraThin
    let cardBackground = Color.clear
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
}

// MARK: - Dark Theme
struct DarkTheme: Theme {
    let name = "Dark"
    let backgroundMaterial = Material.regularMaterial
    let primaryColor = Color.white
    let secondaryColor = Color.gray
    let accentColor = Color.blue
    let glassEffect = Material.ultraThickMaterial
    let cardBackground = Color(NSColor.controlBackgroundColor)
    let textPrimary = Color.white
    let textSecondary = Color.gray
}

// MARK: - Light Theme
struct LightTheme: Theme {
    let name = "Light"
    let backgroundMaterial = Material.regularMaterial
    let primaryColor = Color.black
    let secondaryColor = Color.gray
    let accentColor = Color.blue
    let glassEffect = Material.thinMaterial
    let cardBackground = Color.white
    let textPrimary = Color.black
    let textSecondary = Color.gray
}

// MARK: - System Theme
struct SystemTheme: Theme {
    let name = "System"
    let backgroundMaterial = Material.regularMaterial
    let primaryColor = Color.primary
    let secondaryColor = Color.secondary
    let accentColor = Color.accentColor
    let glassEffect = Material.regularMaterial
    let cardBackground = Color(NSColor.controlBackgroundColor)
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
}

// MARK: - Theme Environment
struct ThemeKey: EnvironmentKey {
    static let defaultValue: any Theme = ModernTheme()
}

extension EnvironmentValues {
    var theme: any Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}