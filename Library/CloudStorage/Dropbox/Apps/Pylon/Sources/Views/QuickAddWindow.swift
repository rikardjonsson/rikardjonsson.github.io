//
//  QuickAddWindow.swift
//  Pylon
//
//  Created on 08.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

struct QuickAddWindow: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: WidgetCategory = .all
    
    // Available widget types that can be added
    private let availableWidgets: [WidgetTemplate] = [
        WidgetTemplate(name: "Calendar", category: .productivity, icon: "calendar", description: "View upcoming events and meetings"),
        WidgetTemplate(name: "Clock", category: .productivity, icon: "clock", description: "Current time with multiple formats"),
        WidgetTemplate(name: "Weather", category: .information, icon: "cloud.sun", description: "Local weather conditions"),
        WidgetTemplate(name: "Reminders", category: .productivity, icon: "checklist", description: "Your upcoming tasks and reminders"),
        WidgetTemplate(name: "Notes", category: .productivity, icon: "note.text", description: "Quick access to recent notes"),
        WidgetTemplate(name: "Email", category: .communication, icon: "envelope", description: "Unread email count and recent messages"),
        WidgetTemplate(name: "System Monitor", category: .system, icon: "cpu", description: "CPU, memory, and disk usage"),
        WidgetTemplate(name: "Network", category: .system, icon: "network", description: "Network status and activity"),
        WidgetTemplate(name: "Finance", category: .information, icon: "dollarsign.circle", description: "Stock prices and financial data"),
        WidgetTemplate(name: "Fitness", category: .health, icon: "figure.walk", description: "Activity rings and health metrics"),
        WidgetTemplate(name: "Music", category: .entertainment, icon: "music.note", description: "Currently playing music controls"),
        WidgetTemplate(name: "Photos", category: .entertainment, icon: "photo", description: "Recent photos from your library")
    ]
    
    private var filteredWidgets: [WidgetTemplate] {
        var widgets = availableWidgets
        
        // Filter by category
        if selectedCategory != .all {
            widgets = widgets.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            widgets = widgets.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return widgets
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Add Widget")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Choose a widget to add to your dashboard")
                        .foregroundColor(.secondary)
                }
                
                // Search and Filter
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search widgets...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Category", selection: $selectedCategory) {
                        Text("All").tag(WidgetCategory.all)
                        Text("Productivity").tag(WidgetCategory.productivity)
                        Text("Information").tag(WidgetCategory.information)
                        Text("Communication").tag(WidgetCategory.communication)
                        Text("System").tag(WidgetCategory.system)
                        Text("Health").tag(WidgetCategory.health)
                        Text("Entertainment").tag(WidgetCategory.entertainment)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 140)
                }
                
                // Widget Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(filteredWidgets, id: \.name) { widget in
                            WidgetTemplateCard(template: widget) {
                                addWidget(widget)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Actions
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.escape)
                    
                    Spacer()
                }
            }
            .padding()
            .frame(width: 600, height: 500)
        }
    }
    
    private func addWidget(_ template: WidgetTemplate) {
        // TODO: Implement actual widget creation based on template
        // For now, just dismiss the window
        print("Adding widget: \(template.name)")
        dismiss()
    }
}

struct WidgetTemplate {
    let name: String
    let category: WidgetCategory
    let icon: String
    let description: String
}

struct WidgetTemplateCard: View {
    let template: WidgetTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: template.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                    .frame(height: 40)
                
                // Content
                VStack(spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                // Category badge
                Text(template.category.rawValue.uppercased())
                    .font(.system(.caption2, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(categoryColor(template.category))
                    .clipShape(Capsule())
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color(.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separatorColor), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            // TODO: Add hover effects if desired
        }
    }
    
    private func categoryColor(_ category: WidgetCategory) -> Color {
        switch category {
        case .productivity: return .blue
        case .information: return .green
        case .communication: return .orange
        case .system: return .purple
        case .health: return .red
        case .entertainment: return .pink
        case .all: return .gray
        }
    }
}

#Preview {
    QuickAddWindow()
        .environmentObject(AppState())
}