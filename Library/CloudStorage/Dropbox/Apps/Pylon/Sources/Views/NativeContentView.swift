//
//  NativeContentView.swift
//  Pylon
//
//  Created on 05.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/// Native macOS content view following Apple's Human Interface Guidelines
struct NativeContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingAddSheet = false
    
    private let nativeTheme = NativeMacOSTheme()
    
    var body: some View {
        VStack(spacing: 0) {
            // Native macOS toolbar
            nativeToolbar
                .background(.windowBackground)
                .overlay(alignment: .bottom) {
                    Divider()
                }
            
            // Main content with native materials
            nativeMainContent
                .background(.windowBackground)
        }
        .sheet(isPresented: $showingAddSheet) {
            NativeAddWidgetSheet()
        }
    }
    
    // MARK: - Native Toolbar
    
    private var nativeToolbar: some View {
        HStack(spacing: NativeMacOSTheme.Spacing.md) {
            // App title with native typography
            VStack(alignment: .leading, spacing: NativeMacOSTheme.Spacing.xxxs) {
                Text("Pylon")
                    .font(NativeMacOSTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                Text("Life's a loop because no one learns anything")
                    .font(NativeMacOSTheme.Typography.caption1)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Native toolbar controls
            HStack(spacing: NativeMacOSTheme.Spacing.xs) {
                // Add widget button - native style
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Widget", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                
                // Refresh button - native style  
                Button {
                    Task {
                        await appState.refreshAllWidgets()
                    }
                } label: {
                    Label("Refresh", systemImage: appState.isRefreshing ? "arrow.circlepath" : "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .disabled(appState.isRefreshing)
                .symbolEffect(.rotate, isActive: appState.isRefreshing)
            }
        }
        .padding(.horizontal, NativeMacOSTheme.Spacing.xl)
        .padding(.vertical, NativeMacOSTheme.Spacing.md)
        .frame(height: 60) // Standard macOS toolbar height
    }
    
    // MARK: - Native Main Content
    
    private var nativeMainContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if appState.widgetManager.containers.isEmpty {
                    nativeEmptyState
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    nativeWidgetGrid
                        .padding(.top, NativeMacOSTheme.Spacing.xs)
                        .padding(.horizontal, NativeMacOSTheme.Spacing.xs)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(.windowBackground)
    }
    
    // MARK: - Native Empty State
    
    private var nativeEmptyState: some View {
        VStack(spacing: NativeMacOSTheme.Spacing.xl) {
            // Native SF Symbol icon
            Image(systemName: "rectangle.3.group")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: NativeMacOSTheme.Spacing.sm) {
                Text("Welcome to Pylon")
                    .font(NativeMacOSTheme.Typography.title2)
                    .foregroundStyle(.primary)
                
                Text("Create your personalized dashboard by adding widgets")
                    .font(NativeMacOSTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Native prominent button
            Button {
                showingAddSheet = true
            } label: {
                Label("Add Your First Widget", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(NativeMacOSTheme.Spacing.xxxl)
        .frame(maxWidth: 480) // Optimal reading width
    }
    
    // MARK: - Native Widget Grid
    
    private var nativeWidgetGrid: some View {
        TetrisGrid(
            widgets: convertToGridWidgets(appState.widgetManager.enabledContainers())
        )
        .frame(maxWidth: .infinity, minHeight: 600)
    }
    
    // MARK: - Helper Methods
    
    /// Convert existing widgets to GridWidget protocol
    private func convertToGridWidgets(_ containers: [any WidgetContainer]) -> [any GridWidget] {
        return WidgetAdapterFactory.adapt(containers)
    }
}

// MARK: - Native Add Widget Sheet

struct NativeAddWidgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    private let nativeTheme = NativeMacOSTheme()
    
    private let widgetTypes: [WidgetType] = [
        WidgetType(id: "clock", name: "Clock", icon: "clock", description: "Current time and date"),
        WidgetType(id: "weather", name: "Weather", icon: "cloud.sun", description: "Weather conditions"),
        WidgetType(id: "calendar", name: "Calendar", icon: "calendar", description: "Upcoming events"),
        WidgetType(id: "reminders", name: "Reminders", icon: "checklist", description: "Task list"),
        WidgetType(id: "notes", name: "Notes", icon: "note.text", description: "Quick notes"),
        WidgetType(id: "system", name: "System Monitor", icon: "cpu", description: "System performance"),
        WidgetType(id: "fitness", name: "Fitness", icon: "heart", description: "Health data"),
        WidgetType(id: "finance", name: "Finance", icon: "chart.line.uptrend.xyaxis", description: "Portfolio tracking"),
        WidgetType(id: "email", name: "Mail", icon: "envelope", description: "Unread messages"),
        WidgetType(id: "stocks", name: "Stocks", icon: "chart.bar", description: "Stock prices"),
        WidgetType(id: "crypto", name: "Crypto", icon: "bitcoinsign.circle", description: "Cryptocurrency"),
        WidgetType(id: "news", name: "News", icon: "newspaper", description: "Latest headlines")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Native search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search widgets", text: .constant(""))
                        .textFieldStyle(.plain)
                }
                .padding(NativeMacOSTheme.Spacing.sm)
                .background(.quinary, in: RoundedRectangle(cornerRadius: NativeMacOSTheme.CornerRadius.sm))
                .padding(NativeMacOSTheme.Spacing.xl)
                
                // Native list
                List(widgetTypes) { widgetType in
                    NativeWidgetTypeRow(widgetType: widgetType) {
                        addWidget(type: widgetType.id)
                        dismiss()
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Widget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 600)
    }
    
    private func addWidget(type: String) {
        // Add widget based on type
        switch type {
        case "clock": appState.widgetManager.registerContainer(ClockWidget())
        case "weather": appState.widgetManager.registerContainer(WeatherWidget())
        case "calendar": appState.widgetManager.registerContainer(CalendarWidget())
        case "reminders": appState.widgetManager.registerContainer(RemindersWidget())
        case "notes": appState.widgetManager.registerContainer(NotesWidget())
        case "system": appState.widgetManager.registerContainer(SystemMonitorWidget())
        case "fitness": appState.widgetManager.registerContainer(FitnessWidget())
        case "finance": appState.widgetManager.registerContainer(FinanceWidget())
        case "email": appState.widgetManager.registerContainer(EmailWidget())
        case "stocks": appState.widgetManager.registerContainer(StocksWidget())
        case "crypto": appState.widgetManager.registerContainer(CryptoWidget())
        case "news": appState.widgetManager.registerContainer(NewsWidget())
        default: break
        }
    }
}

// MARK: - Native Widget Type Row

struct NativeWidgetTypeRow: View {
    let widgetType: WidgetType
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: NativeMacOSTheme.Spacing.md) {
            // Native SF Symbol
            Image(systemName: widgetType.icon)
                .font(.title2)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 32, height: 32)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: NativeMacOSTheme.CornerRadius.sm))
            
            VStack(alignment: .leading, spacing: NativeMacOSTheme.Spacing.xxxs) {
                Text(widgetType.name)
                    .font(NativeMacOSTheme.Typography.body)
                    .foregroundStyle(.primary)
                
                Text(widgetType.description)
                    .font(NativeMacOSTheme.Typography.caption1)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Add") {
                onAdd()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, NativeMacOSTheme.Spacing.xs)
    }
}

// MARK: - Supporting Types

struct WidgetType: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
}

#Preview {
    NativeContentView()
        .environmentObject(AppState())
}