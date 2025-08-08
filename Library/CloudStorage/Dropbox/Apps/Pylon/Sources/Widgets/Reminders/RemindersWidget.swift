//
//  RemindersWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Reminders widget showing task list with priorities
/// Demonstrates todo management with mock data
@MainActor
final class RemindersWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: RemindersContent
    
    // MARK: - Widget Metadata
    
    let title = "Reminders"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = RemindersContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(RemindersConfigurationView())
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
            Image(systemName: "checklist")
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text("\(content.pendingTasks.count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            
            Text("tasks")
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checklist")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Tasks")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text("\(content.pendingTasks.count)")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            
            VStack(spacing: 4) {
                ForEach(Array(content.pendingTasks.prefix(4)), id: \.id) { task in
                    self.taskRow(task, theme: theme, compact: true)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Reminders")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                priorityBadge(content.highPriorityCount, color: .red, theme: theme)
            }
            
            VStack(spacing: 6) {
                ForEach(Array(content.pendingTasks.prefix(7)), id: \.id) { task in
                    self.taskRow(task, theme: theme, compact: false)
                }
            }
            
            if content.completedTasks.count > 0 {
                Divider()
                
                Text("\(content.completedTasks.count) completed today")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "checklist")
                    .font(.largeTitle)
                    .foregroundColor(theme.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reminders")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                    
                    Text("Task Management Dashboard")
                        .font(.headline)
                        .foregroundColor(theme.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    priorityBadgeEnhanced(content.highPriorityCount, label: "High Priority", color: .red, theme: theme)
                    priorityBadgeEnhanced(content.pendingTasks.count, label: "Pending", color: .orange, theme: theme)
                    priorityBadgeEnhanced(content.completedTasks.count, label: "Completed", color: .green, theme: theme)
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pending Tasks")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(content.pendingTasks.prefix(8), id: \.id) { task in
                                self.taskRow(task, theme: theme, compact: false)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Completed Today")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(content.completedTasks.prefix(5), id: \.id) { task in
                                self.taskRow(task, theme: theme, compact: false, showCompleted: true)
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Views
    
    private func taskRow(_ task: ReminderTask, theme: any Theme, compact: Bool, showCompleted: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: showCompleted ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundColor(showCompleted ? .green : priorityColor(task.priority))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showCompleted ? theme.textSecondary : theme.textPrimary)
                    .strikethrough(showCompleted)
                    .lineLimit(1)
                
                if !compact && task.dueDate != nil {
                    Text(formatDueDate(task.dueDate!))
                        .font(.caption2)
                        .foregroundColor(isDueSoon(task.dueDate!) ? .orange : theme.textSecondary)
                }
            }
            
            Spacer()
            
            if !showCompleted && !compact {
                priorityIndicator(task.priority)
            }
        }
    }
    
    @ViewBuilder
    private func priorityBadge(_ count: Int, color: Color, theme: any Theme) -> some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color, in: Capsule())
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func priorityIndicator(_ priority: TaskPriority) -> some View {
        switch priority {
        case .high:
            Image(systemName: "exclamationmark")
                .font(.caption2)
                .foregroundColor(.red)
        case .medium:
            Image(systemName: "minus")
                .font(.caption2)
                .foregroundColor(.orange)
        case .low:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func priorityBadgeEnhanced(_ count: Int, label: String, color: Color, theme: any Theme) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
                .lineLimit(1)
        }
        .padding(8)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Helper Methods
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .gray
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func isDueSoon(_ date: Date) -> Bool {
        let timeInterval = date.timeIntervalSinceNow
        return timeInterval > 0 && timeInterval < 24 * 60 * 60 // Due within 24 hours
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Reminder Data Models

enum TaskPriority: CaseIterable {
    case high, medium, low
}

struct ReminderTask: Identifiable {
    let id = UUID()
    let title: String
    let priority: TaskPriority
    let dueDate: Date?
    let isCompleted: Bool
}

// MARK: - Reminders Content

@MainActor
final class RemindersContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var pendingTasks: [ReminderTask] = []
    @Published var completedTasks: [ReminderTask] = []
    
    var highPriorityCount: Int {
        pendingTasks.filter { $0.priority == .high }.count
    }
    
    init() {
        generateMockTasks()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_200_000_000)
            generateMockTasks()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockTasks() {
        let taskTitles = [
            "Review quarterly report", "Call insurance company", "Buy birthday gift",
            "Schedule dentist appointment", "Update LinkedIn profile", "Clean garage",
            "Prepare presentation", "Book vacation flights", "Water plants",
            "Submit expense report", "Read book chapter", "Exercise routine",
            "Grocery shopping", "Pay credit card bill", "Backup computer files"
        ]
        
        let calendar = Calendar.current
        let now = Date()
        
        // Generate pending tasks
        pendingTasks = (0..<Int.random(in: 5...8)).compactMap { _ in
            guard let title = taskTitles.randomElement() else { return nil }
            
            let priority = TaskPriority.allCases.randomElement() ?? .low
            let hasDueDate = Bool.random()
            let dueDate = hasDueDate ? calendar.date(byAdding: .day, value: Int.random(in: -1...7), to: now) : nil
            
            return ReminderTask(
                title: title,
                priority: priority,
                dueDate: dueDate,
                isCompleted: false
            )
        }.sorted { task1, task2 in
            if task1.priority != task2.priority {
                return task1.priority == .high || (task1.priority == .medium && task2.priority == .low)
            }
            return (task1.dueDate ?? .distantFuture) < (task2.dueDate ?? .distantFuture)
        }
        
        // Generate completed tasks
        completedTasks = (0..<Int.random(in: 3...6)).compactMap { _ in
            guard let title = taskTitles.randomElement() else { return nil }
            
            return ReminderTask(
                title: title,
                priority: TaskPriority.allCases.randomElement() ?? .low,
                dueDate: nil,
                isCompleted: true
            )
        }
    }
}

// MARK: - Configuration View

struct RemindersConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Reminders Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows pending and completed tasks with priority indicators. In a real implementation, this would integrate with the Reminders app or a task management system.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}