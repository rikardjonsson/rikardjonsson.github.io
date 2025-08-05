//
//  FitnessWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Fitness widget showing health metrics and workout data
/// Demonstrates comprehensive health tracking with mock HealthKit integration
@MainActor
final class FitnessWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    @Published private var content: FitnessContent
    
    // MARK: - Widget Metadata
    
    let title = "Fitness"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = FitnessContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(FitnessConfigurationView())
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
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Fitness")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                activeIndicator(theme: theme)
            }
            
            VStack(spacing: 6) {
                activityRing("Steps", current: content.todayStats.steps, goal: content.goals.steps, 
                           color: .blue, theme: theme)
                activityRing("Calories", current: content.todayStats.calories, goal: content.goals.calories, 
                           color: .red, theme: theme)
                activityRing("Exercise", current: content.todayStats.exerciseMinutes, goal: content.goals.exerciseMinutes, 
                           color: .green, theme: theme)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Text("Health & Fitness")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    activeIndicator(theme: theme)
                    Text("Active Day")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            // Activity rings with details
            VStack(spacing: 10) {
                activityRingDetailed("Steps", current: content.todayStats.steps, goal: content.goals.steps, 
                                   unit: "steps", color: .blue, theme: theme)
                activityRingDetailed("Active Calories", current: content.todayStats.calories, goal: content.goals.calories, 
                                   unit: "cal", color: .red, theme: theme)
                activityRingDetailed("Exercise", current: content.todayStats.exerciseMinutes, goal: content.goals.exerciseMinutes, 
                                   unit: "min", color: .green, theme: theme)
                
                if content.todayStats.workouts > 0 {
                    workoutSummary(theme: theme)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        HStack(spacing: 20) {
            // Left side - Today's activities
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                    
                    activeIndicator(theme: theme)
                }
                
                VStack(spacing: 12) {
                    activityRingDetailed("Steps", current: content.todayStats.steps, goal: content.goals.steps, 
                                       unit: "steps", color: .blue, theme: theme)
                    activityRingDetailed("Calories", current: content.todayStats.calories, goal: content.goals.calories, 
                                       unit: "cal", color: .red, theme: theme)
                    activityRingDetailed("Exercise", current: content.todayStats.exerciseMinutes, goal: content.goals.exerciseMinutes, 
                                       unit: "min", color: .green, theme: theme)
                    activityRingDetailed("Distance", current: Int(content.todayStats.distance), goal: Int(content.goals.distance), 
                                       unit: "km", color: .purple, theme: theme)
                }
                
                if content.todayStats.workouts > 0 {
                    workoutSummary(theme: theme)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 160)
            
            // Right side - Health metrics & trends
            VStack(alignment: .leading, spacing: 12) {
                Text("Health")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                
                VStack(spacing: 10) {
                    healthMetric("Heart Rate", value: "\(content.healthMetrics.restingHeartRate) bpm", 
                               status: "Resting", color: .red, theme: theme)
                    healthMetric("Sleep", value: String(format: "%.1fh", content.healthMetrics.sleepHours), 
                               status: "Last Night", color: .indigo, theme: theme)
                    healthMetric("Weight", value: String(format: "%.1f kg", content.healthMetrics.weight), 
                               status: "Latest", color: .orange, theme: theme)
                    healthMetric("Hydration", value: String(format: "%.1fL", content.healthMetrics.waterIntake), 
                               status: "Today", color: .cyan, theme: theme)
                }
                
                Divider()
                
                VStack(spacing: 6) {
                    Text("Weekly Trend")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textPrimary)
                    
                    weeklyTrend(theme: theme)
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
    
    private func activityRing(_ title: String, current: Int, goal: Int, color: Color, theme: any Theme) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
                .frame(width: 60, alignment: .leading)
            
            ProgressView(value: min(Double(current) / Double(goal), 1.0))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 0.7)
            
            Text("\(current)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
                .frame(minWidth: 35, alignment: .trailing)
        }
    }
    
    private func activityRingDetailed(_ title: String, current: Int, goal: Int, unit: String, color: Color, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text("\(current) / \(goal) \(unit)")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            
            HStack {
                ProgressView(value: min(Double(current) / Double(goal), 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 0.8)
                
                Text("\(Int((Double(current) / Double(goal)) * 100))%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .frame(minWidth: 35)
            }
        }
    }
    
    private func healthMetric(_ title: String, value: String, status: String, color: Color, theme: any Theme) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                Text(status)
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary.opacity(0.7))
            }
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
        }
    }
    
    private func workoutSummary(theme: any Theme) -> some View {
        HStack {
            Image(systemName: "figure.run")
                .font(.caption)
                .foregroundColor(.green)
            
            Text("\(content.todayStats.workouts) workout\(content.todayStats.workouts == 1 ? "" : "s") today")
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
    
    private func weeklyTrend(theme: any Theme) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { day in
                let progress = content.weeklyProgress[day]
                Rectangle()
                    .fill(progress > 0.7 ? Color.green : (progress > 0.4 ? Color.orange : Color.gray))
                    .frame(height: CGFloat(progress * 20 + 4))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 24)
    }
    
    private func activeIndicator(theme: any Theme) -> some View {
        let isActive = content.todayStats.steps > content.goals.steps / 2
        return Circle()
            .fill(isActive ? Color.green : Color.gray)
            .frame(width: 8, height: 8)
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Fitness Data Models

struct DailyStats {
    let steps: Int
    let calories: Int
    let exerciseMinutes: Int
    let distance: Double // in km
    let workouts: Int
    let activeHours: Int
}

struct FitnessGoals {
    let steps: Int
    let calories: Int
    let exerciseMinutes: Int
    let distance: Double
    let activeHours: Int
}

struct HealthMetrics {
    let restingHeartRate: Int
    let sleepHours: Double
    let weight: Double
    let waterIntake: Double
    let vo2Max: Double
}

struct WorkoutSummary {
    let type: String
    let duration: Int // minutes
    let calories: Int
    let timestamp: Date
}

// MARK: - Fitness Content

@MainActor
final class FitnessContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var todayStats = DailyStats(steps: 0, calories: 0, exerciseMinutes: 0, distance: 0, workouts: 0, activeHours: 0)
    @Published var goals = FitnessGoals(steps: 10000, calories: 2000, exerciseMinutes: 30, distance: 5.0, activeHours: 8)
    @Published var healthMetrics = HealthMetrics(restingHeartRate: 65, sleepHours: 7.5, weight: 70.0, waterIntake: 2.1, vo2Max: 45.0)
    @Published var recentWorkouts: [WorkoutSummary] = []
    @Published var weeklyProgress: [Double] = []
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_400_000_000)
            generateMockData()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockData() {
        // Generate today's stats with some realistic variation
        let currentHour = Calendar.current.component(.hour, from: Date())
        let dayProgress = Double(currentHour) / 24.0 // How much of the day has passed
        
        let baseSteps = Int(Double(goals.steps) * dayProgress * Double.random(in: 0.8...1.2))
        let baseCalories = Int(Double(goals.calories) * dayProgress * Double.random(in: 0.7...1.1))
        let baseExercise = Int(Double(goals.exerciseMinutes) * dayProgress * Double.random(in: 0.5...1.3))
        let baseDistance = goals.distance * dayProgress * Double.random(in: 0.6...1.4)
        
        todayStats = DailyStats(
            steps: max(baseSteps, 500),
            calories: max(baseCalories, 200),
            exerciseMinutes: max(baseExercise, 0),
            distance: max(baseDistance, 0.5),
            workouts: currentHour > 6 ? Int.random(in: 0...2) : 0,
            activeHours: min(currentHour / 2, 8)
        )
        
        // Generate health metrics with some variation
        healthMetrics = HealthMetrics(
            restingHeartRate: Int.random(in: 55...75),
            sleepHours: Double.random(in: 6.0...9.0),
            weight: Double.random(in: 65.0...85.0),
            waterIntake: Double.random(in: 1.5...3.0),
            vo2Max: Double.random(in: 35.0...55.0)
        )
        
        // Generate recent workouts
        let workoutTypes = ["Running", "Cycling", "Swimming", "Strength", "Yoga", "Walking", "HIIT"]
        let calendar = Calendar.current
        let now = Date()
        
        recentWorkouts = (0..<todayStats.workouts).compactMap { i in
            guard let workoutTime = calendar.date(byAdding: .hour, value: -(i + 1) * 3, to: now) else { return nil }
            
            return WorkoutSummary(
                type: workoutTypes.randomElement() ?? "Exercise",
                duration: Int.random(in: 20...90),
                calories: Int.random(in: 150...600),
                timestamp: workoutTime
            )
        }
        
        // Generate weekly progress (7 days)
        weeklyProgress = (0..<7).map { _ in
            Double.random(in: 0.2...1.0)
        }
        
        // Adjust goals occasionally for variety
        if Bool.random() && Double.random(in: 0...1) < 0.3 {
            goals = FitnessGoals(
                steps: Int.random(in: 8000...12000),
                calories: Int.random(in: 1800...2200),
                exerciseMinutes: Int.random(in: 30...60),
                distance: Double.random(in: 3.0...8.0),
                activeHours: Int.random(in: 6...10)
            )
        }
    }
}

// MARK: - Configuration View

struct FitnessConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Fitness Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows health and fitness metrics including steps, calories, exercise, heart rate, and sleep data. In a real implementation, this would integrate with HealthKit and fitness apps.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}