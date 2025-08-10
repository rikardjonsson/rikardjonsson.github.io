//
//  CalendarWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit

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
            if content.authorizationStatus.canReadEvents {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("\(content.todayEvents.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Text(content.todayEvents.count == 1 ? "event" : "events")
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            } else {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.title2)
                    .foregroundColor(theme.warningColor)
                
                Text("Access")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Text("Required")
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: content.authorizationStatus.canReadEvents ? "calendar" : "calendar.badge.exclamationmark")
                    .font(.title2)
                    .foregroundColor(content.authorizationStatus.canReadEvents ? theme.accentColor : theme.warningColor)
                
                Text(content.authorizationStatus.canReadEvents ? "Today" : "Calendar")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                if content.authorizationStatus.canReadEvents {
                    Text("\(content.todayEvents.count)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            if content.authorizationStatus.canReadEvents {
                if content.todayEvents.isEmpty {
                    Text("No events today")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 4) {
                        ForEach(Array(content.todayEvents.prefix(3)), id: \.id) { event in
                            self.eventRow(event, theme: theme, compact: true)
                        }
                    }
                }
            } else {
                VStack(spacing: 4) {
                    Text("Calendar access required")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Tap to grant permission")
                        .font(.caption)
                        .foregroundColor(theme.accentColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        await content.requestCalendarAccess()
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: content.authorizationStatus.canReadEvents ? "calendar" : "calendar.badge.exclamationmark")
                    .font(.title)
                    .foregroundColor(content.authorizationStatus.canReadEvents ? theme.accentColor : theme.warningColor)
                
                Text(content.authorizationStatus.canReadEvents ? "Upcoming Events" : "Calendar Access")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                if content.authorizationStatus.canReadEvents && content.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if content.authorizationStatus.canReadEvents {
                if content.upcomingEvents.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title2)
                            .foregroundColor(theme.textTertiary)
                        
                        Text("No upcoming events")
                            .font(.headline)
                            .foregroundColor(theme.textSecondary)
                        
                        Text("Your schedule is clear!")
                            .font(.subheadline)
                            .foregroundColor(theme.textTertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(Array(content.upcomingEvents.prefix(8)), id: \.id) { event in
                                self.eventRow(event, theme: theme, compact: false)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 40))
                        .foregroundColor(theme.warningColor)
                    
                    VStack(spacing: 8) {
                        Text("Calendar Access Required")
                            .font(.headline)
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Grant calendar access to view your upcoming events and stay organized.")
                            .font(.subheadline)
                            .foregroundColor(theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        Task {
                            await content.requestCalendarAccess()
                        }
                    } label: {
                        Text("Grant Access")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(theme.accentColor, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            // Enhanced header with status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: content.authorizationStatus.canReadEvents ? "calendar" : "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(content.authorizationStatus.canReadEvents ? theme.accentColor : theme.warningColor)
                        
                        Text("Calendar Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                    }
                    
                    if content.authorizationStatus.canReadEvents {
                        HStack {
                            Text("\(content.todayEvents.count) events today • \(content.upcomingEvents.count) upcoming")
                                .font(.subheadline)
                                .foregroundColor(theme.textSecondary)
                            
                            if !content.availableCalendars.isEmpty {
                                Text("• \(content.availableCalendars.count) calendars")
                                    .font(.subheadline)
                                    .foregroundColor(theme.textTertiary)
                            }
                        }
                    } else {
                        Text(content.authorizationStatus.displayName)
                            .font(.subheadline)
                            .foregroundColor(theme.warningColor)
                    }
                }
                
                Spacer()
                
                if content.authorizationStatus.canReadEvents && content.isLoading {
                    ProgressView()
                        .scaleEffect(0.9)
                }
            }
            
            if content.authorizationStatus.canReadEvents {
                HStack(spacing: 16) {
                    // Today's events column
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Today")
                                .font(.headline)
                                .foregroundColor(theme.textPrimary)
                            
                            Spacer()
                            
                            Text(currentDateString())
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                        }
                        
                        if content.todayEvents.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "sun.max")
                                    .font(.title2)
                                    .foregroundColor(theme.textTertiary)
                                Text("Free day!")
                                    .font(.subheadline)
                                    .foregroundColor(theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 6) {
                                    ForEach(content.todayEvents, id: \.id) { event in
                                        self.eventCardDetailed(event, theme: theme, isToday: true)
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Upcoming events column
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This Week")
                            .font(.headline)
                            .foregroundColor(theme.textPrimary)
                        
                        if content.upcomingEvents.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.title2)
                                    .foregroundColor(theme.textTertiary)
                                Text("No upcoming events")
                                    .font(.subheadline)
                                    .foregroundColor(theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 6) {
                                    ForEach(Array(content.upcomingEvents.prefix(10)), id: \.id) { event in
                                        self.eventCardDetailed(event, theme: theme, isToday: false)
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Permission request UI for xlarge layout
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(theme.warningColor)
                    
                    VStack(spacing: 12) {
                        Text("Calendar Access Required")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Pylon needs access to your calendar to display upcoming events and help you stay organized.")
                            .font(.body)
                            .foregroundColor(theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                    
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await content.requestCalendarAccess()
                            }
                        } label: {
                            Text("Grant Calendar Access")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(theme.accentColor, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        
                        Text("You can also enable this in System Preferences > Security & Privacy > Privacy > Calendars")
                            .font(.caption)
                            .foregroundColor(theme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Helper Views
    
    private func eventRow(_ event: CalendarEvent, theme: any Theme, compact: Bool) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.color)
                .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    if event.isAllDay {
                        Text("All day")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                    } else {
                        Text(event.displayTime)
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                    }
                    
                    if let location = event.location, !compact {
                        Text("• \(location)")
                            .font(.caption2)
                            .foregroundColor(theme.textTertiary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func eventCardDetailed(_ event: CalendarEvent, theme: any Theme, isToday: Bool) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(event.color)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if event.isAllDay {
                        Text("All day")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    } else {
                        Text(event.displayTime)
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                    
                    if !isToday {
                        Text("• \(event.displayDate)")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                
                if let location = event.location {
                    HStack {
                        Image(systemName: "location")
                            .font(.caption2)
                            .foregroundColor(theme.textTertiary)
                        Text(location)
                            .font(.caption)
                            .foregroundColor(theme.textTertiary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(theme.surfaceSecondary.opacity(0.6))
        .cornerRadius(theme.fluidCornerRadius / 2)
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
// CalendarEvent is now defined in CalendarService.swift

// MARK: - Calendar Content

@MainActor
final class CalendarContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var authorizationStatus: CalendarAuthorizationStatus = .notDetermined
    
    @Published var todayEvents: [CalendarEvent] = []
    @Published var upcomingEvents: [CalendarEvent] = []
    @Published var availableCalendars: [String] = []
    
    private let calendarService = CalendarService()
    private var useMockData = false
    
    init() {
        Task {
            await initializeCalendarAccess()
        }
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            if useMockData {
                // Fallback to mock data if calendar access is not available
                try await Task.sleep(nanoseconds: 500_000_000) // Shorter delay for mock
                generateMockEvents()
            } else {
                // Fetch real calendar events
                async let todayEventsFetch = calendarService.fetchTodayEvents()
                async let upcomingEventsFetch = calendarService.fetchUpcomingEvents()
                
                let (fetchedTodayEvents, fetchedUpcomingEvents) = try await (todayEventsFetch, upcomingEventsFetch)
                
                todayEvents = fetchedTodayEvents.sorted { $0.startTime < $1.startTime }
                upcomingEvents = fetchedUpcomingEvents.sorted { $0.startTime < $1.startTime }
            }
            
            lastUpdated = Date()
        } catch {
            // Fallback to mock data on error
            DebugLog.error("Failed to fetch calendar events: \(error)")
            generateMockEvents()
            self.error = error
        }
        
        isLoading = false
    }
    
    private func initializeCalendarAccess() async {
        authorizationStatus = await calendarService.checkAuthorizationStatus()
        
        if authorizationStatus == .notDetermined {
            let granted = await calendarService.requestAccess()
            authorizationStatus = granted ? .authorized : .denied
        }
        
        useMockData = !authorizationStatus.canReadEvents
        
        if authorizationStatus.canReadEvents {
            // Load available calendars
            let calendars = await calendarService.getAvailableCalendars()
            await MainActor.run {
                availableCalendars = calendars.map { $0.title }
            }
        }
        
        // Initial data load
        try? await refresh()
    }
    
    private func generateMockEvents() {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .cyan]
        let eventTitles = [
            "Team Standup", "Design Review", "Client Call", "Lunch Meeting",
            "Workout", "Grocery Shopping", "Doctor Appointment", "Book Club",
            "Project Deadline", "Conference Call", "Coffee Break", "Workshop",
            "Meditation Session", "Code Review", "Birthday Celebration", "Dentist Visit",
            "Team Retrospective", "Product Demo", "All Hands Meeting", "Training Session"
        ]
        
        let calendar = Calendar.current
        let now = Date()
        
        // Generate today's events with realistic timing
        todayEvents = (0..<Int.random(in: 1...3)).compactMap { i in
            let hour = [9, 11, 14, 16, 18].randomElement() ?? 10
            let minute = [0, 15, 30, 45].randomElement() ?? 0
            guard let startTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) else {
                return nil
            }
            
            let isAllDay = i == 0 && Bool.random() && Bool.random() // Less likely to be all day
            let endTime = isAllDay ? startTime : calendar.date(byAdding: .hour, value: Int.random(in: 1...2), to: startTime) ?? startTime
            
            return CalendarEvent(
                id: UUID().uuidString,
                title: eventTitles.randomElement() ?? "Event",
                startTime: startTime,
                endTime: endTime,
                isAllDay: isAllDay,
                color: colors.randomElement() ?? .blue,
                location: Bool.random() ? ["Conference Room A", "Zoom", "Coffee Shop", "Office"].randomElement() : nil,
                notes: nil,
                calendar: "Mock Calendar"
            )
        }.sorted { $0.startTime < $1.startTime }
        
        // Generate upcoming events across the week
        upcomingEvents = (0..<Int.random(in: 6...10)).compactMap { i in
            let daysAhead = Int.random(in: 1...7)
            let hour = Int.random(in: 8...19)
            let minute = [0, 15, 30, 45].randomElement() ?? 0
            
            guard let futureDate = calendar.date(byAdding: .day, value: daysAhead, to: now),
                  let startTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: futureDate) else {
                return nil
            }
            
            let isAllDay = i < 2 && Bool.random() // Some all-day events
            let endTime = isAllDay ? startTime : calendar.date(byAdding: .hour, value: Int.random(in: 1...3), to: startTime) ?? startTime
            
            return CalendarEvent(
                id: UUID().uuidString,
                title: eventTitles.randomElement() ?? "Event",
                startTime: startTime,
                endTime: endTime,
                isAllDay: isAllDay,
                color: colors.randomElement() ?? .blue,
                location: Bool.random() ? ["Conference Room B", "Teams Call", "Client Office", "Home"].randomElement() : nil,
                notes: nil,
                calendar: "Mock Calendar"
            )
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // MARK: - Calendar Management
    
    func requestCalendarAccess() async {
        let granted = await calendarService.requestAccess()
        authorizationStatus = granted ? .authorized : .denied
        useMockData = !authorizationStatus.canReadEvents
        
        if authorizationStatus.canReadEvents {
            let calendars = await calendarService.getAvailableCalendars()
            await MainActor.run {
                availableCalendars = calendars.map { $0.title }
            }
            try? await refresh()
        }
    }
}

// MARK: - Configuration View

struct CalendarConfigurationView: View {
    @StateObject private var calendarService = CalendarService()
    @State private var authorizationStatus: CalendarAuthorizationStatus = .notDetermined
    @State private var availableCalendars: [EKCalendar] = []
    @State private var selectedCalendarIDs: Set<String> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    
                    Text("Calendar Widget Configuration")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Configure your calendar widget to display the events that matter most to you.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Permission Status
                VStack(alignment: .leading, spacing: 12) {
                    Text("Calendar Access")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: authorizationStatus.canReadEvents ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(authorizationStatus.canReadEvents ? .green : .orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authorizationStatus.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if !authorizationStatus.canReadEvents {
                                Text("Calendar access required to show real events")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if !authorizationStatus.canReadEvents {
                            Button("Grant Access") {
                                Task {
                                    await requestAccess()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                
                // Available Calendars
                if authorizationStatus.canReadEvents && !availableCalendars.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Calendars")
                            .font(.headline)
                        
                        Text("Choose which calendars to display in the widget")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            ForEach(availableCalendars, id: \.calendarIdentifier) { calendar in
                                HStack {
                                    Button {
                                        toggleCalendar(calendar)
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedCalendarIDs.contains(calendar.calendarIdentifier) ? "checkmark.square.fill" : "square")
                                                .foregroundColor(selectedCalendarIDs.contains(calendar.calendarIdentifier) ? .accentColor : .secondary)
                                            
                                            Circle()
                                                .fill(Color(calendar.cgColor ?? CGColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)))
                                                .frame(width: 12, height: 12)
                                            
                                            Text(calendar.title)
                                                .font(.subheadline)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                // Widget Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Widget Features")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        FeatureRow(icon: "calendar.day.timeline.leading", title: "Today's Events", description: "Shows events scheduled for today")
                        FeatureRow(icon: "calendar.badge.clock", title: "Upcoming Events", description: "Displays events for the next 7 days")
                        FeatureRow(icon: "location", title: "Event Locations", description: "Shows event locations when available")
                        FeatureRow(icon: "paintbrush", title: "Calendar Colors", description: "Uses your calendar's color scheme")
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                
                Spacer()
            }
        }
        .padding()
        .onAppear {
            Task {
                await loadCalendarData()
            }
        }
    }
    
    private func requestAccess() async {
        let granted = await calendarService.requestAccess()
        await MainActor.run {
            authorizationStatus = granted ? .authorized : .denied
        }
        
        if granted {
            await loadAvailableCalendars()
        }
    }
    
    private func loadCalendarData() async {
        authorizationStatus = await calendarService.checkAuthorizationStatus()
        
        if authorizationStatus.canReadEvents {
            await loadAvailableCalendars()
        }
    }
    
    private func loadAvailableCalendars() async {
        let calendars = await calendarService.getAvailableCalendars()
        await MainActor.run {
            availableCalendars = calendars
            // Select all calendars by default
            selectedCalendarIDs = Set(calendars.map { $0.calendarIdentifier })
        }
    }
    
    private func toggleCalendar(_ calendar: EKCalendar) {
        if selectedCalendarIDs.contains(calendar.calendarIdentifier) {
            selectedCalendarIDs.remove(calendar.calendarIdentifier)
        } else {
            selectedCalendarIDs.insert(calendar.calendarIdentifier)
        }
        
        // Save preferences (implement later)
        // UserDefaults.standard.set(Array(selectedCalendarIDs), forKey: "SelectedCalendarIDs")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}