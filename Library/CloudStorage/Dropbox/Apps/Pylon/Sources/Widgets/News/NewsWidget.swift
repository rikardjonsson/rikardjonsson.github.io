//
//  NewsWidget.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class NewsWidget: WidgetContainer, ObservableObject {
    let id = UUID()
    @Published var size: WidgetSize = .large
    @Published var theme: WidgetThemeOverride?
    @Published var isEnabled: Bool = true
    @Published var gridPosition: GridCell = GridCell(row: 0, column: 0)
    
    @Published private var content: NewsContent
    
    let title = "News"
    let category = WidgetCategory.information
    let supportedSizes: [WidgetSize] = [.medium, .large, .xlarge]
    
    var lastUpdated: Date? { content.lastUpdated }
    var isLoading: Bool { content.isLoading }
    var error: Error? { content.error }
    
    init() {
        content = NewsContent()
    }
    
    func refresh() async throws {
        try await content.refresh()
    }
    
    func configure() -> AnyView {
        AnyView(EmptyView())
    }
    
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView {
        AnyView(
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "newspaper")
                        .font(.title)
                        .foregroundColor(theme.accentColor)
                    Text("Latest News")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    ForEach(content.articles, id: \.id) { article in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(article.headline)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(theme.textPrimary)
                                .lineLimit(2)
                            
                            HStack {
                                Text(article.source)
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondary)
                                Spacer()
                                Text(self.formatTime(article.publishedAt))
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct NewsArticle: Identifiable {
    let id = UUID()
    let headline: String
    let source: String
    let publishedAt: Date
}

@MainActor
final class NewsContent: WidgetContent, ObservableObject {
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var articles: [NewsArticle] = []
    
    init() {
        generateMockNews()
        lastUpdated = Date()
    }
    
    func refresh() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 1_800_000_000)
        generateMockNews()
        lastUpdated = Date()
        isLoading = false
    }
    
    private func generateMockNews() {
        let headlines = [
            "Tech Giants Report Record Quarterly Earnings",
            "Climate Summit Reaches Historic Agreement",
            "Space Mission Successfully Lands on Mars",
            "New Medical Breakthrough Shows Promise",
            "Global Markets Rally on Economic News"
        ]
        let sources = ["Reuters", "AP News", "BBC", "CNN", "Forbes"]
        
        articles = (0..<5).map { i in
            let hoursAgo = Int.random(in: 1...24)
            let date = Calendar.current.date(byAdding: .hour, value: -hoursAgo, to: Date()) ?? Date()
            
            return NewsArticle(
                headline: headlines[i],
                source: sources[i],
                publishedAt: date
            )
        }
    }
}