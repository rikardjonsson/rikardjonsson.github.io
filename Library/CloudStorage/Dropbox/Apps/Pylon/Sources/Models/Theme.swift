//
//  Theme.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

protocol Theme: Sendable {
    var name: String { get }
    var id: String { get } // Unique identifier for theme
    var category: ThemeCategory { get } // Theme categorization
    
    // Core Visual Properties
    var backgroundMaterial: Material { get }
    var backgroundColor: Color { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var glassEffect: Material { get }
    var cardBackground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    
    // Enhanced Design System Extensions
    var depthLayer1: Material { get }  // Closest to user - strongest blur
    var depthLayer2: Material { get }  // Mid-depth - medium blur
    var depthLayer3: Material { get }  // Background - subtle blur
    var ambientGlow: Color { get }     // Rim lighting color
    var contextualAccent: Color { get } // Adaptive accent based on content
    var fluidCornerRadius: CGFloat { get } // Base corner radius for morphing
    
    // Advanced Visual Properties
    var shadowColor: Color { get }     // Base shadow color
    var borderColor: Color { get }     // Default border color
    var errorColor: Color { get }      // Error state color
    var warningColor: Color { get }    // Warning state color
    var successColor: Color { get }    // Success state color
    var focusColor: Color { get }      // Focus/selection color
    
    // Semantic Color System
    var surfacePrimary: Color { get }   // Primary surface backgrounds
    var surfaceSecondary: Color { get } // Secondary surface backgrounds
    var surfaceTertiary: Color { get }  // Tertiary surface backgrounds
    
    // Interactive States
    var interactiveDefault: Color { get } // Default interactive elements
    var interactiveHover: Color { get }   // Hover state
    var interactivePressed: Color { get } // Pressed state
    var interactiveDisabled: Color { get } // Disabled state
    
    // Typography Colors
    var textTertiary: Color { get }    // Less prominent text
    var textQuaternary: Color { get }  // Least prominent text
    var textLink: Color { get }        // Link text color
    var textOnAccent: Color { get }    // Text on accent backgrounds
    
    // Animation Properties
    var transitionDuration: Double { get }    // Base transition duration
    var springResponse: Double { get }        // Spring animation response
    var springDamping: Double { get }         // Spring animation damping
    
    // Layout Properties
    var baseSpacing: CGFloat { get }          // Base spacing unit (8pt grid)
    var compactSpacing: CGFloat { get }       // Compact spacing
    var comfortableSpacing: CGFloat { get }   // Comfortable spacing
    
    // Visual Effects
    var blurRadius: CGFloat { get }           // Base blur radius
    var shadowRadius: CGFloat { get }         // Base shadow radius
    var shadowOpacity: Double { get }         // Base shadow opacity
}

// MARK: - Theme Categories

enum ThemeCategory: String, CaseIterable, Sendable {
    case native = "Native"
    case modern = "Modern"
    case classic = "Classic"
    case specialty = "Specialty"
    case custom = "Custom"
    
    var displayName: String { rawValue }
}

// MARK: - Theme Concrete Types

enum ThemeType: CaseIterable, Sendable {
    case nativeMacOS     // Native macOS design system
    case surveillance    // Cyberpunk surveillance aesthetic
    case modern         // Clean modern design
    case glassmorphism   // Glass morphism trend
    case minimal        // Ultra-minimal design
    case dark           // Classic dark theme
    case light          // Classic light theme
    case system         // System adaptive theme
    case vibrant        // High-contrast vibrant theme
    case monochrome     // Elegant monochrome theme
    
    var theme: any Theme {
        switch self {
        case .nativeMacOS: NativeMacOSTheme()
        case .surveillance: SurveillanceTheme()
        case .modern: ModernTheme()
        case .glassmorphism: GlassmorphismTheme()
        case .minimal: MinimalTheme()
        case .dark: DarkTheme()
        case .light: LightTheme()
        case .system: SystemTheme()
        case .vibrant: VibrantTheme()
        case .monochrome: MonochromeTheme()
        }
    }
    
