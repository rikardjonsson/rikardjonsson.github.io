//
//  WidgetContainer.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// Protocol defining the container architecture for all Pylon widgets
/// Widgets are designed as containers where content can be swapped dynamically
@MainActor
protocol WidgetContainer: Identifiable {
    var id: UUID { get }
    var size: WidgetSize { get set }
    var theme: WidgetThemeOverride? { get set }
    var isEnabled: Bool { get set }
    var position: GridPosition { get set }

    /// Widget metadata
    var title: String { get }
    var category: WidgetCategory { get }
    var supportedSizes: [WidgetSize] { get }
    var lastUpdated: Date? { get }
    var isLoading: Bool { get }
    var error: Error? { get }

    /// Lifecycle methods
    func refresh() async throws
    func configure() -> AnyView

    /// Main widget view
    func body(theme: any Theme, gridUnit: CGFloat, spacing: CGFloat) -> AnyView
}

/// Content protocol for swappable widget content
@MainActor
protocol WidgetContent: ObservableObject {
    var lastUpdated: Date? { get }
    var isLoading: Bool { get }
    var error: Error? { get }

    func refresh() async throws
}

/// Widget categories for organization
enum WidgetCategory: String, CaseIterable, Sendable {
    case productivity
    case information
    case system
    case communication
    case entertainment

    var displayName: String {
        switch self {
        case .productivity: "Productivity"
        case .information: "Information"
        case .system: "System"
        case .communication: "Communication"
        case .entertainment: "Entertainment"
        }
    }

    var iconName: String {
        switch self {
        case .productivity: "checklist"
        case .information: "info.circle"
        case .system: "cpu"
        case .communication: "message"
        case .entertainment: "play.circle"
        }
    }
}

/// Grid position for widget layout
struct GridPosition: Sendable, Codable, Equatable {
    let x: Int
    let y: Int

    static let zero = GridPosition(x: 0, y: 0)
}

/// Theme overrides specific to a widget
struct WidgetThemeOverride: Sendable, Codable {
    let accentColor: String?
    let backgroundOpacity: Double?
    let cornerRadius: Double?

    init(
        accentColor: String? = nil,
        backgroundOpacity: Double? = nil,
        cornerRadius: Double? = nil
    ) {
        self.accentColor = accentColor
        self.backgroundOpacity = backgroundOpacity
        self.cornerRadius = cornerRadius
    }
}
