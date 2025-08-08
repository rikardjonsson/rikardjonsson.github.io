//
//  ActivityWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class ActivityWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: ActivityContent
    
    let title = "Activity"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = ActivityContent()
    }
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(EmptyView())
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    VStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                        Text("\(content.steps)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                        Text("steps")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                    }
                case .medium:
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .font(.title2)
                                .foregroundColor(theme.accentColor)
                            Text("Activity")
                                .font(.headline)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        
                        VStack(spacing: 6) {
                            activityRow("Steps", value: "\(content.steps)", progress: content.stepsProgress, theme: theme)
                            activityRow("Calories", value: "\(content.calories)", progress: content.caloriesProgress, theme: theme)
                            activityRow("Exercise", value: "\(content.exerciseMinutes) min", progress: content.exerciseProgress, theme: theme)
                        }
                        Spacer()
                    }
                case .large:
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .font(.title)
                                .foregroundColor(theme.accentColor)
                            Text("Daily Activity")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        
                        VStack(spacing: 10) {
                            activityRowDetailed("Steps", value: "\(content.steps)", goal: "10,000", progress: content.stepsProgress, color: .blue, theme: theme)
                            activityRowDetailed("Calories", value: "\(content.calories)", goal: "2,000", progress: content.caloriesProgress, color: .red, theme: theme)
                            activityRowDetailed("Exercise", value: "\(content.exerciseMinutes) min", goal: "30 min", progress: content.exerciseProgress, color: .green, theme: theme)
                        }
                        Spacer()
                    }
                case .xlarge:
                    VStack(spacing: 16) {
                        // Header with larger title and date
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "figure.walk")
                                        .font(.largeTitle)
                                        .foregroundColor(theme.accentColor)
                                    Text("Activity Dashboard")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(theme.textPrimary)
                                }
                                Text("Today • \(formatDate(Date()))")
                                    .font(.subheadline)
                                    .foregroundColor(theme.textSecondary)
                            }
                            Spacer()
                        }
                        
                        // Main activity metrics with large progress circles
                        HStack(spacing: 20) {
                            activityCircle("Steps", value: "\(content.steps)", goal: "10,000", progress: content.stepsProgress, color: .blue, theme: theme)
                            activityCircle("Calories", value: "\(content.calories)", goal: "2,000", progress: content.caloriesProgress, color: .red, theme: theme)
                            activityCircle("Exercise", value: "\(content.exerciseMinutes)", goal: "30", progress: content.exerciseProgress, color: .green, theme: theme)
                        }
                        
                        Spacer()
                        
                        // Bottom stats row with additional metrics
                        HStack(spacing: 30) {
                            statBox("Average", value: "\(Int(Double(content.steps) * 0.7))", unit: "steps/day", theme: theme)
                            statBox("Streak", value: "12", unit: "days", theme: theme)
                            statBox("This Week", value: "\(content.exerciseMinutes * 7)", unit: "minutes", theme: theme)
                        }
                        
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private func activityRow(_ label: String, value: String, progress: Double, theme: any Theme) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                .frame(width: 30)
                .scaleEffect(y: 0.7)
        }
    }
    
    private func activityRowDetailed(_ label: String, value: String, goal: String, progress: Double, color: Color, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(theme.textPrimary)
                Spacer()
                Text("\(value) / \(goal)")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 0.8)
        }
    }
    
    private func activityCircle(_ label: String, value: String, goal: String, progress: Double, color: Color, theme: any Theme) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
    }
    
    private func statBox(_ label: String, value: String, unit: String, theme: any Theme) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            Text(unit)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            Text(label)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

@MainActor
final class ActivityContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var steps: Int = 0
    @Published var calories: Int = 0
    @Published var exerciseMinutes: Int = 0
    @Published var stepsProgress: Double = 0.0
    @Published var caloriesProgress: Double = 0.0
    @Published var exerciseProgress: Double = 0.0
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    func refresh() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 1_000_000_000)
        generateMockData()  
        lastUpdated = Date()
        isLoading = false
    }
    
    private func generateMockData() {
        steps = Int.random(in: 3000...12000)
        calories = Int.random(in: 800...2500)
        exerciseMinutes = Int.random(in: 0...60)
        
        stepsProgress = min(Double(steps) / 10000.0, 1.0)
        caloriesProgress = min(Double(calories) / 2000.0, 1.0)
        exerciseProgress = min(Double(exerciseMinutes) / 30.0, 1.0)
    }
}