    var displayName: String {
        switch self {
        case .nativeMacOS: "macOS Native"
        case .surveillance: "Surveillance"
        case .modern: "Modern"
        case .glassmorphism: "Glassmorphism"
        case .minimal: "Minimal"
        case .dark: "Dark"
        case .light: "Light"
        case .system: "System"
        case .vibrant: "Vibrant"
        case .monochrome: "Monochrome"
        }
    }
}

// MARK: - Surveillance Theme

struct SurveillanceTheme: Theme {
    let name = "SURVEILLANCE"
    let id = "surveillance"
    let category = ThemeCategory.specialty
    
    // Core Visual Properties
    let backgroundMaterial = Material.ultraThinMaterial
    let backgroundColor = Color.black
    let primaryColor = Color(red: 0.04, green: 0.04, blue: 0.069)
    let secondaryColor = Color(red: 0.11, green: 0.11, blue: 0.13)
    let accentColor = Color(red: 0.42, green: 0.45, blue: 0.5)
    let glassEffect = Material.ultraThinMaterial
    let cardBackground = Color(red: 0.078, green: 0.078, blue: 0.094)
    let textPrimary = Color(red: 0.97, green: 0.97, blue: 0.96)
    let textSecondary = Color(red: 0.71, green: 0.71, blue: 0.73)
    
    // Enhanced Design System
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.ultraThinMaterial
    let ambientGlow = Color(red: 0.5, green: 0.6, blue: 0.8)
    let contextualAccent = Color(red: 0.3, green: 0.7, blue: 0.9)
    let fluidCornerRadius: CGFloat = 8.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black
    let borderColor = Color(red: 0.3, green: 0.35, blue: 0.4)
    let errorColor = Color(red: 0.9, green: 0.3, blue: 0.3)
    let warningColor = Color(red: 0.9, green: 0.7, blue: 0.2)
    let successColor = Color(red: 0.3, green: 0.8, blue: 0.4)
    let focusColor = Color(red: 0.3, green: 0.7, blue: 0.9)
    
    // Semantic Surfaces
    let surfacePrimary = Color(red: 0.06, green: 0.06, blue: 0.08)
    let surfaceSecondary = Color(red: 0.09, green: 0.09, blue: 0.11)
    let surfaceTertiary = Color(red: 0.12, green: 0.12, blue: 0.14)
    
    // Interactive States
    let interactiveDefault = Color(red: 0.42, green: 0.45, blue: 0.5)
    let interactiveHover = Color(red: 0.52, green: 0.55, blue: 0.6)
    let interactivePressed = Color(red: 0.32, green: 0.35, blue: 0.4)
    let interactiveDisabled = Color(red: 0.25, green: 0.25, blue: 0.3)
    
    // Typography Colors
    let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.65)
    let textQuaternary = Color(red: 0.45, green: 0.45, blue: 0.5)
    let textLink = Color(red: 0.4, green: 0.8, blue: 0.9)
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.3
    let springResponse: Double = 0.4
    let springDamping: Double = 0.8
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 4
    let comfortableSpacing: CGFloat = 12
    
    // Visual Effects
    let blurRadius: CGFloat = 8
    let shadowRadius: CGFloat = 4
    let shadowOpacity: Double = 0.2
}

// MARK: - Modern Theme

struct ModernTheme: Theme {
    let name = "Modern"
    let id = "modern"
    let category = ThemeCategory.modern
    
    // Core Visual Properties
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.gray.opacity(0.05)
    let primaryColor = Color.blue
    let secondaryColor = Color.blue.opacity(0.6)
    let accentColor = Color.blue
    let glassEffect = Material.ultraThin
    let cardBackground = Color.clear
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    
    // Enhanced Design System
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.blue
    let contextualAccent = Color.cyan
    let fluidCornerRadius: CGFloat = 12.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black.opacity(0.15)
    let borderColor = Color.gray.opacity(0.3)
    let errorColor = Color.red
    let warningColor = Color.orange
    let successColor = Color.green
    let focusColor = Color.blue
    
