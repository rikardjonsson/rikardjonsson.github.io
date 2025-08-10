//
//  ThemeComponents.swift
//  Pylon
//
//  Created on 10.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

// MARK: - Theme-Aware Components

/// A theme-aware button with multiple styles
struct ThemedButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let size: ControlSize
    
    @Environment(\.theme) private var theme
    
    enum ButtonStyle {
        case primary
        case secondary 
        case destructive
        case ghost
        case outline
    }
    
    init(_ title: String, style: ButtonStyle = .primary, size: ControlSize = .regular, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.compactSpacing) {
                Text(title)
                    .font(fontForSize(size))
                    .fontWeight(style == .primary ? .semibold : .medium)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundForStyle, in: backgroundShape)
            .foregroundColor(foregroundColorForStyle)
            .overlay(
                backgroundShape
                    .stroke(borderColorForStyle, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(pressed ? 0.98 : 1.0)
        .animation(.spring(response: theme.springResponse, dampingFraction: theme.springDamping), value: pressed)
    }
    
    @State private var pressed = false
    
    private var backgroundForStyle: Color {
        switch style {
        case .primary:
            return theme.accentColor
        case .secondary:
            return theme.surfaceSecondary
        case .destructive:
            return theme.errorColor
        case .ghost:
            return Color.clear
        case .outline:
            return Color.clear
        }
    }
    
    private var foregroundColorForStyle: Color {
        switch style {
        case .primary, .destructive:
            return theme.textOnAccent
        case .secondary:
            return theme.textPrimary
        case .ghost, .outline:
            return theme.accentColor
        }
    }
    
    private var borderColorForStyle: Color {
        switch style {
        case .outline:
            return theme.accentColor
        case .secondary:
            return theme.borderColor
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        style == .outline || style == .secondary ? 1 : 0
    }
    
    private var backgroundShape: some Shape {
        RoundedRectangle(cornerRadius: theme.fluidCornerRadius / 2)
    }
    
    private func fontForSize(_ size: ControlSize) -> Font {
        switch size {
        case .mini:
            return .caption2
        case .small:
            return .caption
        case .regular:
            return .body
        case .large:
            return .title3
        @unknown default:
            return .body
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .mini:
            return theme.baseSpacing
        case .small:
            return theme.baseSpacing * 1.5
        case .regular:
            return theme.baseSpacing * 2
        case .large:
            return theme.baseSpacing * 3
        @unknown default:
            return theme.baseSpacing * 2
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .mini:
            return theme.compactSpacing / 2
        case .small:
            return theme.compactSpacing
        case .regular:
            return theme.baseSpacing
        case .large:
            return theme.baseSpacing * 1.5
        @unknown default:
            return theme.baseSpacing
        }
    }
}

/// Theme-aware card container
struct ThemedCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let padding: EdgeInsets?
    
    @Environment(\.theme) private var theme
    
    enum CardStyle {
        case elevated
        case flat 
        case glass
        case outline
    }
    
    init(style: CardStyle = .elevated, padding: EdgeInsets? = nil, @ViewBuilder content: () -> Content) {
        self.style = style
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding ?? defaultPadding)
            .background(backgroundForStyle, in: cardShape)
            .overlay(overlayForStyle)
            .shadow(
                color: shadowColorForStyle,
                radius: shadowRadiusForStyle,
                x: shadowOffsetForStyle.x,
                y: shadowOffsetForStyle.y
            )
    }
    
    private var cardShape: some Shape {
        RoundedRectangle(cornerRadius: theme.fluidCornerRadius)
    }
    
    private var defaultPadding: EdgeInsets {
        EdgeInsets(
            top: theme.comfortableSpacing,
            leading: theme.comfortableSpacing,
            bottom: theme.comfortableSpacing,
            trailing: theme.comfortableSpacing
        )
    }
    
    private var backgroundForStyle: some ShapeStyle {
        switch style {
        case .elevated, .flat:
            return AnyShapeStyle(theme.surfacePrimary)
        case .glass:
            return AnyShapeStyle(theme.glassEffect)
        case .outline:
            return AnyShapeStyle(Color.clear)
        }
    }
    
    private var overlayForStyle: some View {
        Group {
            if style == .outline {
                cardShape
                    .stroke(theme.borderColor, lineWidth: 1)
            } else {
                EmptyView()
            }
        }
    }
    
    private var shadowColorForStyle: Color {
        switch style {
        case .elevated:
            return theme.shadowColor
        case .glass:
            return theme.shadowColor.opacity(0.1)
        default:
            return Color.clear
        }
    }
    
    private var shadowRadiusForStyle: CGFloat {
        switch style {
        case .elevated:
            return theme.shadowRadius
        case .glass:
            return theme.shadowRadius * 2
        default:
            return 0
        }
    }
    
    private var shadowOffsetForStyle: CGPoint {
        switch style {
        case .elevated, .glass:
            return CGPoint(x: 0, y: theme.shadowRadius / 4)
        default:
            return .zero
        }
    }
}

