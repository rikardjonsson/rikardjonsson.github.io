//
//  CalendarWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Calendar widget showing upcoming events
/// Demonstrates rich event data with mock EventKit integration
@MainActor
final class CalendarWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: CalendarContent
    
    // MARK: - Widget Metadata
    
    let title = "Calendar"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = CalendarContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(CalendarConfigurationView())
    }
    
    // MARK: - Main Widget View
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    smallLayout(theme: theme)
                case .medium:
                    mediumLayout(theme: theme)
                case .large:
                    largeLayout(theme: theme)
                case .xlarge:
                    xlargeLayout(theme: theme)
                }
            }
        )
    }
    
    // MARK: - Size-Specific Layouts
    
    private func smallLayout(theme: any Theme) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text("\(content.todayEvents.count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            
            Text("events")
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Today")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text("\(content.todayEvents.count)")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            
            VStack(spacing: 4) {
                ForEach(Array(content.todayEvents.prefix(3)), id: \.id) { event in
                    self.eventRow(event, theme: theme, compact: true)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Upcoming Events")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(Array(content.upcomingEvents.prefix(5)), id: \.id) { event in
                    self.eventRow(event, theme: theme, compact: false)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            // Header with month view
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.largeTitle)
                            .foregroundColor(theme.accentColor)
                        Text("Calendar Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                    }
                    Text("\(content.todayEvents.count) events today • \(content.upcomingEvents.count) upcoming")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Today's events column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(content.todayEvents, id: \.id) { event in
                                eventCardDetailed(event, theme: theme, isToday: true)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .frame(maxWidth: .infinity)
                
                // Upcoming events column
                VStack(alignment: .leading, spacing: 8) {
                    Text("This Week")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(Array(content.upcomingEvents.prefix(8)), id: \.id) { event in
                                eventCardDetailed(event, theme: theme, isToday: false)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Views
    
    private func eventRow(_ event: CalendarEvent, theme: any Theme, compact: Bool) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                if !compact || event.isAllDay {
                    Text(event.isAllDay ? "All day" : formatTime(event.startTime))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    private func eventCardDetailed(_ event: CalendarEvent, theme: any Theme, isToday: Bool) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(event.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                HStack {
                    if event.isAllDay {
                        Text("All day")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    } else {
                        Text(formatTime(event.startTime))
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                    
                    if !isToday {
                        Text("• \(formatDate(event.startTime))")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(theme.surfaceSecondary.opacity(0.3))
        .cornerRadius(6)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Data Models

struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let startTime: Date
    let isAllDay: Bool
    let color: Color
}

// MARK: - Calendar Content

@MainActor
final class CalendarContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var todayEvents: [CalendarEvent] = []
    @Published var upcomingEvents: [CalendarEvent] = []
    
    init() {
        generateMockEvents()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            generateMockEvents()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockEvents() {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink]
        let eventTitles = [
            "Team Standup", "Design Review", "Client Call", "Lunch with Sarah",
            "Gym Session", "Grocery Shopping", "Doctor Appointment", "Book Club",
            "Project Deadline", "Conference Call", "Coffee Break", "Workshop",
            "Meditation", "Code Review", "Birthday Party", "Dentist"
        ]
        
        let calendar = Calendar.current
        let now = Date()
        
        // Generate today's events
        todayEvents = (0..<Int.random(in: 2...4)).map { i in
            let hour = Int.random(in: 9...18)
            let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) ?? now
            
            return CalendarEvent(
                title: eventTitles.randomElement() ?? "Event",
                startTime: startTime,
                isAllDay: Bool.random() && i == 0,
                color: colors.randomElement() ?? .blue
            )
        }.sorted { $0.startTime < $1.startTime }
        
        // Generate upcoming events
        upcomingEvents = (0..<Int.random(in: 8...12)).map { i in
            let daysAhead = Int.random(in: 1...7)
            let hour = Int.random(in: 9...20)
            let futureDate = calendar.date(byAdding: .day, value: daysAhead, to: now) ?? now
            let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: futureDate) ?? futureDate
            
            return CalendarEvent(
                title: eventTitles.randomElement() ?? "Event",
                startTime: startTime,
                isAllDay: Bool.random() && i < 2,
                color: colors.randomElement() ?? .blue
            )
        }.sorted { $0.startTime < $1.startTime }
    }
}

// MARK: - Configuration View

struct CalendarConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Calendar Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows upcoming calendar events with mock data. In a real implementation, this would integrate with EventKit to display actual calendar events.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}