    // Semantic Surfaces
    let surfacePrimary = Color.white.opacity(0.9)
    let surfaceSecondary = Color.gray.opacity(0.1)
    let surfaceTertiary = Color.gray.opacity(0.05)
    
    // Interactive States
    let interactiveDefault = Color.blue
    let interactiveHover = Color.blue.opacity(0.8)
    let interactivePressed = Color.blue.opacity(1.2)
    let interactiveDisabled = Color.gray.opacity(0.4)
    
    // Typography Colors
    let textTertiary = Color.secondary.opacity(0.8)
    let textQuaternary = Color.secondary.opacity(0.6)
    let textLink = Color.blue
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.25
    let springResponse: Double = 0.5
    let springDamping: Double = 0.7
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 4
    let comfortableSpacing: CGFloat = 16
    
    // Visual Effects
    let blurRadius: CGFloat = 12
    let shadowRadius: CGFloat = 8
    let shadowOpacity: Double = 0.1
}

// MARK: - Dark Theme

struct DarkTheme: Theme {
    let name = "Dark"
    let id = "dark"
    let category = ThemeCategory.classic
    
    // Core Visual Properties  
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    let primaryColor = Color.white
    let secondaryColor = Color.gray
    let accentColor = Color.blue
    let glassEffect = Material.ultraThickMaterial
    let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.15)
    let textPrimary = Color.white
    let textSecondary = Color.gray
    
    // Enhanced Design System
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.white.opacity(0.8)
    let contextualAccent = Color.blue
    let fluidCornerRadius: CGFloat = 8.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black
    let borderColor = Color.gray.opacity(0.3)
    let errorColor = Color.red
    let warningColor = Color.orange
    let successColor = Color.green
    let focusColor = Color.blue
    
    // Semantic Surfaces
    let surfacePrimary = Color(red: 0.18, green: 0.18, blue: 0.18)
    let surfaceSecondary = Color(red: 0.22, green: 0.22, blue: 0.22)
    let surfaceTertiary = Color(red: 0.26, green: 0.26, blue: 0.26)
    
    // Interactive States
    let interactiveDefault = Color.blue
    let interactiveHover = Color.blue.opacity(0.8)
    let interactivePressed = Color.blue.opacity(1.2)
    let interactiveDisabled = Color.gray.opacity(0.4)
    
    // Typography Colors
    let textTertiary = Color.gray.opacity(0.8)
    let textQuaternary = Color.gray.opacity(0.6)
    let textLink = Color.blue
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.2
    let springResponse: Double = 0.4
    let springDamping: Double = 0.8
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 4
    let comfortableSpacing: CGFloat = 12
    
    // Visual Effects
    let blurRadius: CGFloat = 6
    let shadowRadius: CGFloat = 4
    let shadowOpacity: Double = 0.3
}

// MARK: - Light Theme

struct LightTheme: Theme {
    let name = "Light"
    let id = "light"
    let category = ThemeCategory.classic
    
    // Core Visual Properties
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.white
    let primaryColor = Color.black
    let secondaryColor = Color.gray
    let accentColor = Color.blue
    let glassEffect = Material.thinMaterial
    let cardBackground = Color.white
    let textPrimary = Color.black
    let textSecondary = Color.gray
    
    // Enhanced Design System
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.gray.opacity(0.6)
    let contextualAccent = Color.blue
    let fluidCornerRadius: CGFloat = 8.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black.opacity(0.2)
    let borderColor = Color.gray.opacity(0.3)
    let errorColor = Color.red
    let warningColor = Color.orange
    let successColor = Color.green
    let focusColor = Color.blue
    
    // Semantic Surfaces
    let surfacePrimary = Color.white
    let surfaceSecondary = Color(red: 0.98, green: 0.98, blue: 0.98)
    let surfaceTertiary = Color(red: 0.95, green: 0.95, blue: 0.95)
    
