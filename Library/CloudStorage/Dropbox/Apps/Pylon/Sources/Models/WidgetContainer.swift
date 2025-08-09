//
//  WidgetContainer.swift
//  Pylon
//
//  Created on 04.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

// Temporary bridge to new grid system
typealias GridCell = GridPosition

/// Protocol defining the container architecture for all Pylon widgets
/// Widgets are designed as containers where content can be swapped dynamically
@MainActor
protocol WidgetContainer: Identifiable, Sendable {
    var id: UUID { get }
    var size: WidgetSize { get set }
    var theme: WidgetThemeOverride? { get set }
    var isEnabled: Bool { get set }
    var gridPosition: GridCell { get set }

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
    case all
    case productivity
    case information
    case system
    case communication
    case entertainment
    case health

    var displayName: String {
        switch self {
        case .all: "All"
        case .productivity: "Productivity"
        case .information: "Information"
        case .system: "System"
        case .communication: "Communication"
        case .entertainment: "Entertainment"
        case .health: "Health"
        }
    }

    var iconName: String {
        switch self {
        case .all: "square.grid.3x3"
        case .productivity: "checklist"
        case .information: "info.circle"
        case .system: "cpu"
        case .communication: "message"
        case .entertainment: "play.circle"
        case .health: "heart"
        }
    }
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
