import SwiftUI

protocol Theme {
    var name: String { get }
    var backgroundStyle: BackgroundStyle { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var glassEffect: Material { get }
    var cardBackground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
}

extension Theme {
    static let modern = ModernTheme()
    static let dark = DarkTheme()
    static let light = LightTheme()
    static let system = SystemTheme()
}

// MARK: - Modern Theme
struct ModernTheme: Theme {
    let name = "Modern"
    let backgroundStyle = BackgroundStyle.regularMaterial
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
    let backgroundStyle = BackgroundStyle.regularMaterial
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
    let backgroundStyle = BackgroundStyle.regularMaterial
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
    let backgroundStyle = BackgroundStyle.regularMaterial
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
    static let defaultValue: Theme = .modern
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}