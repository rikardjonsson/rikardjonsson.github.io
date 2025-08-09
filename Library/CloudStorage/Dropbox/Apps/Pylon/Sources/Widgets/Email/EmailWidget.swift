//
//  EmailWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Email widget showing inbox with unread count and recent messages
/// Demonstrates rich communication data with mock Mail app integration
@MainActor
final class EmailWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: EmailContent
    
    // MARK: - Widget Metadata
    
    let title = "Email"
    let category = WidgetCategory.productivity
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = EmailContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(EmailConfigurationView())
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
            Image(systemName: "envelope.fill")
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text("\(content.unreadCount)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            
            Text("unread")
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "envelope.fill")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Inbox")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                unreadBadge(count: content.unreadCount, theme: theme)
            }
            
            VStack(spacing: 4) {
                ForEach(Array(content.recentEmails.prefix(3)), id: \.id) { email in
                    self.emailRow(email, theme: theme, compact: true)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "envelope.fill")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Email")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    unreadBadge(count: content.unreadCount, theme: theme)
                    Text("\(content.totalEmails) total")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            VStack(spacing: 6) {
                ForEach(Array(content.recentEmails.prefix(6)), id: \.id) { email in
                    self.emailRow(email, theme: theme, compact: false)
                }
            }
            
            HStack {
                accountsIndicator(theme: theme)
                
                Spacer()
                
                if let lastUpdated = content.lastUpdated {
                    Text("Synced: \(formatTime(lastUpdated))")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            // Header with detailed stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.largeTitle)
                            .foregroundColor(theme.accentColor)
                        Text("Email Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                    }
                    Text("\(content.unreadCount) unread • \(content.totalEmails) total messages")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                Spacer()
            }
            
            HStack(spacing: 20) {
                // Inbox column
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Messages")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(content.recentEmails, id: \.id) { email in
                                self.emailCardDetailed(email, theme: theme)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .frame(maxWidth: .infinity)
                
                // Stats column
                VStack(alignment: .leading, spacing: 16) {
                    Text("Account Status")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    
                    VStack(spacing: 12) {
                        emailStatCard("Unread", count: content.unreadCount, color: .red, theme: theme)
                        emailStatCard("Today", count: content.todayCount, color: .blue, theme: theme)
                        emailStatCard("This Week", count: content.weekCount, color: .green, theme: theme)
                    }
                    
                    Spacer()
                }
                .frame(width: 160)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    // MARK: - Helper Views
    
    private func emailRow(_ email: EmailMessage, theme: any Theme, compact: Bool) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(email.isUnread ? theme.accentColor : Color.clear)
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(email.sender)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(email.isUnread ? .semibold : .medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                if !compact {
                    Text(email.subject)
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTime(email.receivedAt))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                
                if email.hasAttachment && !compact {
                    Image(systemName: "paperclip")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary.opacity(0.7))
                }
            }
        }
    }
    
    private func emailRowDetailed(_ email: EmailMessage, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(email.isUnread ? theme.accentColor : Color.clear)
                    .frame(width: 6, height: 6)
                
                Text(email.sender)
                    .font(.subheadline)
                    .fontWeight(email.isUnread ? .semibold : .medium)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    if email.hasAttachment {
                        Image(systemName: "paperclip")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary.opacity(0.7))
                    }
                    
                    Text(formatTime(email.receivedAt))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Text(email.subject)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
                .lineLimit(1)
            
            if !email.preview.isEmpty {
                Text(email.preview)
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary.opacity(0.8))
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func accountRow(_ account: EmailAccount, theme: any Theme) -> some View {
        HStack {
            Circle()
                .fill(self.accountColor(for: account.provider))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                Text(account.provider)
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
            
            if account.unreadCount > 0 {
                Text("\(account.unreadCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(theme.accentColor, in: Capsule())
            }
        }
    }
    
    @ViewBuilder
    private func unreadBadge(count: Int, theme: any Theme) -> some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(theme.accentColor, in: Capsule())
        } else {
            EmptyView()
        }
    }
    
    private func accountsIndicator(theme: any Theme) -> some View {
        HStack(spacing: -4) {
            ForEach(Array(content.accounts.prefix(3)), id: \.id) { account in
                Circle()
                    .fill(self.accountColor(for: account.provider))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(theme.backgroundMaterial, lineWidth: 1)
                    )
            }
            
            if content.accounts.count > 3 {
                Text("+\(content.accounts.count - 3)")
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func accountColor(for provider: String) -> Color {
        switch provider.lowercased() {
        case "gmail": return .red
        case "outlook": return .blue
        case "icloud": return .cyan
        case "yahoo": return .purple
        default: return .gray
        }
    }
    
    private func emailCardDetailed(_ email: EmailMessage, theme: any Theme) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(email.isUnread ? theme.accentColor : Color.clear)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(email.sender)
                        .font(.subheadline)
                        .fontWeight(email.isUnread ? .semibold : .medium)
                        .foregroundColor(theme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatTime(email.receivedAt))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
                
                Text(email.subject)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)
                
                if !email.preview.isEmpty {
                    Text(email.preview)
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary.opacity(0.8))
                        .lineLimit(2)
                }
            }
        }
        .padding(8)
        .background(email.isUnread ? theme.cardBackground.opacity(0.3) : Color.clear)
        .cornerRadius(6)
    }
    
    private func emailStatCard(_ label: String, count: Int, color: Color, theme: any Theme) -> some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Email Data Models

