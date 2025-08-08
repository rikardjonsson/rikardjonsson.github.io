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
    var backgroundMaterial: Material { get }
    var backgroundColor: Color { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var glassEffect: Material { get }
    var cardBackground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    
    // 2025 Design System Extensions
    var depthLayer1: Material { get }  // Closest to user - strongest blur
    var depthLayer2: Material { get }  // Mid-depth - medium blur
    var depthLayer3: Material { get }  // Background - subtle blur
    var ambientGlow: Color { get }     // Rim lighting color
    var contextualAccent: Color { get } // Adaptive accent based on content
    var fluidCornerRadius: CGFloat { get } // Base corner radius for morphing
}

// MARK: - Theme Concrete Types

enum ThemeType: CaseIterable, Sendable {
    case nativeMacOS  // New native macOS theme
    case surveillance
    case modern
    case dark
    case light
    case system

    var theme: any Theme {
        switch self {
        case .nativeMacOS: NativeMacOSTheme()
        case .surveillance: SurveillanceTheme()
        case .modern: ModernTheme()
        case .dark: DarkTheme()
        case .light: LightTheme()
        case .system: SystemTheme()
        }
    }
}

// MARK: - Surveillance Theme

struct SurveillanceTheme: Theme {
    let name = "SURVEILLANCE"
    let backgroundMaterial = Material.ultraThinMaterial
    let backgroundColor = Color.black
    let primaryColor = Color(red: 0.04, green: 0.04, blue: 0.069) // Sophisticated dark charcoal
    let secondaryColor = Color(red: 0.11, green: 0.11, blue: 0.13) // Warmer dark gray
    let accentColor = Color(red: 0.42, green: 0.45, blue: 0.5) // Subtle blue-gray accent
    let glassEffect = Material.ultraThinMaterial
    let cardBackground = Color(red: 0.078, green: 0.078, blue: 0.094) // Refined card background
    let textPrimary = Color(red: 0.97, green: 0.97, blue: 0.96) // Warm off-white primary
    let textSecondary = Color(red: 0.71, green: 0.71, blue: 0.73) // Sophisticated secondary
    
    // 2025 Design System
    let depthLayer1 = Material.thickMaterial      // Strongest blur for focus
    let depthLayer2 = Material.regularMaterial    // Medium blur for mid-level
    let depthLayer3 = Material.ultraThinMaterial  // Subtle blur for background
    let ambientGlow = Color(red: 0.5, green: 0.6, blue: 0.8)  // Cool blue rim light
    let contextualAccent = Color(red: 0.3, green: 0.7, blue: 0.9) // Adaptive cyan
    let fluidCornerRadius: CGFloat = 8.0          // Golden ratio based
}

// MARK: - Modern Theme

struct ModernTheme: Theme {
    let name = "Modern"
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.gray.opacity(0.1)
    let primaryColor = Color.blue
    let secondaryColor = Color.blue.opacity(0.6)
    let accentColor = Color.blue
    let glassEffect = Material.ultraThin
    let cardBackground = Color.clear
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.blue
    let contextualAccent = Color.cyan
    let fluidCornerRadius: CGFloat = 8.0
}

// MARK: - Dark Theme

struct DarkTheme: Theme {
    let name = "Dark"
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.black
    let primaryColor = Color.white
    let secondaryColor = Color.gray
    let accentColor = Color.blue
    let glassEffect = Material.ultraThickMaterial
    let cardBackground = Color(NSColor.controlBackgroundColor)
    let textPrimary = Color.white
    let textSecondary = Color.gray
    
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.white
    let contextualAccent = Color.blue
    let fluidCornerRadius: CGFloat = 8.0
}

// MARK: - Light Theme

struct LightTheme: Theme {
    let name = "Light"
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.white
    let primaryColor = Color.black
    let secondaryColor = Color.gray
    let accentColor = Color.blue
    let glassEffect = Material.thinMaterial
    let cardBackground = Color.white
    let textPrimary = Color.black
    let textSecondary = Color.gray
    
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.gray
    let contextualAccent = Color.blue
    let fluidCornerRadius: CGFloat = 8.0
}

// MARK: - System Theme

struct SystemTheme: Theme {
    let name = "System"
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.clear
    let primaryColor = Color.primary
    let secondaryColor = Color.secondary
    let accentColor = Color.accentColor
    let glassEffect = Material.regularMaterial
    let cardBackground = Color(NSColor.controlBackgroundColor)
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    
    let depthLayer1 = Material.thickMaterial
    let depthLayer2 = Material.regularMaterial
    let depthLayer3 = Material.thinMaterial
    let ambientGlow = Color.accentColor
    let contextualAccent = Color.accentColor
    let fluidCornerRadius: CGFloat = 8.0
}

// MARK: - Theme Environment

struct ThemeKey: EnvironmentKey {
    static let defaultValue: any Theme = NativeMacOSTheme() // Default to native macOS theme
}

extension EnvironmentValues {
    var theme: any Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
