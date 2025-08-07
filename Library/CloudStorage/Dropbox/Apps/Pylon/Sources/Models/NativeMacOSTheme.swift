//
//  NativeMacOSTheme.swift
//  Pylon
//
//  Created on 05.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// Native macOS design system following Apple's Human Interface Guidelines
struct NativeMacOSTheme: Theme {
    let name = "macOS Native"
    
    // MARK: - Native macOS Materials & Colors
    let backgroundMaterial = Material.regularMaterial
    let backgroundColor = Color.clear
    let primaryColor = Color.primary
    let secondaryColor = Color.secondary  
    let accentColor = Color.accentColor
    let glassEffect = Material.ultraThinMaterial
    let cardBackground = Color(NSColor.controlBackgroundColor)
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    
    // Native macOS Design System Extensions
    let depthLayer1 = Material.regularMaterial      // Primary content
    let depthLayer2 = Material.thinMaterial         // Secondary content  
    let depthLayer3 = Material.ultraThinMaterial    // Background
    let ambientGlow = Color.accentColor       // System accent for highlights
    let contextualAccent = Color.accentColor  // Follows system accent
    let fluidCornerRadius: CGFloat = 8.0      // macOS standard corner radius
    
    // MARK: - Native macOS Color Palette
    var surfacePrimary: Color { Color(NSColor.controlBackgroundColor) }
    var surfaceSecondary: Color { Color(NSColor.alternatingContentBackgroundColors[0]) }
    var surfaceTertiary: Color { Color(NSColor.alternatingContentBackgroundColors[1]) }
    
    // Semantic colors that adapt to light/dark mode
    var labelPrimary: Color { Color(NSColor.labelColor) }
    var labelSecondary: Color { Color(NSColor.secondaryLabelColor) }
    var labelTertiary: Color { Color(NSColor.tertiaryLabelColor) }
    var labelQuaternary: Color { Color(NSColor.quaternaryLabelColor) }
    
    // System colors
    var systemBlue: Color { Color(NSColor.systemBlue) }
    var systemGreen: Color { Color(NSColor.systemGreen) }
    var systemOrange: Color { Color(NSColor.systemOrange) }
    var systemRed: Color { Color(NSColor.systemRed) }
    var systemPurple: Color { Color(NSColor.systemPurple) }
    var systemYellow: Color { Color(NSColor.systemYellow) }
    
    // Selection and interaction colors
    var selectionColor: Color { Color(NSColor.selectedContentBackgroundColor) }
    var hoverColor: Color { Color(NSColor.controlBackgroundColor).opacity(0.5) }
    
    // MARK: - Native Typography Scale (San Francisco)
    struct Typography {
        static let largeTitle = Font.system(.largeTitle, design: .default, weight: .regular)
        static let title1 = Font.system(.title, design: .default, weight: .regular)
        static let title2 = Font.system(.title2, design: .default, weight: .regular)
        static let title3 = Font.system(.title3, design: .default, weight: .regular)
        static let headline = Font.system(.headline, design: .default, weight: .semibold)
        static let subheadline = Font.system(.subheadline, design: .default, weight: .regular)
        static let body = Font.system(.body, design: .default, weight: .regular)
        static let callout = Font.system(.callout, design: .default, weight: .regular)
        static let footnote = Font.system(.footnote, design: .default, weight: .regular)
        static let caption1 = Font.system(.caption, design: .default, weight: .regular)
        static let caption2 = Font.system(.caption2, design: .default, weight: .regular)
        
        // Monospaced variants for data
        static let bodyMono = Font.system(.body, design: .monospaced, weight: .regular)
        static let captionMono = Font.system(.caption, design: .monospaced, weight: .regular)
    }
    
    // MARK: - Native Spacing Scale (8pt grid system)
    struct Spacing {
        static let xxxs: CGFloat = 2   // 2pt
        static let xxs: CGFloat = 4    // 4pt  
        static let xs: CGFloat = 8     // 8pt
        static let sm: CGFloat = 12    // 12pt
        static let md: CGFloat = 16    // 16pt
        static let lg: CGFloat = 20    // 20pt
        static let xl: CGFloat = 24    // 24pt
        static let xxl: CGFloat = 32   // 32pt
        static let xxxl: CGFloat = 40  // 40pt
    }
    
    // MARK: - Native Corner Radius Scale
    struct CornerRadius {
        static let xs: CGFloat = 4     // Small elements
        static let sm: CGFloat = 6     // Buttons, chips
        static let md: CGFloat = 8     // Cards, panels (macOS standard)
        static let lg: CGFloat = 12    // Large cards
        static let xl: CGFloat = 16    // Hero elements
    }
    
    // MARK: - Native Shadow Styles
    struct Shadows {
        static let card = Shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        static let elevated = Shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
        static let floating = Shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 12)
        static let subtle = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Native macOS Animation Curves
extension Animation {
    /// Native macOS easing curve for UI transitions
    static let macOSEaseOut = Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.35)
    
    /// Native macOS spring animation for interactive elements
    static let macOSSpring = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
    
    /// Subtle animation for secondary elements
    static let macOSSubtle = Animation.easeOut(duration: 0.2)
}