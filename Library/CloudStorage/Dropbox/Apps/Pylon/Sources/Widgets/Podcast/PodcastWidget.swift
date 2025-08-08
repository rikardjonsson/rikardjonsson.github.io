//
//  PodcastWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

/// Podcast widget showing subscriptions, episodes, and playback status
/// Demonstrates audio content management with mock podcast data
@MainActor
final class PodcastWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: PodcastContent
    
    // MARK: - Widget Metadata
    
    let title = "Podcasts"
    let category = WidgetCategory.entertainment
    let supportedSizes: [WidgetSize] = [.medium, .large, .xlarge]
    
    // Proxy content properties
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = PodcastContent()
    }
    
    // MARK: - Lifecycle Methods
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(PodcastConfigurationView())
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
                    largeLayout(theme: theme) // Use large layout for xlarge
                }
            }
        )
    }
    
    // MARK: - Size-Specific Layouts
    
    private func mediumLayout(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "podcast.fill")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                
                Text("Podcasts")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                if content.isPlaying {
                    playingIndicator(theme: theme)
                }
            }
            
            if let currentEpisode = content.currentEpisode {
                currentlyPlayingCompact(currentEpisode, theme: theme)
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(content.newEpisodes.prefix(3)), id: \.id) { episode in
                        self.episodeRow(episode, theme: theme, compact: true)
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
                Image(systemName: "podcast.fill")
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                
                Text("Podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    if content.isPlaying {
                        playingIndicator(theme: theme)
                    }
                    
                    unplayedBadge(count: content.unplayedCount, theme: theme)
                }
            }
            
            if let currentEpisode = content.currentEpisode {
                currentlyPlaying(currentEpisode, theme: theme)
                
                Divider()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("New Episodes")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                VStack(spacing: 6) {
                    ForEach(Array(content.newEpisodes.prefix(4)), id: \.id) { episode in
                        self.episodeRow(episode, theme: theme, compact: false)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    // MARK: - Helper Views
    
    private func episodeRow(_ episode: PodcastEpisode, theme: any Theme, compact: Bool) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(episode.isUnplayed ? theme.accentColor : Color.clear)
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(episode.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(episode.isUnplayed ? .semibold : .medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                if !compact {
                    Text(episode.podcastName)
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTime(episode.publishedAt))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                
                if !compact {
                    Text(formatDuration(episode.duration))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary.opacity(0.7))
                }
            }
        }
    }
    
    private func episodeRowDetailed(_ episode: PodcastEpisode, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(episode.isUnplayed ? theme.accentColor : Color.clear)
                    .frame(width: 6, height: 6)
                
                Text(episode.title)
                    .font(.subheadline)
                    .fontWeight(episode.isUnplayed ? .semibold : .medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(2)
                
                Spacer()
                
                Text(formatTime(episode.publishedAt))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
            
            HStack {
                Text(episode.podcastName)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                Spacer()
                
                Text(formatDuration(episode.duration))
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary.opacity(0.7))
            }
            
            if !episode.description.isEmpty {
                Text(episode.description)
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary.opacity(0.8))
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func currentlyPlayingCompact(_ episode: PodcastEpisode, theme: any Theme) -> some View {
        HStack(spacing: 8) {
            playingIndicator(theme: theme)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Now Playing")
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
                
                Text(episode.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(theme.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private func currentlyPlaying(_ episode: PodcastEpisode, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                playingIndicator(theme: theme)
                
                Text("Now Playing")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(2)
                
                Text(episode.podcastName)
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                
                ProgressView(value: episode.playbackProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                    .scaleEffect(y: 0.6)
                
                HStack {
                    Text(formatDuration(Int(Double(episode.duration) * episode.playbackProgress)))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    Text(formatDuration(episode.duration))
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(theme.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func subscriptionRow(_ podcast: PodcastSubscription, theme: any Theme) -> some View {
        HStack {
            Circle()
                .fill(podcastColor(for: podcast.name))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(podcast.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                Text(podcast.category)
                    .font(.caption2)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
            
            if podcast.newEpisodes > 0 {
                Text("\(podcast.newEpisodes)")
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
    private func unplayedBadge(count: Int, theme: any Theme) -> some View {
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
    
    private func playingIndicator(theme: any Theme) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { _ in
                Rectangle()
                    .fill(theme.accentColor)
                    .frame(width: 2, height: 8)
                    .animation(.easeInOut(duration: 0.8).repeatForever(), value: self.content.isPlaying)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func podcastColor(for name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .cyan]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Podcast Data Models

struct PodcastEpisode: Identifiable {
    let id = UUID()
    let title: String
    let podcastName: String
    let description: String
    let duration: Int // in seconds
    let publishedAt: Date
    let isUnplayed: Bool
    let playbackProgress: Double // 0.0 to 1.0
}

struct PodcastSubscription: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let newEpisodes: Int
    let isSubscribed: Bool
}

// MARK: - Podcast Content

@MainActor
final class PodcastContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var newEpisodes: [PodcastEpisode] = []
    @Published var subscriptions: [PodcastSubscription] = []
    @Published var currentEpisode: PodcastEpisode?
    @Published var isPlaying: Bool = false
    @Published var unplayedCount: Int = 0
    
    init() {
        generateMockData()
        lastUpdated = Date()
    }
    
    @MainActor
    func refresh() async throws {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            generateMockData()
            lastUpdated = Date()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    private func generateMockData() {
        // Generate subscriptions
        let podcastData = [
            ("The Tim Ferriss Show", "Business", Int.random(in: 0...3)),
            ("Design Better", "Design", Int.random(in: 0...2)),
            ("The Daily", "News", Int.random(in: 0...5)),
            ("TED Talks Daily", "Education", Int.random(in: 0...4)),
            ("Syntax", "Technology", Int.random(in: 0...2)),
            ("How I Built This", "Business", Int.random(in: 0...1)),
            ("Criminal", "True Crime", Int.random(in: 0...1)),
            ("Radiolab", "Science", Int.random(in: 0...2))
        ]
        
        subscriptions = podcastData.map { (name, category, newCount) in
            PodcastSubscription(
                name: name,
                category: category,
                newEpisodes: newCount,
                isSubscribed: true
            )
        }.shuffled()
        
        // Generate episodes
        let episodeTitles = [
            "The Art of Learning from Failure",
            "Building Resilient Design Systems",
            "The Future of Remote Work",
            "Mastering Creative Problem Solving",
            "The Psychology of User Experience",
            "Building Better Teams",
            "The Science of Habit Formation",
            "Designing for Accessibility",
            "The Power of Deep Work",
            "Innovation in Uncertain Times",
            "The Art of Clear Communication",
            "Building Sustainable Products"
        ]
        
        let descriptions = [
            "How embracing failure can accelerate learning and growth in your career and personal life.",
            "Strategies for creating design systems that scale across teams and evolve with your product.",
            "Exploring how remote work is reshaping company culture and productivity.",
            "Techniques and frameworks for approaching complex challenges with creativity.",
            "Understanding cognitive biases and psychology principles that drive user behavior.",
            "Leadership strategies for building high-performing, collaborative teams.",
            "The neuroscience behind how habits form and how to build better ones.",
            "Practical approaches to making your products usable by everyone.",
            "How to cultivate focus and concentration in our distracted world.",
            "Navigating change and finding opportunities in unpredictable times.",
            "Tools and techniques for communicating ideas clearly and persuasively.",
            "Balancing business success with environmental and social responsibility."
        ]
        
        let podcastNames = subscriptions.map { $0.name }
        let calendar = Calendar.current
        let now = Date()
        
        newEpisodes = (0..<Int.random(in: 6...10)).map { i in
            let hoursAgo = Int.random(in: 1...72)
            let publishedAt = calendar.date(byAdding: .hour, value: -hoursAgo, to: now) ?? now
            let isUnplayed = Bool.random() && hoursAgo < 24 // More likely unplayed if recent
            
            return PodcastEpisode(
                title: episodeTitles.randomElement() ?? "Episode \(i + 1)",
                podcastName: podcastNames.randomElement() ?? "Unknown Podcast",
                description: descriptions.randomElement() ?? "",
                duration: Int.random(in: 1200...7200), // 20 min to 2 hours
                publishedAt: publishedAt,
                isUnplayed: isUnplayed,
                playbackProgress: isUnplayed ? 0.0 : Double.random(in: 0.0...1.0)
            )
        }.sorted { $0.publishedAt > $1.publishedAt }
        
        // Set currently playing episode
        isPlaying = Bool.random() && Double.random(in: 0...1) < 0.4 // 40% chance of playing
        if isPlaying {
            let playingEpisode = newEpisodes.first { $0.playbackProgress > 0 && $0.playbackProgress < 1 }
            currentEpisode = playingEpisode ?? newEpisodes.first
            if currentEpisode?.playbackProgress == 0 {
                currentEpisode = PodcastEpisode(
                    title: currentEpisode?.title ?? "Unknown",
                    podcastName: currentEpisode?.podcastName ?? "Unknown",
                    description: currentEpisode?.description ?? "",
                    duration: currentEpisode?.duration ?? 1800,
                    publishedAt: currentEpisode?.publishedAt ?? Date(),
                    isUnplayed: false,
                    playbackProgress: Double.random(in: 0.1...0.9)
                )
            }
        }
        
        // Calculate unplayed count
        unplayedCount = newEpisodes.filter { $0.isUnplayed }.count + 
                       subscriptions.reduce(0) { $0 + $1.newEpisodes }
    }
}

// MARK: - Configuration View

struct PodcastConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Podcast Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Shows podcast subscriptions, new episodes, and playback status with mock data. In a real implementation, this would integrate with Apple Podcasts or other podcast apps.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}