    // Interactive States
    let interactiveDefault = Color.blue
    let interactiveHover = Color.blue.opacity(0.8)
    let interactivePressed = Color.blue.opacity(1.2)
    let interactiveDisabled = Color.gray.opacity(0.4)
    
    // Typography Colors
    let textTertiary = Color.gray.opacity(0.8)
    let textQuaternary = Color.gray.opacity(0.6)
    let textLink = Color.blue
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.2
    let springResponse: Double = 0.4
    let springDamping: Double = 0.8
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 4
    let comfortableSpacing: CGFloat = 12
    
    // Visual Effects
    let blurRadius: CGFloat = 6
    let shadowRadius: CGFloat = 2
    let shadowOpacity: Double = 0.1
}

// MARK: - System Theme

struct SystemTheme: Theme {
    let name = "System"
    let id = "system"
    let category = ThemeCategory.native
    
    // Core Visual Properties
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.clear
    let primaryColor = Color.primary
    let secondaryColor = Color.secondary
    let accentColor = Color.accentColor
    let glassEffect = Material.regularMaterial
    let cardBackground = Color(NSColor.controlBackgroundColor)
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    
    // Enhanced Design System
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.accentColor
    let contextualAccent = Color.accentColor
    let fluidCornerRadius: CGFloat = 8.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black.opacity(0.2)
    let borderColor = Color.primary.opacity(0.2)
    let errorColor = Color.red
    let warningColor = Color.orange
    let successColor = Color.green
    let focusColor = Color.accentColor
    
    // Semantic Surfaces
    let surfacePrimary = Color(NSColor.controlBackgroundColor)
    let surfaceSecondary = Color(NSColor.alternatingContentBackgroundColors[0])
    let surfaceTertiary = Color(NSColor.alternatingContentBackgroundColors[1])
    
    // Interactive States
    let interactiveDefault = Color.accentColor
    let interactiveHover = Color.accentColor.opacity(0.8)
    let interactivePressed = Color.accentColor.opacity(1.2)
    let interactiveDisabled = Color.secondary.opacity(0.4)
    
    // Typography Colors
    let textTertiary = Color.secondary.opacity(0.8)
    let textQuaternary = Color.secondary.opacity(0.6)
    let textLink = Color.accentColor
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.25
    let springResponse: Double = 0.4
    let springDamping: Double = 0.8
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 4
    let comfortableSpacing: CGFloat = 12
    
    // Visual Effects
    let blurRadius: CGFloat = 8
    let shadowRadius: CGFloat = 4
    let shadowOpacity: Double = 0.15
}

// MARK: - New Theme Implementations

/// Modern glassmorphism theme with translucent elements
struct GlassmorphismTheme: Theme {
    let name = "Glassmorphism"
    let id = "glassmorphism"
    let category = ThemeCategory.modern
    
    // Core Visual Properties
    let backgroundMaterial = Material.ultraThinMaterial
    let backgroundColor = Color.clear
    let primaryColor = Color.primary
    let secondaryColor = Color.secondary
    let accentColor = Color.blue
    let glassEffect = Material.ultraThinMaterial
    let cardBackground = Color.white.opacity(0.1)
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    
    // Enhanced Design System
    let depthLayer1 = Material.ultraThinMaterial
    let depthLayer2 = Material.thinMaterial
    let depthLayer3 = Material.regularMaterial
    let ambientGlow = Color.blue.opacity(0.6)
    let contextualAccent = Color.cyan
    let fluidCornerRadius: CGFloat = 16.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black.opacity(0.1)
    let borderColor = Color.white.opacity(0.2)
    let errorColor = Color.red.opacity(0.8)
    let warningColor = Color.orange.opacity(0.8)
    let successColor = Color.green.opacity(0.8)
    let focusColor = Color.blue.opacity(0.6)
    
