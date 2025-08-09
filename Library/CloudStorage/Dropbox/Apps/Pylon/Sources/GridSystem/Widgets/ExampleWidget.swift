//
//  ExampleWidget.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Example widget implementation
//

import Foundation
import SwiftUI

/// Example widget demonstrating the GridWidget protocol
struct ExampleWidget: GridWidget {
    let id = UUID()
    var size: GridSize
    var position: GridPosition = .zero
    let title: String
    let category: GridWidgetCategory
    let type: String = "example"
    var isEnabled: Bool = true
    
    // Mock data properties
    var lastUpdated: Date? = Date()
    var isLoading: Bool = false
    var error: (any Error)? = nil
    
    // MARK: - Initialization
    
    init(title: String, size: GridSize = .medium, category: GridWidgetCategory = .utilities) {
        self.title = title
        self.size = size
        self.category = category
    }
    
    // MARK: - GridWidget Implementation
    
    @MainActor
    func body(theme: any Theme, configuration: GridConfiguration) -> AnyView {
        AnyView(
            VStack(spacing: 8) {
                // Header
                HStack {
                    Image(systemName: category.systemImage)
                        .font(.title2)
                        .foregroundStyle(theme.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(theme.primaryColor)
                        Text(category.displayName)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryColor)
                    }
                    
                    Spacer()
                }
                
                if size != .small {
                    // Content area
                    VStack(spacing: 4) {
                        Text("Example Content")
                            .font(.body)
                            .foregroundStyle(theme.primaryColor)
                        Text("Size: \(size.displayName)")
                            .font(.caption)
                            .foregroundStyle(theme.secondaryColor)
                    }
                }
            }
        )
    }
}

// Note: Clock and Weather widgets are defined elsewhere to avoid conflicts