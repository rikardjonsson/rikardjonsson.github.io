//
//  PhotosWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class PhotosWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var position: GridPosition = .zero
    
    @Published private var content: PhotosContent
    
    let title = "Photos"
    let category = WidgetCategory.entertainment
    let supportedSizes: [WidgetSize] = [.small, .medium, .large, .xlarge]
    
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = PhotosContent()
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
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                        Text("\(content.recentPhotos.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                        Text("photos")
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                    }
                case .medium:
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundColor(theme.accentColor)
                            Text("Recent Photos")
                                .font(.headline)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                            ForEach(Array(content.recentPhotos.prefix(6)), id: \.id) { photo in
                                self.photoThumbnail(photo, theme: theme)
                            }
                        }
                        Spacer()
                    }
                case .large:
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundColor(theme.accentColor)
                            Text("Photo Library")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4), spacing: 4) {
                            ForEach(Array(content.recentPhotos.prefix(8)), id: \.id) { photo in
                                self.photoThumbnail(photo, theme: theme)
                            }
                        }
                        
                        HStack {
                            Text("\(content.totalPhotos) total photos")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                            Spacer()
                            if let lastUpdated = content.lastUpdated {
                                Text("Updated: \(formatTime(lastUpdated))")
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                        Spacer()
                    }
                case .xlarge:
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundColor(theme.accentColor)
                            Text("Photo Library")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                            Text("\(content.totalPhotos) photos")
                                .font(.subheadline)
                                .foregroundColor(theme.textSecondary)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 4) {
                            ForEach(content.recentPhotos, id: \.id) { photo in
                                self.photoThumbnail(photo, theme: theme)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private func photoThumbnail(_ photo: PhotoItem, theme: any Theme) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(photo.dominantColor.opacity(0.3))
            .overlay(
                Image(systemName: photo.systemIcon)
                    .font(.system(size: 16))
                    .foregroundColor(photo.dominantColor)
            )
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: 40)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct PhotoItem: Identifiable {
    let id = UUID()
    let name: String
    let dateTaken: Date
    let dominantColor: Color
    let systemIcon: String
}

@MainActor
final class PhotosContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    @Published var recentPhotos: [PhotoItem] = []
    @Published var totalPhotos: Int = 0
    
    init() {
        generateMockPhotos()
        lastUpdated = Date()
    }
    
    func refresh() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 1_200_000_000)
        generateMockPhotos()
        lastUpdated = Date()
        isLoading = false
    }
    
    private func generateMockPhotos() {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .cyan]
        let icons = ["photo", "camera", "video", "heart", "star", "leaf", "sun.max", "moon"]
        
        totalPhotos = Int.random(in: 500...2000)
        
        recentPhotos = (0..<Int.random(in: 8...15)).map { i in
            let daysAgo = Int.random(in: 0...30)
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            
            return PhotoItem(
                name: "Photo \(i + 1)",
                dateTaken: date,
                dominantColor: colors.randomElement() ?? .blue,
                systemIcon: icons.randomElement() ?? "photo"
            )
        }.sorted { $0.dateTaken > $1.dateTaken }
    }
}