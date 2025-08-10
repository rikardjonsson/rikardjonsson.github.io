//
//  ThemePreferencesView.swift
//  Pylon
//
//  Created on 10.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

struct ThemePreferencesView: View {
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: ThemeCategory = .native
    @State private var showingCustomThemeCreator = false
    @State private var previewTheme: (any Theme)? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Theme categories
                categorySelector
                
                Divider()
                
                // Theme grid
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(themesForCategory, id: \.id) { theme in
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: theme.id == themeManager.currentTheme.id,
                                isPreview: previewTheme?.id == theme.id
                            ) {
                                selectTheme(theme)
                            } onPreview: { previewing in
                                previewTheme = previewing ? theme : nil
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Theme Preferences")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("New Theme") {
                        showingCustomThemeCreator = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .sheet(isPresented: $showingCustomThemeCreator) {
            CustomThemeCreatorView(themeManager: themeManager)
        }
        .environment(\.theme, previewTheme ?? themeManager.currentTheme)
        .frame(width: 800, height: 600)
    }
    
    private var categorySelector: some View {
        HStack {
            ForEach(ThemeCategory.allCases, id: \.self) { category in
                Button(category.displayName) {
                    selectedCategory = category
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    selectedCategory == category ? 
                    Color.accentColor.opacity(0.2) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 8)
                )
                .foregroundColor(
                    selectedCategory == category ? 
                    .accentColor : .secondary
                )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    }
    
    private var themesForCategory: [any Theme] {
        themeManager.themesByCategory[selectedCategory] ?? []
    }
    
    private func selectTheme(_ theme: any Theme) {
        themeManager.switchTheme(to: theme, animated: true)
    }
}

struct ThemePreviewCard: View {
    let theme: any Theme
    let isSelected: Bool
    let isPreview: Bool
    let onSelect: () -> Void
    let onPreview: (Bool) -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Theme preview
            themePreviewContent
                .frame(width: 200, height: 120)
                .background(theme.backgroundColor, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .scaleEffect(isHovering ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
            
            // Theme info
            VStack(spacing: 4) {
                Text(theme.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(theme.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Action buttons
            HStack(spacing: 8) {
                Button(isSelected ? "Current" : "Select") {
                    if !isSelected {
                        onSelect()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isSelected)
                
                Button("Preview") {
                    onPreview(!isPreview)
                }
                .buttonStyle(.bordered)
                .foregroundColor(isPreview ? .accentColor : .primary)
            }
        }
        .padding()
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private var themePreviewContent: some View {
        VStack(spacing: 8) {
            // Header bar
            HStack {
                Circle()
                    .fill(theme.accentColor)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(theme.textSecondary)
                    .frame(width: 60, height: 4)
                    .cornerRadius(2)
                
                Spacer()
            }
            
            // Content area
            VStack(spacing: 6) {
                Rectangle()
                    .fill(theme.surfacePrimary)
                    .frame(height: 30)
                    .cornerRadius(6)
                
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(theme.surfaceSecondary)
                        .frame(width: 40, height: 20)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(theme.surfaceSecondary)
                        .frame(width: 60, height: 20)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Bottom accent
            Rectangle()
                .fill(theme.contextualAccent.opacity(0.6))
                .frame(height: 4)
                .cornerRadius(2)
        }
        .padding(8)
    }
    
    private var borderColor: Color {
        if isSelected {
            return .accentColor
        } else if isPreview {
            return .orange
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        isSelected || isPreview ? 2 : 0
    }
}

struct CustomThemeCreatorView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var themeName = ""
    @State private var selectedBaseTheme: any Theme = NativeMacOSTheme()
    @State private var customizations = ThemeCustomizations()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Theme Name", text: $themeName)
                    
                    Picker("Base Theme", selection: Binding(
                        get: { selectedBaseTheme.id },
                        set: { id in
                            if let theme = allThemes.first(where: { $0.id == id }) {
                                selectedBaseTheme = theme
                            }
                        }
                    )) {
                        ForEach(allThemes, id: \.id) { theme in
                            Text(theme.name).tag(theme.id)
                        }
                    }
                }
                
                Section("Customizations") {
                    // Color customizations
                    ColorPicker("Accent Color", selection: Binding(
                        get: { customizations.accentColor?.color ?? selectedBaseTheme.accentColor },
                        set: { color in
                            customizations.accentColor = ColorCustomization(color: color)
                        }
                    ))
                    
                    // Layout customizations
                    if let cornerRadius = customizations.cornerRadius {
                        HStack {
                            Text("Corner Radius")
                            Slider(value: Binding(
                                get: { Double(cornerRadius) },
                                set: { customizations.cornerRadius = CGFloat($0) }
                            ), in: 0...20)
                            Text("\(Int(cornerRadius))pt")
                        }
                    } else {
                        Button("Customize Corner Radius") {
                            customizations.cornerRadius = selectedBaseTheme.fluidCornerRadius
                        }
                    }
                    
                    if let spacing = customizations.spacing {
                        HStack {
                            Text("Base Spacing")
                            Slider(value: Binding(
                                get: { Double(spacing) },
                                set: { customizations.spacing = CGFloat($0) }
                            ), in: 2...24)
                            Text("\(Int(spacing))pt")
                        }
                    } else {
                        Button("Customize Spacing") {
                            customizations.spacing = selectedBaseTheme.baseSpacing
                        }
                    }
                }
                
                Section("Preview") {
                    ThemePreviewCard(
                        theme: selectedBaseTheme,
                        isSelected: false,
                        isPreview: true
                    ) {
                        // Preview action
                    } onPreview: { _ in
                        // Preview toggle
                    }
                }
            }
            .navigationTitle("Create Custom Theme")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createCustomTheme()
                        dismiss()
                    }
                    .disabled(themeName.isEmpty)
                }
            }
        }
        .frame(width: 600, height: 500)
    }
    
    private var allThemes: [any Theme] {
        themeManager.themesByCategory.values.flatMap { $0 }
    }
    
    private func createCustomTheme() {
        let customTheme = themeManager.createCustomTheme(
            named: themeName,
            basedOn: selectedBaseTheme
        )
        themeManager.updateCustomTheme(customTheme, customizations: customizations)
    }
}

// MARK: - Theme Settings Integration
// Theme preferences integration is handled in AppState.swift

#Preview {
    ThemePreferencesView()
}