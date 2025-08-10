//
//  CalendarService.swift
//  Pylon
//
//  Created on 10.08.25.
//  Copyright © 2025. All rights reserved.
//

import EventKit
import Foundation
import SwiftUI

/// Service for accessing calendar events via EventKit
/// Handles permissions, fetching, and data conversion
actor CalendarService {
    private let eventStore = EKEventStore()
    private var isAuthorized = false
    
    // MARK: - Authorization
    
    /// Request calendar access permissions
    func requestAccess() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                isAuthorized = granted
                return granted
            } catch {
                DebugLog.error("Failed to request calendar access: \(error)")
                return false
            }
            
        case .authorized, .fullAccess:
            isAuthorized = true
            return true
            
        case .denied, .restricted:
            isAuthorized = false
            return false
            
        case .writeOnly:
            // Write-only access is not sufficient for reading events
            isAuthorized = false
            return false
            
        @unknown default:
            isAuthorized = false
            return false
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() -> CalendarAuthorizationStatus {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized, .fullAccess:
            return .authorized
        case .writeOnly:
            return .writeOnly
        @unknown default:
            return .unknown
        }
    }
    
    // MARK: - Event Fetching
    
    /// Fetch calendar events for a given date range
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEvent] {
        guard isAuthorized else {
            throw CalendarError.notAuthorized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                do {
                    let predicate = self.eventStore.predicateForEvents(
                        withStart: startDate,
                        end: endDate,
                        calendars: nil
                    )
                    
                    let events = self.eventStore.events(matching: predicate)
                    let calendarEvents = events.compactMap { ekEvent in
                        self.convertEKEventToCalendarEvent(ekEvent)
                    }
                    
                    continuation.resume(returning: calendarEvents)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Fetch today's events
    func fetchTodayEvents() async throws -> [CalendarEvent] {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        
        return try await fetchEvents(from: startOfDay, to: endOfDay)
    }
    
    /// Fetch upcoming events for the next week
    func fetchUpcomingEvents() async throws -> [CalendarEvent] {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        
        return try await fetchEvents(from: tomorrow, to: nextWeek)
    }
    
    /// Fetch events for a specific date
    func fetchEvents(for date: Date) async throws -> [CalendarEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return try await fetchEvents(from: startOfDay, to: endOfDay)
    }
    
    // MARK: - Calendar Access
    
    /// Get available calendars
    func getAvailableCalendars() async -> [EKCalendar] {
        guard isAuthorized else {
            return []
        }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let calendars = self.eventStore.calendars(for: .event)
                continuation.resume(returning: calendars)
            }
        }
    }
    
    /// Get events from specific calendars only
    func fetchEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]) async throws -> [CalendarEvent] {
        guard isAuthorized else {
            throw CalendarError.notAuthorized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                do {
                    let predicate = self.eventStore.predicateForEvents(
                        withStart: startDate,
                        end: endDate,
                        calendars: calendars
                    )
                    
                    let events = self.eventStore.events(matching: predicate)
                    let calendarEvents = events.compactMap { ekEvent in
                        self.convertEKEventToCalendarEvent(ekEvent)
                    }
                    
                    continuation.resume(returning: calendarEvents)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Data Conversion
    
    /// Convert EKEvent to CalendarEvent
    private func convertEKEventToCalendarEvent(_ ekEvent: EKEvent) -> CalendarEvent? {
        // Determine event color based on calendar color
        let eventColor = Color(ekEvent.calendar.cgColor ?? CGColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0))
        
        return CalendarEvent(
            id: ekEvent.eventIdentifier ?? UUID().uuidString,
            title: ekEvent.title ?? "Untitled Event",
            startTime: ekEvent.startDate,
            endTime: ekEvent.endDate,
            isAllDay: ekEvent.isAllDay,
            color: eventColor,
            location: ekEvent.location,
            notes: ekEvent.notes,
            calendar: ekEvent.calendar.title,
            url: ekEvent.url
        )
    }
}

// MARK: - Supporting Types

enum CalendarAuthorizationStatus {
    case notDetermined
    case denied
    case restricted
    case authorized
    case writeOnly
    case unknown
    
    var displayName: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorized:
            return "Authorized"
        case .writeOnly:
            return "Write Only"
        case .unknown:
            return "Unknown"
        }
    }
    
    var canReadEvents: Bool {
        self == .authorized
    }
}

enum CalendarError: LocalizedError, Sendable {
    case notAuthorized
    case accessDenied
    case eventNotFound
    case invalidDateRange
    case eventStoreUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Calendar access not authorized. Please grant permission in System Preferences."
        case .accessDenied:
            return "Calendar access has been denied."
        case .eventNotFound:
            return "The requested event could not be found."
        case .invalidDateRange:
            return "Invalid date range specified."
        case .eventStoreUnavailable:
            return "Calendar service is currently unavailable."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notAuthorized, .accessDenied:
            return "Go to System Preferences > Security & Privacy > Privacy > Calendars to grant access."
        default:
            return "Please try again later."
        }
    }
}

// MARK: - Enhanced CalendarEvent Model

struct CalendarEvent: Identifiable, Sendable {
    let id: String
    let title: String
    let startTime: Date
    let endTime: Date
    let isAllDay: Bool
    let color: Color
    let location: String?
    let notes: String?
    let calendar: String
    let url: URL?
    
    // Convenience initializer for backward compatibility
    init(
        title: String,
        startTime: Date,
        isAllDay: Bool,
        color: Color
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.startTime = startTime
        self.endTime = Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
        self.isAllDay = isAllDay
        self.color = color
        self.location = nil
        self.notes = nil
        self.calendar = "Default"
        self.url = nil
    }
    
    // Full initializer
    init(
        id: String,
        title: String,
        startTime: Date,
        endTime: Date,
        isAllDay: Bool,
        color: Color,
        location: String? = nil,
        notes: String? = nil,
        calendar: String,
        url: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.isAllDay = isAllDay
        self.color = color
        self.location = location
        self.notes = notes
        self.calendar = calendar
        self.url = url
    }
    
    // Computed properties
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startTime)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(startTime)
    }
    
    var isThisWeek: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.isDate(startTime, equalTo: now, toGranularity: .weekOfYear)
    }
    
    var displayTime: String {
        if isAllDay {
            return "All day"
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if Calendar.current.isDate(startTime, inSameDayAs: endTime) {
            return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
        } else {
            formatter.dateStyle = .short
            return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
        }
    }
    
    var displayDate: String {
        let formatter = DateFormatter()
        
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isThisWeek {
            formatter.dateFormat = "EEEE" // Day of week
            return formatter.string(from: startTime)
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: startTime)
        }
    }
}

// MARK: - Calendar Filtering Options

struct CalendarFilter {
    var enabledCalendarIDs: Set<String>
    var showAllDayEvents: Bool
    var showPastEvents: Bool
    var maxEventsPerDay: Int
    
    static let `default` = CalendarFilter(
        enabledCalendarIDs: [],
        showAllDayEvents: true,
        showPastEvents: false,
        maxEventsPerDay: 10
    )
}