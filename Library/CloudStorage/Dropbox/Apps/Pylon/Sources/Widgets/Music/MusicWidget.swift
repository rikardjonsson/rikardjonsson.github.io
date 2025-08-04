//
//  MusicWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class MusicWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .medium
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    @Published private var content: MusicContent
    
    let title = "Music"
    let category = WidgetCategory.entertainment
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = MusicContent()
    }
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(MusicConfigurationView())
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            Group {
                switch size {
                case .small:
                    VStack(spacing: 4) {
                        Image(systemName: content.isPlaying ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                        Text(content.currentTrack?.artist ?? "Music")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                            .lineLimit(1)
                    }
                case .medium:
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "music.note")
                                .font(.title2)
                                .foregroundColor(theme.accentColor)
                            Text("Now Playing")
                                .font(.headline)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        
                        if let track = content.currentTrack {
                            VStack(spacing: 4) {
                                Text(track.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(theme.textPrimary)
                                    .lineLimit(1)
                                Text(track.artist)
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondary)
                                    .lineLimit(1)
                            }
                            
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Image(systemName: "backward.fill")
                                        .foregroundColor(theme.textSecondary)
                                }
                                Button(action: {}) {
                                    Image(systemName: content.isPlaying ? "pause.fill" : "play.fill")
                                        .foregroundColor(theme.accentColor)
                                }
                                Button(action: {}) {
                                    Image(systemName: "forward.fill")
                                        .foregroundColor(theme.textSecondary)
                                }
                            }
                            .font(.title3)
                        }
                        Spacer()
                    }
                case .large:
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundColor(theme.accentColor)
                            Text("Music Player")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        
                        if let track = content.currentTrack {
                            VStack(spacing: 8) {
                                Text(track.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textPrimary)
                                    .lineLimit(2)
                                
                                Text("\(track.artist) • \(track.album)")
                                    .font(.subheadline)
                                    .foregroundColor(theme.textSecondary)
                                    .lineLimit(1)
                                
                                // Progress bar
                                ProgressView(value: content.progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                                
                                HStack {
                                    Text(formatTime(content.currentTime))
                                        .font(.caption2)
                                        .foregroundColor(theme.textSecondary)
                                    Spacer()
                                    Text(formatTime(track.duration))
                                        .font(.caption2)
                                        .foregroundColor(theme.textSecondary)
                                }
                                
                                HStack(spacing: 20) {
                                    Button(action: {}) {
                                        Image(systemName: "backward.fill")
                                            .foregroundColor(theme.textSecondary)
                                    }
                                    Button(action: {}) {
                                        Image(systemName: content.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(theme.accentColor)
                                    }
                                    Button(action: {}) {
                                        Image(systemName: "forward.fill")
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .font(.title2)
                            }
                        }
                        Spacer()
                    }
                case .xlarge:
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Now Playing")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.textPrimary)
                            
                            if let track = content.currentTrack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(track.title)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(theme.textPrimary)
                                    
                                    Text(track.artist)
                                        .font(.subheadline)
                                        .foregroundColor(theme.textSecondary)
                                    
                                    Text(track.album)
                                        .font(.caption)
                                        .foregroundColor(theme.textSecondary.opacity(0.8))
                                    
                                    ProgressView(value: content.progress)
                                        .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                                    
                                    HStack {
                                        Text(formatTime(content.currentTime))
                                            .font(.caption2)
                                            .foregroundColor(theme.textSecondary)
                                        Spacer()
                                        Text(formatTime(track.duration))
                                            .font(.caption2)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 16) {
                            Text("Controls")
                                .font(.headline)
                                .foregroundColor(theme.textPrimary)
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    Button(action: {}) {
                                        Image(systemName: "backward.fill")
                                            .foregroundColor(theme.textSecondary)
                                    }
                                    Button(action: {}) {
                                        Image(systemName: content.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(theme.accentColor)
                                    }
                                    Button(action: {}) {
                                        Image(systemName: "forward.fill")
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .font(.title2)
                                
                                HStack(spacing: 16) {
                                    Button(action: {}) {
                                        Image(systemName: "shuffle")
                                            .foregroundColor(content.isShuffled ? theme.accentColor : theme.textSecondary)
                                    }
                                    Button(action: {}) {
                                        Image(systemName: "repeat")
                                            .foregroundColor(content.isRepeating ? theme.accentColor : theme.textSecondary)
                                    }
                                }
                                .font(.title3)
                            }
                            Spacer()
                        }
                        .frame(width: 120)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MusicTrack {
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
}

@MainActor
final class MusicContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var currentTrack: MusicTrack?
    @Published var isPlaying: Bool = true
    @Published var progress: Double = 0.3
    @Published var currentTime: TimeInterval = 45
    @Published var isShuffled: Bool = false
    @Published var isRepeating: Bool = true
    
    init() {
        generateMockTrack()
        lastUpdated = Date()
    }
    
    func refresh() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 800_000_000)
        generateMockTrack()
        lastUpdated = Date()
        isLoading = false
    }
    
    private func generateMockTrack() {
        let tracks = [
            MusicTrack(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", duration: 355),
            MusicTrack(title: "Hotel California", artist: "Eagles", album: "Hotel California", duration: 391),
            MusicTrack(title: "Imagine", artist: "John Lennon", album: "Imagine", duration: 183),
            MusicTrack(title: "Billie Jean", artist: "Michael Jackson", album: "Thriller", duration: 294),
            MusicTrack(title: "Sweet Child O' Mine", artist: "Guns N' Roses", album: "Appetite for Destruction", duration: 356)
        ]
        
        currentTrack = tracks.randomElement()
        isPlaying = Bool.random()
        progress = Double.random(in: 0.1...0.9)
        if let track = currentTrack {
            currentTime = progress * track.duration
        }
        isShuffled = Bool.random()
        isRepeating = Bool.random()
    }
}

struct MusicConfigurationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Music Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)
            Text("Shows currently playing music with playback controls. Would integrate with Music app or Spotify API.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}