/// Theme-aware text input field
struct ThemedTextField: View {
    @Binding var text: String
    let placeholder: String
    let style: TextFieldStyle
    
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool
    
    enum TextFieldStyle {
        case standard
        case filled
        case outline
    }
    
    init(_ placeholder: String, text: Binding<String>, style: TextFieldStyle = .standard) {
        self.placeholder = placeholder
        self._text = text
        self.style = style
    }
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.horizontal, theme.baseSpacing)
            .padding(.vertical, theme.baseSpacing)
            .background(backgroundForStyle, in: fieldShape)
            .overlay(overlayForStyle)
            .foregroundColor(theme.textPrimary)
            .focused($isFocused)
            .animation(.spring(response: theme.springResponse, dampingFraction: theme.springDamping), value: isFocused)
    }
    
    private var fieldShape: some Shape {
        RoundedRectangle(cornerRadius: theme.fluidCornerRadius / 2)
    }
    
    private var backgroundForStyle: Color {
        switch style {
        case .standard:
            return Color.clear
        case .filled:
            return theme.surfaceSecondary
        case .outline:
            return Color.clear
        }
    }
    
    private var overlayForStyle: some View {
        fieldShape
            .stroke(borderColor, lineWidth: borderWidth)
    }
    
    private var borderColor: Color {
        if isFocused {
            return theme.focusColor
        } else {
            switch style {
            case .standard:
                return theme.borderColor.opacity(0.5)
            case .filled:
                return Color.clear
            case .outline:
                return theme.borderColor
            }
        }
    }
    
    private var borderWidth: CGFloat {
        isFocused ? 2 : (style == .standard ? 0 : 1)
    }
}

/// Theme-aware divider
struct ThemedDivider: View {
    let style: DividerStyle
    
    @Environment(\.theme) private var theme
    
    enum DividerStyle {
        case thin
        case thick
        case gradient
    }
    
    init(style: DividerStyle = .thin) {
        self.style = style
    }
    
    var body: some View {
        Rectangle()
            .fill(fillForStyle)
            .frame(height: heightForStyle)
    }
    
    private var heightForStyle: CGFloat {
        switch style {
        case .thin:
            return 1
        case .thick:
            return 2
        case .gradient:
            return 1
        }
    }
    
