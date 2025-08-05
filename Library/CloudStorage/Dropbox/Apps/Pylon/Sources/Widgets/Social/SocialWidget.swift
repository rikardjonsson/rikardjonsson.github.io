//
//  SocialWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Social widget showing notifications and messages from various platforms
/// Demonstrates social media integration with mock notification data
@MainActor
final class SocialWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    @Published private var content: SocialContent
    
    // MARK: - Widget Metadata
    
    let title = "Social"
    let category = WidgetCategory.entertainment
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = SocialContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(SocialConfigurationView())
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
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.title2)
                .foregroundColor(theme.accentColor)
            
            Text("\(content.unreadCount)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textPrimary)
            
            Text("updates")
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Social")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                notificationBadge(count: content.unreadCount, theme: theme)
            }
            
            VStack(spacing: 4) {
                ForEach(Array(content.recentNotifications.prefix(3)), id: \.id) { notification in
                    self.notificationRow(notification, theme: theme, compact: true)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func largeLayout(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Social Updates")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                platformsIndicator(theme: theme)
            }
            
            VStack(spacing: 6) {
                ForEach(Array(content.recentNotifications.prefix(6)), id: \.id) { notification in
                    self.notificationRow(notification, theme: theme, compact: false)
                }
            }
            
            HStack {
                notificationBadge(count: content.unreadCount, theme: theme)
                
                Spacer()
                
                if let lastUpdated = content.lastUpdated {
                    Text("Updated: \(formatTime(lastUpdated))")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func xlargeLayout(theme: any Theme) -> some View {
        HStack(spacing: 20) {
            // Left side - Recent notifications
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                    
                    notificationBadge(count: content.unreadCount, theme: theme)
                }
                
                VStack(spacing: 8) {
                    ForEach(content.recentNotifications, id: \.id) { notification in
                        self.notificationRowDetailed(notification, theme: theme)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 140)
            
            // Right side - Platform summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Platforms")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                
                VStack(spacing: 8) {
                    ForEach(content.platformSummary, id: \.platform) { summary in
                        self.platformRow(summary, theme: theme)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(content.totalNotifications) total")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    
                    if let lastUpdated = content.lastUpdated {
                        Text("Updated: \(formatTime(lastUpdated))")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            .frame(width: 160)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Views
    
    private func notificationRow(_ notification: SocialNotification, theme: any Theme, compact: Bool) -> some View {
        HStack(spacing: 8) {
            platformIcon(for: notification.platform)
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(notification.isUnread ? .semibold : .medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                if !compact {
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTime(notification.timestamp))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                
                if notification.isUnread {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
    
    private func notificationRowDetailed(_ notification: SocialNotification, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                platformIcon(for: notification.platform)
                    .frame(width: 18, height: 18)
                
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(notification.isUnread ? .semibold : .medium)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(notification.timestamp))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                    
                    if notification.isUnread {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            Text(notification.message)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
                .lineLimit(3)
            
            if !notification.actionText.isEmpty {
                Text(notification.actionText)
                    .font(.caption2)
                    .foregroundColor(theme.accentColor)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func platformRow(_ summary: PlatformSummary, theme: any Theme) -> some View {
        HStack {
            platformIcon(for: summary.platform)
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(summary.platform)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Text(summary.lastActivity)
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
            
            if summary.unreadCount > 0 {
                Text("\(summary.unreadCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(platformColor(for: summary.platform), in: Capsule())
            }
        }
    }
    
    @ViewBuilder
    private func notificationBadge(count: Int, theme: any Theme) -> some View {
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
    
    private func platformsIndicator(theme: any Theme) -> some View {
        HStack(spacing: -2) {
            ForEach(Array(content.platformSummary.prefix(4)), id: \.platform) { summary in
                self.platformIcon(for: summary.platform)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(theme.backgroundMaterial))
            }
            
            if content.platformSummary.count > 4 {
                Text("+\(content.platformSummary.count - 4)")
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                    .padding(.leading, 4)
            }
        }
    }
    
    private func platformIcon(for platform: String) -> some View {
        Circle()
            .fill(platformColor(for: platform))
            .overlay(
                Image(systemName: platformSystemIcon(for: platform))
                    .font(.caption2)
                    .foregroundColor(.white)
            )
    }
    
    // MARK: - Helper Methods
    
    private func platformColor(for platform: String) -> Color {
        switch platform.lowercased() {
        case "twitter": return Color.blue
        case "instagram": return Color.pink
        case "linkedin": return Color.blue
        case "facebook": return Color.blue
        case "slack": return Color.purple
        case "discord": return Color.indigo
        case "github": return Color.primary
        case "reddit": return Color.orange
        default: return Color.gray
        }
    }
    
    private func platformSystemIcon(for platform: String) -> String {
        switch platform.lowercased() {
        case "twitter": return "bird"
        case "instagram": return "camera"
        case "linkedin": return "briefcase"
        case "facebook": return "person.2"
        case "slack": return "message"
        case "discord": return "gamecontroller"
        case "github": return "chevron.left.forwardslash.chevron.right"
        case "reddit": return "bubble.left.and.bubble.right"
        default: return "bell"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Social Data Models

struct SocialNotification: Identifiable {
    let id = UUID()
    let platform: String
    let title: String
    let message: String
    let timestamp: Date
    let isUnread: Bool
    let actionText: String
    let notificationType: NotificationType
}

struct PlatformSummary {
    let platform: String
    let unreadCount: Int
    let lastActivity: String
    let isConnected: Bool
}

enum NotificationType: CaseIterable {
    case like, comment, mention, follow, message, post
}

// MARK: - Social Content

@MainActor
final class SocialContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var recentNotifications: [SocialNotification] = []
    @Published var platformSummary: [PlatformSummary] = []
    @Published var unreadCount: Int = 0
    @Published var totalNotifications: Int = 0
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_600_000_000)
            generateMockData()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockData() {
        let platforms = ["Twitter", "Instagram", "LinkedIn", "Slack", "Discord", "GitHub", "Reddit"]
        
        // Generate platform summaries
        platformSummary = platforms.map { platform in
            let unreadCount = Int.random(in: 0...15)
            let lastActivityHours = Int.random(in: 1...72)
            
            return PlatformSummary(
                platform: platform,
                unreadCount: unreadCount,
                lastActivity: "\(lastActivityHours)h ago",
                isConnected: Bool.random() || unreadCount > 0
            )
        }.filter { $0.isConnected }
        
        // Generate notifications
        let notificationTitles = [
            "Sarah liked your post",
            "New connection request",
            "You were mentioned in a comment",
            "Weekly team update",
            "Your post got 50 likes",
            "New follower: Alex Johnson",
            "Message from Design Team",
            "GitHub: PR review requested",
            "Your photo was featured",
            "Trending in your network",
            "Meeting reminder",
            "New comment on your article",
            "Event invitation received",
            "Your code was starred",
            "Weekend team social",
            "New job opportunity"
        ]
        
        let notificationMessages = [
            "Great work on the design system documentation! Really helpful for the team.",
            "Hi! I'd love to connect. We have mutual connections and similar interests.",
            "Loved your thoughts on the latest design trends. What do you think about...",
            "Here's what the team accomplished this week and our goals for next week.",
            "Your post about productivity tips is really resonating with people!",
            "Alex Johnson, Senior Designer at TechCorp, wants to connect with you.",
            "Hey team! Don't forget about the design review meeting tomorrow at 2 PM.",
            "Your pull request for the new authentication system needs review.",
            "Your sunset photography was selected for our community spotlight!",
            "3 posts from your network are trending. Check them out to stay updated.",
            "Standup meeting in 30 minutes. Join us in the main conference room.",
            "Really insightful article! I have a question about the implementation...",
            "You're invited to TechConf 2024. Early bird pricing ends this Friday.",
            "15 developers starred your open source project this week. Great work!",
            "Join us for bowling and pizza this Saturday at 6 PM. RSVP in comments.",
            "Based on your skills, this Senior Designer role might interest you."
        ]
        
        let actionTexts = [
            "", "View Profile", "Reply", "Join Meeting", "View Post", 
            "Accept", "Read More", "Review PR", "See Details", "", 
            "Join", "Respond", "View Event", "See Repository", "RSVP", "View Job"
        ]
        
        let calendar = Calendar.current
        let now = Date()
        
        recentNotifications = (0..<Int.random(in: 8...12)).map { i in
            let hoursAgo = Int.random(in: 0...72)
            let timestamp = calendar.date(byAdding: .hour, value: -hoursAgo, to: now) ?? now
            let isUnread = Bool.random() && hoursAgo < 12 // More likely unread if recent
            let platform = platforms.randomElement() ?? "Twitter"
            
            return SocialNotification(
                platform: platform,
                title: notificationTitles.randomElement() ?? "New notification",
                message: notificationMessages.randomElement() ?? "Check it out!",
                timestamp: timestamp,
                isUnread: isUnread,
                actionText: actionTexts.randomElement() ?? "",
                notificationType: NotificationType.allCases.randomElement() ?? .like
            )
        }.sorted { $0.timestamp > $1.timestamp }
        
        // Calculate totals
        unreadCount = recentNotifications.filter { $0.isUnread }.count + 
                     platformSummary.reduce(0) { $0 + $1.unreadCount }
        totalNotifications = Int.random(in: 100...500)
    }
}

// MARK: - Configuration View

struct SocialConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Social Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows notifications and updates from social media platforms with mock data. In a real implementation, this would integrate with platform APIs and notification services.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}