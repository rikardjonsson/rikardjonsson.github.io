//
//  ThemeManager.swift
//  Pylon
//
//  Created on 10.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI
import Combine

/// Advanced theme management system with transitions and customization
@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: any Theme = NativeMacOSTheme()
    @Published var isTransitioning = false
    @Published var customThemes: [CustomTheme] = []
    
    // Theme transition properties
    @Published var transitionProgress: Double = 0.0
    private var transitionTimer: Timer?
    private var fromTheme: (any Theme)?
    private var toTheme: (any Theme)?
    
    // Available themes organized by category
    var themesByCategory: [ThemeCategory: [any Theme]] {
        let allThemes: [any Theme] = [
            NativeMacOSTheme(),
            SystemTheme(),
            ModernTheme(),
            GlassmorphismTheme(),
            MinimalTheme(),
            DarkTheme(),
            LightTheme(),
            SurveillanceTheme(),
            VibrantTheme(),
            MonochromeTheme()
        ]
        
        return Dictionary(grouping: allThemes) { $0.category }
    }
    
    init() {
        loadCustomThemes()
    }
    
    // MARK: - Theme Switching with Transitions
    
    func switchTheme(to newTheme: any Theme, animated: Bool = true) {
        guard !isTransitioning else { return }
        
        if animated {
            animateThemeTransition(to: newTheme)
        } else {
            currentTheme = newTheme
        }
        
        // Save theme preference
        saveThemePreference(newTheme)
    }
    
    private func animateThemeTransition(to newTheme: any Theme) {
        isTransitioning = true
        fromTheme = currentTheme
        toTheme = newTheme
        transitionProgress = 0.0
        
        // Create smooth transition over theme's preferred duration
        let duration = newTheme.transitionDuration
        let steps = Int(duration * 60) // 60 FPS
        let stepDuration = duration / Double(steps)
        
        transitionTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { _ in
            Task { @MainActor in
                self.transitionProgress += 1.0 / Double(steps)
                
                if self.transitionProgress >= 1.0 {
                    self.completeTransition()
                }
            }
        }
    }
    
    private func completeTransition() {
        transitionTimer?.invalidate()
        transitionTimer = nil
        
        if let newTheme = toTheme {
            currentTheme = newTheme
        }
        
        isTransitioning = false
        transitionProgress = 0.0
        fromTheme = nil
        toTheme = nil
    }
    
    // MARK: - Custom Theme Creation
    
    func createCustomTheme(named name: String, basedOn baseTheme: any Theme) -> CustomTheme {
        let customTheme = CustomTheme(
            name: name,
            baseTheme: baseTheme,
            customizations: ThemeCustomizations()
        )
        
        customThemes.append(customTheme)
        saveCustomThemes()
        
        return customTheme
    }
    
    func updateCustomTheme(_ theme: CustomTheme, customizations: ThemeCustomizations) {
        if let index = customThemes.firstIndex(where: { $0.id == theme.id }) {
            customThemes[index].customizations = customizations
            saveCustomThemes()
        }
    }
    
    func deleteCustomTheme(_ theme: CustomTheme) {
        customThemes.removeAll { $0.id == theme.id }
        saveCustomThemes()
    }
    
    // MARK: - Theme Interpolation for Transitions
    
    /// Interpolates between two themes based on progress (0.0 to 1.0)
    func interpolatedTheme(from: any Theme, to: any Theme, progress: Double) -> InterpolatedTheme {
        let clampedProgress = max(0.0, min(1.0, progress))
        
        return InterpolatedTheme(
            fromTheme: from,
            toTheme: to,
            progress: clampedProgress
        )
    }
    
    // MARK: - Theme Persistence
    
    private func saveThemePreference(_ theme: any Theme) {
        UserDefaults.standard.set(theme.id, forKey: "SelectedThemeID")
    }
    
    func loadSavedTheme() -> any Theme {
        guard let themeID = UserDefaults.standard.string(forKey: "SelectedThemeID") else {
            return NativeMacOSTheme()
        }
        
        // Find theme by ID
        let allThemes = themesByCategory.values.flatMap { $0 }
        return allThemes.first { $0.id == themeID } ?? NativeMacOSTheme()
    }
    
    private func saveCustomThemes() {
        do {
            let data = try JSONEncoder().encode(customThemes)
            UserDefaults.standard.set(data, forKey: "CustomThemes")
        } catch {
            DebugLog.error("Failed to save custom themes: \(error)")
        }
    }
    
    private func loadCustomThemes() {
        guard let data = UserDefaults.standard.data(forKey: "CustomThemes") else { return }
        
        do {
            customThemes = try JSONDecoder().decode([CustomTheme].self, from: data)
        } catch {
            DebugLog.error("Failed to load custom themes: \(error)")
        }
    }
}

