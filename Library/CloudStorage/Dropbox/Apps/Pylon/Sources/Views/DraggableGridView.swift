//
//  DraggableGridView.swift
//  Pylon
//
//  Created on 05.08.25.
//  Copyright © 2025. All rights reserved.
//
// DEPRECATED: This file is being replaced by TetrisGrid
// Keeping as stub to avoid compilation errors until cleanup

import SwiftUI

/// Stub implementation - DraggableGridView has been replaced by TetrisGrid
/// This file is kept temporarily to avoid compilation errors
struct DraggableGridView: View {
    let gridConfig: GridConfiguration
    let containers: [any WidgetContainer]
    
    init(gridConfig: GridConfiguration, containers: [any WidgetContainer]) {
        self.gridConfig = gridConfig
        self.containers = containers
    }
    
    var body: some View {
        VStack {
            Text("DraggableGridView is deprecated")
                .foregroundColor(.red)
            Text("Use TetrisGrid instead")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}