struct EmailMessage: Identifiable {
    let id = UUID()
    let sender: String
    let subject: String
    let preview: String
    let receivedAt: Date
    let isUnread: Bool
    let hasAttachment: Bool
    let priority: EmailPriority
}

struct EmailAccount: Identifiable {
    let id = UUID()
    let name: String
    let provider: String
    let unreadCount: Int
    let isEnabled: Bool
}

enum EmailPriority: CaseIterable {
    case high, normal, low
}

// MARK: - Email Content

@MainActor
final class EmailContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var recentEmails: [EmailMessage] = []
    @Published var accounts: [EmailAccount] = []
    @Published var unreadCount: Int = 0
    @Published var totalEmails: Int = 0
    
    var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return recentEmails.filter { Calendar.current.startOfDay(for: $0.receivedAt) >= today }.count
    }
    
    var weekCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return recentEmails.filter { $0.receivedAt >= weekAgo }.count
    }
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_800_000_000)
            generateMockData()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockData() {
        // Generate mock accounts
        let accountData = [
            ("Work", "Gmail", Int.random(in: 0...15)),
            ("Personal", "iCloud", Int.random(in: 0...8)),
            ("Newsletter", "Outlook", Int.random(in: 0...25)),
            ("Projects", "Yahoo", Int.random(in: 0...5))
        ]
        
        accounts = accountData.map { (name, provider, unread) in
            EmailAccount(
                name: name,
                provider: provider,
                unreadCount: unread,
                isEnabled: true
            )
        }
        
        // Generate mock emails
        let senders = [
            "Sarah Johnson", "Mike Chen", "LinkedIn", "GitHub",
            "Apple Developer", "Design Weekly", "Alex Rodriguez", "Team Lead",
            "Project Manager", "HR Department", "Newsletter", "Medium Daily",
            "Stack Overflow", "Dribbble", "Figma Updates", "Slack"
        ]
        
        let subjects = [
            "Weekly team sync - Action items",
            "Your design has been approved",
            "New connection request from John",
            "Security alert for your account",
            "Project deadline reminder",
            "Invoice #2024-0891 ready",
            "Welcome to our premium plan",
            "Your article was featured",
            "Meeting rescheduled to tomorrow",
            "Performance review feedback",
            "System maintenance notice",
            "Holiday schedule update",
            "New feature announcement",
            "Feedback on latest proposal",
            "Conference registration confirmed",
            "Monthly newsletter"
        ]
        
        let previews = [
            "Hi there! I wanted to follow up on our discussion about the quarterly planning session...",
            "Great work on the latest design iteration. The client feedback has been overwhelmingly positive...",
            "I'd like to add you to my professional network on LinkedIn. We met at the design conference...",
            "We detected unusual activity on your account. Please review these login attempts...",
            "Just a friendly reminder that the project deliverables are due this Friday at 5 PM...",
            "Your monthly subscription invoice is ready for download. Amount due: $29.99...",
            "Thank you for upgrading! You now have access to premium features including...",
            "Congratulations! Your article 'Design Systems at Scale' has been featured on our homepage...",
            "Due to a scheduling conflict, we need to move tomorrow's meeting to Thursday...",
            "Thank you for your hard work this quarter. Here's your performance summary...",
            "Scheduled maintenance will occur this weekend. Expected downtime: 2-4 hours...",
            "Please note the updated holiday schedule for the remainder of the year...",
            "We're excited to announce our new collaboration features. Try them out today...",
            "Thank you for the detailed proposal. Overall it looks great, just a few minor suggestions...",
            "Your registration for DesignConf 2024 has been confirmed. See you in San Francisco...",
            "Here's what's been happening this month in design, development, and innovation..."
        ]
        
        let calendar = Calendar.current
        let now = Date()
        
        recentEmails = (0..<Int.random(in: 8...12)).map { i in
            let hoursAgo = Int.random(in: 0...168) // Within last week
            let receivedAt = calendar.date(byAdding: .hour, value: -hoursAgo, to: now) ?? now
            let isUnread = Bool.random() && hoursAgo < 24 // More likely to be unread if recent
            
            return EmailMessage(
                sender: senders.randomElement() ?? "Unknown",
                subject: subjects.randomElement() ?? "No Subject",
                preview: previews.randomElement() ?? "",
                receivedAt: receivedAt,
                isUnread: isUnread,
                hasAttachment: Bool.random() && Int.random(in: 1...10) <= 3, // 30% chance
                priority: EmailPriority.allCases.randomElement() ?? .normal
            )
        }.sorted { $0.receivedAt > $1.receivedAt }
        
        // Calculate totals
        unreadCount = recentEmails.filter { $0.isUnread }.count + accounts.reduce(0) { $0 + $1.unreadCount }
        totalEmails = Int.random(in: 500...2000)
    }
}

// MARK: - Configuration View

struct EmailConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Email Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows inbox with unread count, recent messages, and account status. In a real implementation, this would integrate with Mail app via AppleScript or EventKit.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}