// MARK: - Custom Theme Support

struct CustomTheme: Identifiable, Codable {
    let id = UUID()
    var name: String
    let baseThemeID: String
    var customizations: ThemeCustomizations
    
    init(name: String, baseTheme: any Theme, customizations: ThemeCustomizations) {
        self.name = name
        self.baseThemeID = baseTheme.id
        self.customizations = customizations
    }
}

struct ThemeCustomizations: Codable {
    var accentColor: ColorCustomization?
    var cornerRadius: CGFloat?
    var spacing: CGFloat?
    var shadowIntensity: Double?
    var blurIntensity: CGFloat?
    var animationSpeed: Double?
    
    init() {}
}

struct ColorCustomization: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(color: Color) {
        // Extract color components (simplified)
        self.red = 0.5
        self.green = 0.5
        self.blue = 0.5
        self.alpha = 1.0
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Theme Interpolation Support

/// A theme that interpolates between two themes for smooth transitions
struct InterpolatedTheme: Theme {
    let fromTheme: any Theme
    let toTheme: any Theme
    let progress: Double
    
    var name: String { "Transitioning" }
    var id: String { "interpolated" }
    var category: ThemeCategory { .custom }
    
    // Interpolated properties
    var backgroundMaterial: Material {
        progress < 0.5 ? fromTheme.backgroundMaterial : toTheme.backgroundMaterial
    }
    
    var backgroundColor: Color {
        interpolateColor(from: fromTheme.backgroundColor, to: toTheme.backgroundColor)
    }
    
    var primaryColor: Color {
        interpolateColor(from: fromTheme.primaryColor, to: toTheme.primaryColor)
    }
    
    var secondaryColor: Color {
        interpolateColor(from: fromTheme.secondaryColor, to: toTheme.secondaryColor)
    }
    
    var accentColor: Color {
        interpolateColor(from: fromTheme.accentColor, to: toTheme.accentColor)
    }
    
    var glassEffect: Material {
        progress < 0.5 ? fromTheme.glassEffect : toTheme.glassEffect
    }
    
    var cardBackground: Color {
        interpolateColor(from: fromTheme.cardBackground, to: toTheme.cardBackground)
    }
    
    var textPrimary: Color {
        interpolateColor(from: fromTheme.textPrimary, to: toTheme.textPrimary)
    }
    
    var textSecondary: Color {
        interpolateColor(from: fromTheme.textSecondary, to: toTheme.textSecondary)
    }
    
    // Design system properties
    var depthLayer1: Material { progress < 0.5 ? fromTheme.depthLayer1 : toTheme.depthLayer1 }
    var depthLayer2: Material { progress < 0.5 ? fromTheme.depthLayer2 : toTheme.depthLayer2 }
    var depthLayer3: Material { progress < 0.5 ? fromTheme.depthLayer3 : toTheme.depthLayer3 }
    
    var ambientGlow: Color {
        interpolateColor(from: fromTheme.ambientGlow, to: toTheme.ambientGlow)
    }
    
    var contextualAccent: Color {
        interpolateColor(from: fromTheme.contextualAccent, to: toTheme.contextualAccent)
    }
    
