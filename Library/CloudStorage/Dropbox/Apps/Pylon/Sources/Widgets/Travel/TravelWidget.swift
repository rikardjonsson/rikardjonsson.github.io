//
//  TravelWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Travel widget showing flights, trips, and travel information
/// Demonstrates comprehensive travel management with mock booking data
@MainActor
final class TravelWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    @Published private var content: TravelContent
    
    // MARK: - Widget Metadata
    
    let title = "Travel"
    let category = WidgetCategory.information
    let supportedSizes: [WidgetSize] = [.medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = TravelContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(TravelConfigurationView())
    }
    
    // MARK: - Main Widget View
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    mediumLayout(theme: theme) // Use medium for small
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
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "airplane")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Travel")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                if let nextTrip = content.upcomingTrips.first {
                    tripStatusIndicator(nextTrip, theme: theme)
                }
            }
            
            if let nextTrip = content.upcomingTrips.first {
                nextTripCompact(nextTrip, theme: theme)
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "suitcase")
                        .font(.title3)
                        .foregroundColor(theme.textSecondary.opacity(0.6))
                    
                    Text("No upcoming trips")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "airplane")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Travel")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    if let nextTrip = content.upcomingTrips.first {
                        tripStatusIndicator(nextTrip, theme: theme)
                    }
                    
                    if content.upcomingTrips.count > 0 {
                        Text("\(content.upcomingTrips.count) trips")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            
            if let nextTrip = content.upcomingTrips.first {
                nextTripDetailed(nextTrip, theme: theme)
                
                if content.upcomingTrips.count > 1 {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Other Trips")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(theme.textPrimary)
                        
                        ForEach(Array(content.upcomingTrips.dropFirst().prefix(2)), id: \.id) { trip in
                            self.tripRow(trip, theme: theme, compact: true)
                        }
                    }
                }
            } else {
                emptyState(theme: theme)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        HStack(spacing: 20) {
            // Left side - Upcoming trips
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Upcoming")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                    
                    if let nextTrip = content.upcomingTrips.first {
                        tripStatusIndicator(nextTrip, theme: theme)
                    }
                }
                
                if !content.upcomingTrips.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(content.upcomingTrips, id: \.id) { trip in
                            self.tripRowDetailed(trip, theme: theme)
                        }
                    }
                } else {
                    emptyState(theme: theme)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 140)
            
            // Right side - Recent trips & stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Travel Stats")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                
                VStack(spacing: 10) {
                    travelStat("Miles This Year", value: "\(content.stats.milesThisYear)K", 
                             icon: "airplane", color: .blue, theme: theme)
                    travelStat("Countries Visited", value: "\(content.stats.countriesVisited)", 
                             icon: "globe", color: .green, theme: theme)
                    travelStat("Trips Completed", value: "\(content.stats.tripsCompleted)", 
                             icon: "checkmark.circle", color: .orange, theme: theme)
                }
                
                if !content.recentTrips.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(theme.textPrimary)
                        
                        ForEach(Array(content.recentTrips.prefix(3)), id: \.id) { trip in
                            self.recentTripRow(trip, theme: theme)
                        }
                    }
                }
                
                Spacer()
                
                if let lastUpdated = content.lastUpdated {
                    Text("Updated: \(formatTime(lastUpdated))")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            .frame(width: 180)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Views
    
    private func nextTripCompact(_ trip: Trip, theme: any Theme) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(trip.destination)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text(formatTripDate(trip.departureDate))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            
            if let flight = trip.flights.first {
                HStack {
                    Text("\(flight.airline) \(flight.flightNumber)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    Text("\(flight.departureAirport) → \(flight.arrivalAirport)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(theme.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private func nextTripDetailed(_ trip: Trip, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(trip.destination)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTripDate(trip.departureDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textPrimary)
                    
                    Text(daysUntilTrip(trip.departureDate))
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            if let flight = trip.flights.first {
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: "airplane.departure")
                            .font(.caption)
                            .foregroundColor(theme.accentColor)
                        
                        Text("\(flight.airline) \(flight.flightNumber)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(theme.textPrimary)
                        
                        Spacer()
                        
                        Text(formatFlightTime(flight.departureTime))
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                    
                    HStack {
                        Text("\(flight.departureAirport)")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary.opacity(0.6))
                        
                        Text("\(flight.arrivalAirport)")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                        
                        Spacer()
                        
                        Text("Gate \(flight.gate ?? "TBD")")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary.opacity(0.7))
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(theme.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func tripRow(_ trip: Trip, theme: any Theme, compact: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(trip.destination)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                if !compact && !trip.purpose.isEmpty {
                    Text(trip.purpose)
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTripDate(trip.departureDate))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                if !compact {
                    Text(daysUntilTrip(trip.departureDate))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary.opacity(0.7))
                }
            }
        }
    }
    
    private func tripRowDetailed(_ trip: Trip, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(trip.destination)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text(formatTripDate(trip.departureDate))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            
            HStack {
                if !trip.purpose.isEmpty {
                    Text(trip.purpose)
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
                
                Spacer()
                
                Text(daysUntilTrip(trip.departureDate))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.accentColor)
            }
            
            if let flight = trip.flights.first {
                HStack {
                    Text("\(flight.airline) \(flight.flightNumber)")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(flight.departureAirport) → \(flight.arrivalAirport)")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func recentTripRow(_ trip: Trip, theme: any Theme) -> some View {
        HStack {
            Circle()
                .fill(destinationColor(trip.destination))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(trip.destination)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                Text(formatTripDate(trip.departureDate))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private func travelStat(_ title: String, value: String, icon: String, color: Color, theme: any Theme) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
            }
            
            Spacer()
        }
    }
    
    private func emptyState(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "suitcase")
                .font(.title2)
                .foregroundColor(theme.textSecondary.opacity(0.6))
            
            Text("No upcoming trips")
                .font(.subheadline)
                .foregroundColor(theme.textSecondary)
            
            Text("Your next adventure awaits!")
                .font(.caption)
                .foregroundColor(theme.textSecondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func tripStatusIndicator(_ trip: Trip, theme: any Theme) -> some View {
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: trip.departureDate).day ?? 0
        let color: Color = daysUntil <= 1 ? .red : (daysUntil <= 7 ? .orange : theme.accentColor)
        
        return Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
    
    // MARK: - Helper Methods
    
    private func destinationColor(_ destination: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .cyan]
        let index = abs(destination.hashValue) % colors.count
        return colors[index]
    }
    
    private func formatTripDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatFlightTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func daysUntilTrip(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        if days < 0 {
            return "Past"
        } else if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "in \(days) days"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Travel Data Models

struct Trip: Identifiable {
    let id = UUID()
    let destination: String
    let purpose: String
    let departureDate: Date
    let returnDate: Date
    let flights: [Flight]
    let hotels: [Hotel]
    let status: TripStatus
}

struct Flight: Identifiable {
    let id = UUID()
    let airline: String
    let flightNumber: String
    let departureAirport: String
    let arrivalAirport: String
    let departureTime: Date
    let arrivalTime: Date
    let gate: String?
    let seat: String?
}

struct Hotel: Identifiable {
    let id = UUID()
    let name: String
    let checkIn: Date
    let checkOut: Date
    let confirmationNumber: String
}

struct TravelStats {
    let milesThisYear: Int
    let countriesVisited: Int
    let tripsCompleted: Int
    let favoriteDestination: String
}

enum TripStatus: CaseIterable {
    case confirmed, checkedIn, delayed, cancelled
}

// MARK: - Travel Content

@MainActor
final class TravelContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var upcomingTrips: [Trip] = []
    @Published var recentTrips: [Trip] = []
    @Published var stats = TravelStats(milesThisYear: 0, countriesVisited: 0, tripsCompleted: 0, favoriteDestination: "")
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            generateMockData()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockData() {
        let destinations = [
            "Tokyo, Japan", "Paris, France", "New York, USA", "London, UK",
            "Sydney, Australia", "Barcelona, Spain", "Amsterdam, Netherlands",
            "Singapore", "Dubai, UAE", "San Francisco, USA", "Berlin, Germany",
            "Copenhagen, Denmark", "Stockholm, Sweden", "Vancouver, Canada"
        ]
        
        let purposes = ["Business", "Vacation", "Conference", "Family Visit", "Adventure", ""]
        let airlines = ["Delta", "United", "American", "Lufthansa", "British Airways", "Emirates", "KLM"]
        let airports = ["JFK", "LAX", "LHR", "CDG", "NRT", "SYD", "AMS", "DXB", "SFO", "BER"]
        
        let calendar = Calendar.current
        let now = Date()
        
        // Generate upcoming trips
        upcomingTrips = (0..<Int.random(in: 1...4)).compactMap { i in
            let daysAhead = i * Int.random(in: 7...30) + Int.random(in: 1...7)
            guard let departureDate = calendar.date(byAdding: .day, value: daysAhead, to: now) else { return nil }
            guard let returnDate = calendar.date(byAdding: .day, value: Int.random(in: 2...14), to: departureDate) else { return nil }
            
            let destination = destinations.randomElement() ?? "Unknown"
            let purpose = purposes.randomElement() ?? ""
            
            // Generate flight
            let airline = airlines.randomElement() ?? "Airline"
            let flightNumber = "\(Int.random(in: 100...9999))"
            let departureAirport = airports.randomElement() ?? "DEP"
            let arrivalAirport = airports.randomElement() ?? "ARR"
            
            let flight = Flight(
                airline: airline,
                flightNumber: flightNumber,
                departureAirport: departureAirport,
                arrivalAirport: arrivalAirport,
                departureTime: departureDate,
                arrivalTime: calendar.date(byAdding: .hour, value: Int.random(in: 2...12), to: departureDate) ?? departureDate,
                gate: Bool.random() ? "\(Int.random(in: 1...50))" : nil,
                seat: Bool.random() ? "\(Int.random(in: 1...30))\(["A","B","C","D","E","F"].randomElement() ?? "A")" : nil
            )
            
            return Trip(
                destination: destination,
                purpose: purpose,
                departureDate: departureDate,
                returnDate: returnDate,
                flights: [flight],
                hotels: [],
                status: TripStatus.allCases.randomElement() ?? .confirmed
            )
        }.sorted { $0.departureDate < $1.departureDate }
        
        // Generate recent trips
        recentTrips = (0..<Int.random(in: 3...6)).compactMap { i in
            let daysAgo = (i + 1) * Int.random(in: 14...60)
            guard let departureDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { return nil }
            guard let returnDate = calendar.date(byAdding: .day, value: Int.random(in: 2...10), to: departureDate) else { return nil }
            
            return Trip(
                destination: destinations.randomElement() ?? "Unknown",
                purpose: purposes.randomElement() ?? "",
                departureDate: departureDate,
                returnDate: returnDate,
                flights: [],
                hotels: [],
                status: .confirmed
            )
        }.sorted { $0.departureDate > $1.departureDate }
        
        // Generate stats
        stats = TravelStats(
            milesThisYear: Int.random(in: 25...150),
            countriesVisited: Int.random(in: 8...25),
            tripsCompleted: recentTrips.count + Int.random(in: 5...15),
            favoriteDestination: destinations.randomElement() ?? "Tokyo, Japan"
        )
    }
}

// MARK: - Configuration View

struct TravelConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Travel Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows upcoming trips, flights, and travel statistics with mock data. In a real implementation, this would integrate with travel booking APIs and calendar events.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}