    // Semantic Surfaces
    let surfacePrimary = Color.white.opacity(0.15)
    let surfaceSecondary = Color.white.opacity(0.1)
    let surfaceTertiary = Color.white.opacity(0.05)
    
    // Interactive States
    let interactiveDefault = Color.blue.opacity(0.8)
    let interactiveHover = Color.blue.opacity(0.6)
    let interactivePressed = Color.blue
    let interactiveDisabled = Color.gray.opacity(0.3)
    
    // Typography Colors
    let textTertiary = Color.secondary.opacity(0.8)
    let textQuaternary = Color.secondary.opacity(0.6)
    let textLink = Color.blue.opacity(0.8)
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.4
    let springResponse: Double = 0.6
    let springDamping: Double = 0.7
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 6
    let comfortableSpacing: CGFloat = 16
    
    // Visual Effects
    let blurRadius: CGFloat = 20
    let shadowRadius: CGFloat = 16
    let shadowOpacity: Double = 0.1
}

/// Ultra-minimal theme with maximum whitespace
struct MinimalTheme: Theme {
    let name = "Minimal"
    let id = "minimal"
    let category = ThemeCategory.modern
    
    // Core Visual Properties
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.white
    let primaryColor = Color.black
    let secondaryColor = Color.gray.opacity(0.6)
    let accentColor = Color.black
    let glassEffect = Material.thinMaterial
    let cardBackground = Color.white
    let textPrimary = Color.black
    let textSecondary = Color.gray
    
    // Enhanced Design System
    let depthLayer1 = Material.thinMaterial
    let depthLayer2 = Material.ultraThinMaterial
    let depthLayer3 = Material.regularMaterial
    let ambientGlow = Color.gray.opacity(0.3)
    let contextualAccent = Color.black
    let fluidCornerRadius: CGFloat = 2.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black.opacity(0.05)
    let borderColor = Color.gray.opacity(0.2)
    let errorColor = Color.red
    let warningColor = Color.orange
    let successColor = Color.green
    let focusColor = Color.black
    
    // Semantic Surfaces
    let surfacePrimary = Color.white
    let surfaceSecondary = Color(red: 0.99, green: 0.99, blue: 0.99)
    let surfaceTertiary = Color(red: 0.97, green: 0.97, blue: 0.97)
    
    // Interactive States
    let interactiveDefault = Color.black
    let interactiveHover = Color.gray
    let interactivePressed = Color.black.opacity(0.8)
    let interactiveDisabled = Color.gray.opacity(0.4)
    
    // Typography Colors
    let textTertiary = Color.gray.opacity(0.7)
    let textQuaternary = Color.gray.opacity(0.5)
    let textLink = Color.black
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.15
    let springResponse: Double = 0.3
    let springDamping: Double = 0.9
    
    // Layout Properties
    let baseSpacing: CGFloat = 12
    let compactSpacing: CGFloat = 8
    let comfortableSpacing: CGFloat = 24
    
    // Visual Effects
    let blurRadius: CGFloat = 4
    let shadowRadius: CGFloat = 1
    let shadowOpacity: Double = 0.05
}

/// High-contrast vibrant theme
struct VibrantTheme: Theme {
    let name = "Vibrant"
    let id = "vibrant"
    let category = ThemeCategory.specialty
    
    // Core Visual Properties
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.black
    let primaryColor = Color.white
    let secondaryColor = Color.gray
    let accentColor = Color(red: 1.0, green: 0.3, blue: 0.6)
    let glassEffect = Material.thickMaterial
    let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    let textPrimary = Color.white
    let textSecondary = Color.gray.opacity(0.8)
    
    // Enhanced Design System
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color(red: 1.0, green: 0.3, blue: 0.6)
    let contextualAccent = Color(red: 0.3, green: 0.8, blue: 1.0)
    let fluidCornerRadius: CGFloat = 12.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black
    let borderColor = Color(red: 0.4, green: 0.4, blue: 0.6)
    let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    let warningColor = Color(red: 1.0, green: 0.6, blue: 0.2)
    let successColor = Color(red: 0.2, green: 1.0, blue: 0.4)
    let focusColor = Color(red: 1.0, green: 0.3, blue: 0.6)
    