    var fluidCornerRadius: CGFloat {
        interpolateValue(from: fromTheme.fluidCornerRadius, to: toTheme.fluidCornerRadius)
    }
    
    // Advanced properties
    var shadowColor: Color { interpolateColor(from: fromTheme.shadowColor, to: toTheme.shadowColor) }
    var borderColor: Color { interpolateColor(from: fromTheme.borderColor, to: toTheme.borderColor) }
    var errorColor: Color { interpolateColor(from: fromTheme.errorColor, to: toTheme.errorColor) }
    var warningColor: Color { interpolateColor(from: fromTheme.warningColor, to: toTheme.warningColor) }
    var successColor: Color { interpolateColor(from: fromTheme.successColor, to: toTheme.successColor) }
    var focusColor: Color { interpolateColor(from: fromTheme.focusColor, to: toTheme.focusColor) }
    
    var surfacePrimary: Color { interpolateColor(from: fromTheme.surfacePrimary, to: toTheme.surfacePrimary) }
    var surfaceSecondary: Color { interpolateColor(from: fromTheme.surfaceSecondary, to: toTheme.surfaceSecondary) }
    var surfaceTertiary: Color { interpolateColor(from: fromTheme.surfaceTertiary, to: toTheme.surfaceTertiary) }
    
    var interactiveDefault: Color { interpolateColor(from: fromTheme.interactiveDefault, to: toTheme.interactiveDefault) }
    var interactiveHover: Color { interpolateColor(from: fromTheme.interactiveHover, to: toTheme.interactiveHover) }
    var interactivePressed: Color { interpolateColor(from: fromTheme.interactivePressed, to: toTheme.interactivePressed) }
    var interactiveDisabled: Color { interpolateColor(from: fromTheme.interactiveDisabled, to: toTheme.interactiveDisabled) }
    
    var textTertiary: Color { interpolateColor(from: fromTheme.textTertiary, to: toTheme.textTertiary) }
    var textQuaternary: Color { interpolateColor(from: fromTheme.textQuaternary, to: toTheme.textQuaternary) }
    var textLink: Color { interpolateColor(from: fromTheme.textLink, to: toTheme.textLink) }
    var textOnAccent: Color { interpolateColor(from: fromTheme.textOnAccent, to: toTheme.textOnAccent) }
    
    var transitionDuration: Double { interpolateValue(from: fromTheme.transitionDuration, to: toTheme.transitionDuration) }
    var springResponse: Double { interpolateValue(from: fromTheme.springResponse, to: toTheme.springResponse) }
    var springDamping: Double { interpolateValue(from: fromTheme.springDamping, to: toTheme.springDamping) }
    
    var baseSpacing: CGFloat { interpolateValue(from: fromTheme.baseSpacing, to: toTheme.baseSpacing) }
    var compactSpacing: CGFloat { interpolateValue(from: fromTheme.compactSpacing, to: toTheme.compactSpacing) }
    var comfortableSpacing: CGFloat { interpolateValue(from: fromTheme.comfortableSpacing, to: toTheme.comfortableSpacing) }
    
    var blurRadius: CGFloat { interpolateValue(from: fromTheme.blurRadius, to: toTheme.blurRadius) }
    var shadowRadius: CGFloat { interpolateValue(from: fromTheme.shadowRadius, to: toTheme.shadowRadius) }
    var shadowOpacity: Double { interpolateValue(from: fromTheme.shadowOpacity, to: toTheme.shadowOpacity) }
    
    // Helper methods for interpolation
    private func interpolateColor(from: Color, to: Color) -> Color {
        // Simplified color interpolation - in a real implementation,
        // you'd extract RGB components and interpolate them
        return progress < 0.5 ? from : to
    }
    
    private func interpolateValue<T: Numeric>(from: T, to: T) -> T where T: BinaryFloatingPoint {
        return from + (to - from) * T(progress)
    }
}