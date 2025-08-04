//
//  NotesWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Notes widget showing recent notes preview
/// Demonstrates text content with mock Notes app integration
@MainActor
final class NotesWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    @Published private var content: NotesContent
    
    let title = "Notes"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = NotesContent()
    }
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(NotesConfigurationView())
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    VStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                        Text("\(content.notes.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                        Text("notes")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                    }
                case .medium:
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.title2)
                                .foregroundColor(theme.accentColor)
                            Text("Recent Notes")
                                .font(.headline)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        VStack(spacing: 4) {
                            ForEach(Array(content.notes.prefix(3)), id: \.id) { note in
                                self.noteRow(note, theme: theme, compact: true)
                            }
                        }
                        Spacer()
                    }
                case .large:
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.title)
                                .foregroundColor(theme.accentColor)
                            Text("Notes")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        VStack(spacing: 6) {
                            ForEach(Array(content.notes.prefix(5)), id: \.id) { note in
                                self.noteRow(note, theme: theme, compact: false)
                            }
                        }
                        Spacer()
                    }
                case .xlarge:
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Notes")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.textPrimary)
                            VStack(spacing: 8) {
                                ForEach(content.notes, id: \.id) { note in
                                    noteRowDetailed(note, theme: theme)
                                }
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private func noteRow(_ note: Note, theme: any Theme, compact: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(note.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                if !compact {
                    Text(note.preview)
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(2)
                }
            }
            Spacer()
            Text(formatDate(note.modifiedDate))
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
    }
    
    private func noteRowDetailed(_ note: Note, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                Spacer()
                Text(formatDate(note.modifiedDate))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
            Text(note.preview)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct Note: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let modifiedDate: Date
}

@MainActor
final class NotesContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var notes: [Note] = []
    
    init() {
        generateMockNotes()
        lastUpdated = Date()
    }
    
    func refresh() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 1_000_000_000)
        generateMockNotes()
        lastUpdated = Date()
        isLoading = false
    }
    
    private func generateMockNotes() {
        let noteTitles = [
            "Meeting Notes", "Project Ideas", "Shopping List", "Weekend Plans",
            "Book Recommendations", "Recipe: Pasta", "Travel Itinerary", "Code Snippets"
        ]
        let previews = [
            "Discussed quarterly goals and upcoming deadlines. Key action items include...",
            "New app concept for productivity. Features: dark mode, sync, widgets...",
            "Milk, bread, eggs, apples, chicken, rice, coffee beans, yogurt...",
            "Saturday: hiking in the mountains. Sunday: brunch with friends...",
            "The Design of Everyday Things, Atomic Habits, Deep Work...",
            "Fresh pasta with tomato sauce and basil. Cook for 8-10 minutes...",
            "Flight at 9AM, hotel check-in at 3PM, dinner reservation at 7PM...",
            "Swift async/await patterns, SwiftUI animations, Core Data setup..."
        ]
        
        notes = (0..<Int.random(in: 5...8)).map { i in
            let daysAgo = Int.random(in: 0...14)
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            
            return Note(
                title: noteTitles[i % noteTitles.count],
                preview: previews[i % previews.count],
                modifiedDate: date
            )
        }.sorted { $0.modifiedDate > $1.modifiedDate }
    }
}

struct NotesConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Notes Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            Text("Shows recent notes with preview text. Would integrate with Notes app via AppleScript.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}