    private var fillForStyle: some ShapeStyle {
        switch style {
        case .thin, .thick:
            return AnyShapeStyle(theme.borderColor.opacity(0.5))
        case .gradient:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color.clear,
                        theme.borderColor.opacity(0.5),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

/// Theme-aware status indicator
struct ThemedStatusIndicator: View {
    let status: Status
    let size: IndicatorSize
    let showLabel: Bool
    
    @Environment(\.theme) private var theme
    
    enum Status {
        case success
        case warning
        case error
        case info
        case loading
        
        var color: (any Theme) -> Color {
            switch self {
            case .success:
                return \.successColor
            case .warning:
                return \.warningColor
            case .error:
                return \.errorColor
            case .info:
                return \.accentColor
            case .loading:
                return \.accentColor
            }
        }
        
        var iconName: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .warning:
                return "exclamationmark.triangle.fill"
            case .error:
                return "xmark.circle.fill"
            case .info:
                return "info.circle.fill"
            case .loading:
                return "arrow.triangle.2.circlepath"
            }
        }
        
        var label: String {
            switch self {
            case .success:
                return "Success"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            case .info:
                return "Info"
            case .loading:
                return "Loading"
            }
        }
    }
    
    enum IndicatorSize {
        case small
        case medium
        case large
        
        var iconSize: CGFloat {
            switch self {
            case .small:
                return 12
            case .medium:
                return 16
            case .large:
                return 24
            }
        }
        
        var font: Font {
            switch self {
            case .small:
                return .caption2
            case .medium:
                return .caption
            case .large:
                return .body
            }
        }
    }
    
    init(status: Status, size: IndicatorSize = .medium, showLabel: Bool = false) {
        self.status = status
        self.size = size
        self.showLabel = showLabel
    }
    
    var body: some View {
        HStack(spacing: theme.compactSpacing) {
            Image(systemName: status.iconName)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(status.color(theme))
                .rotationEffect(.degrees(status == .loading ? rotationAngle : 0))
                .animation(
                    status == .loading ? 
                    .linear(duration: 1.0).repeatForever(autoreverses: false) : 
                    .none, 
                    value: rotationAngle
                )
            
            if showLabel {
                Text(status.label)
                    .font(size.font)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .onAppear {
            if status == .loading {
                withAnimation {
                    rotationAngle = 360
                }
            }
        }
    }
    
    @State private var rotationAngle: Double = 0
}

// MARK: - Theme Modifier Extensions

extension View {
    /// Applies theme-aware styling to any view
    func themedBackground(_ style: ThemedCard<EmptyView>.CardStyle = .flat) -> some View {
        self.modifier(ThemedBackgroundModifier(style: style))
    }
    
    /// Applies theme-aware padding
    func themedPadding(_ multiplier: CGFloat = 1.0) -> some View {
        self.modifier(ThemedPaddingModifier(multiplier: multiplier))
    }
    
    /// Applies theme-aware shadow
    func themedShadow(_ intensity: CGFloat = 1.0) -> some View {
        self.modifier(ThemedShadowModifier(intensity: intensity))
    }
}

// MARK: - Theme Modifiers

struct ThemedBackgroundModifier: ViewModifier {
    let style: ThemedCard<EmptyView>.CardStyle
    @Environment(\.theme) private var theme
    
    func body(content: Content) -> some View {
        content
            .background(backgroundForStyle, in: RoundedRectangle(cornerRadius: theme.fluidCornerRadius))
    }
    
    private var backgroundForStyle: some ShapeStyle {
        switch style {
        case .elevated, .flat:
            return AnyShapeStyle(theme.surfacePrimary)
        case .glass:
            return AnyShapeStyle(theme.glassEffect)
        case .outline:
            return AnyShapeStyle(Color.clear)
        }
    }
}

struct ThemedPaddingModifier: ViewModifier {
    let multiplier: CGFloat
    @Environment(\.theme) private var theme
    
    func body(content: Content) -> some View {
        content
            .padding(theme.baseSpacing * multiplier)
    }
}

struct ThemedShadowModifier: ViewModifier {
    let intensity: CGFloat
    @Environment(\.theme) private var theme
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: theme.shadowColor.opacity(theme.shadowOpacity * intensity),
                radius: theme.shadowRadius * intensity,
                x: 0,
                y: theme.shadowRadius * intensity / 2
            )
    }
}

// MARK: - Preview Helpers

#Preview("Themed Components") {
    VStack(spacing: 16) {
        ThemedButton("Primary Button") { }
        ThemedButton("Secondary", style: .secondary) { }
        ThemedButton("Destructive", style: .destructive) { }
        
        ThemedCard {
            VStack {
                Text("Card Content")
                ThemedTextField("Enter text", text: .constant(""))
            }
        }
        
        ThemedDivider()
        
        HStack {
            ThemedStatusIndicator(status: .success, showLabel: true)
            ThemedStatusIndicator(status: .warning, showLabel: true)
            ThemedStatusIndicator(status: .error, showLabel: true)
        }
    }
    .padding()
    .environment(\.theme, NativeMacOSTheme())
}