    // Semantic Surfaces
    let surfacePrimary = Color(red: 0.15, green: 0.15, blue: 0.2)
    let surfaceSecondary = Color(red: 0.2, green: 0.2, blue: 0.25)
    let surfaceTertiary = Color(red: 0.25, green: 0.25, blue: 0.3)
    
    // Interactive States
    let interactiveDefault = Color(red: 1.0, green: 0.3, blue: 0.6)
    let interactiveHover = Color(red: 1.0, green: 0.4, blue: 0.7)
    let interactivePressed = Color(red: 0.9, green: 0.2, blue: 0.5)
    let interactiveDisabled = Color.gray.opacity(0.4)
    
    // Typography Colors
    let textTertiary = Color.gray.opacity(0.7)
    let textQuaternary = Color.gray.opacity(0.5)
    let textLink = Color(red: 0.3, green: 0.8, blue: 1.0)
    let textOnAccent = Color.white
    
    // Animation Properties
    let transitionDuration: Double = 0.3
    let springResponse: Double = 0.5
    let springDamping: Double = 0.6
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 4
    let comfortableSpacing: CGFloat = 16
    
    // Visual Effects
    let blurRadius: CGFloat = 10
    let shadowRadius: CGFloat = 8
    let shadowOpacity: Double = 0.4
}

/// Elegant monochrome theme
struct MonochromeTheme: Theme {
    let name = "Monochrome"
    let id = "monochrome"
    let category = ThemeCategory.specialty
    
    // Core Visual Properties
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color(red: 0.15, green: 0.15, blue: 0.15)
    let primaryColor = Color.white
    let secondaryColor = Color.gray
    let accentColor = Color.white
    let glassEffect = Material.regularMaterial
    let cardBackground = Color(red: 0.2, green: 0.2, blue: 0.2)
    let textPrimary = Color.white
    let textSecondary = Color.gray.opacity(0.8)
    
    // Enhanced Design System
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.white.opacity(0.6)
    let contextualAccent = Color.gray.opacity(0.8)
    let fluidCornerRadius: CGFloat = 6.0
    
    // Advanced Visual Properties
    let shadowColor = Color.black
    let borderColor = Color.gray.opacity(0.4)
    let errorColor = Color.white
    let warningColor = Color.gray.opacity(0.8)
    let successColor = Color.white
    let focusColor = Color.white
    
    // Semantic Surfaces
    let surfacePrimary = Color(red: 0.25, green: 0.25, blue: 0.25)
    let surfaceSecondary = Color(red: 0.3, green: 0.3, blue: 0.3)
    let surfaceTertiary = Color(red: 0.35, green: 0.35, blue: 0.35)
    
    // Interactive States
    let interactiveDefault = Color.white
    let interactiveHover = Color.gray.opacity(0.8)
    let interactivePressed = Color.white.opacity(0.8)
    let interactiveDisabled = Color.gray.opacity(0.4)
    
    // Typography Colors
    let textTertiary = Color.gray.opacity(0.7)
    let textQuaternary = Color.gray.opacity(0.5)
    let textLink = Color.white
    let textOnAccent = Color.black
    
    // Animation Properties
    let transitionDuration: Double = 0.25
    let springResponse: Double = 0.4
    let springDamping: Double = 0.8
    
    // Layout Properties
    let baseSpacing: CGFloat = 8
    let compactSpacing: CGFloat = 4
    let comfortableSpacing: CGFloat = 12
    
    // Visual Effects
    let blurRadius: CGFloat = 6
    let shadowRadius: CGFloat = 4
    let shadowOpacity: Double = 0.2
}

// MARK: - Theme Environment

struct ThemeKey: EnvironmentKey {
    static let defaultValue: any Theme = NativeMacOSTheme()
}

extension EnvironmentValues {
    var theme: any Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
