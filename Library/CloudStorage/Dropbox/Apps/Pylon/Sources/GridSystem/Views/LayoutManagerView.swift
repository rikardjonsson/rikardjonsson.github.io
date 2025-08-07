//
//  LayoutManagerView.swift
//  Pylon
//
//  Created on 06.08.25.
//  Grid Layout System - Layout management interface
//

import SwiftUI

/// Layout management interface for saving, loading, and organizing grid layouts
struct LayoutManagerView: View {
    @State private var persistence: GridLayoutPersistence
    @State private var gridManager: GridManager
    @State private var showingSaveDialog = false
    @State private var newLayoutName = ""
    @State private var selectedLayout: GridLayoutData?
    @State private var showingImportPicker = false
    @State private var showingExportSheet = false
    
    let theme: any Theme
    
    init(gridManager: GridManager, theme: any Theme) throws {
        self._gridManager = State(initialValue: gridManager)
        self._persistence = State(initialValue: try GridLayoutPersistence())
        self.theme = theme
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Current Layout Info
                currentLayoutSection
                
                // Actions
                actionButtonsSection
                
                // Saved Layouts
                savedLayoutsSection
            }
            .padding()
            .navigationTitle("Grid Layouts")
            .background(theme.backgroundColor.opacity(0.05))
        }
        .sheet(isPresented: $showingSaveDialog) {
            saveLayoutDialog
        }
        .sheet(isPresented: $showingExportSheet) {
            if let selectedLayout = selectedLayout {
                exportLayoutSheet(for: selectedLayout)
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
    }
    
    // MARK: - Current Layout Section
    
    private var currentLayoutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "grid")
                    .foregroundStyle(theme.accentColor)
                Text("Current Layout")
                    .font(.headline)
                    .foregroundStyle(theme.primaryColor)
                Spacer()
                
                if let currentId = persistence.currentLayoutId,
                   let currentLayout = persistence.savedLayouts.first(where: { $0.id == currentId }) {
                    Text(currentLayout.name)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.accentColor.opacity(0.2), in: Capsule())
                }
            }
            
            HStack {
                Label("\(gridManager.widgets.count) widgets", systemImage: "square.grid.3x3")
                Spacer()
                Label("\(gridManager.configuration.bounds.columns) columns", systemImage: "rectangle.split.3x1")
            }
            .font(.caption)
            .foregroundStyle(theme.secondaryColor)
        }
        .padding()
        .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(theme.accentColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Save Current Layout
            Button {
                showingSaveDialog = true
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            
            // Import Layout
            Button {
                showingImportPicker = true
            } label: {
                Label("Import", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            
            // Auto-save Toggle
            Button {
                persistence.autoSaveLayout(gridManager)
            } label: {
                Label("Auto-save", systemImage: "clock")
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
    }
    
    // MARK: - Saved Layouts Section
    
    private var savedLayoutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Saved Layouts")
                    .font(.headline)
                    .foregroundStyle(theme.primaryColor)
                
                Spacer()
                
                Text("\(persistence.savedLayouts.count) layouts")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryColor)
            }
            
            if persistence.savedLayouts.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(persistence.savedLayouts) { layout in
                        LayoutRowView(
                            layout: layout,
                            theme: theme,
                            isCurrent: persistence.currentLayoutId == layout.id,
                            onLoad: { loadLayout(layout) },
                            onExport: { exportLayout(layout) },
                            onDelete: { deleteLayout(layout) }
                        )
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(theme.secondaryColor.opacity(0.6))
            
            Text("No saved layouts")
                .font(.headline)
                .foregroundStyle(theme.primaryColor)
            
            Text("Save your current layout to get started")
                .font(.caption)
                .foregroundStyle(theme.secondaryColor)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Save Dialog
    
    private var saveLayoutDialog: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Layout Name")
                        .font(.headline)
                    
                    TextField("Enter layout name", text: $newLayoutName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { saveCurrentLayout() }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Save Layout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingSaveDialog = false
                        newLayoutName = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCurrentLayout()
                    }
                    .disabled(newLayoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Export Sheet
    
    private func exportLayoutSheet(for layout: GridLayoutData) -> some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Export \"\(layout.name)\"")
                    .font(.headline)
                
                Text("This will create a JSON file that can be imported later or shared with others.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.secondaryColor)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Layout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingExportSheet = false
                        selectedLayout = nil
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Export") {
                        performExport(layout)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveCurrentLayout() {
        let trimmedName = newLayoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        do {
            try persistence.saveLayout(gridManager, name: trimmedName)
            showingSaveDialog = false
            newLayoutName = ""
        } catch {
            print("❌ Failed to save layout: \(error)")
        }
    }
    
    private func loadLayout(_ layout: GridLayoutData) {
        do {
            try persistence.loadLayout(layout, into: gridManager)
        } catch {
            print("❌ Failed to load layout: \(error)")
        }
    }
    
    private func exportLayout(_ layout: GridLayoutData) {
        selectedLayout = layout
        showingExportSheet = true
    }
    
    private func performExport(_ layout: GridLayoutData) {
        do {
            let data = try persistence.exportLayout(layout)
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(layout.name).json")
            
            try data.write(to: tempURL)
            
            #if os(macOS)
            NSWorkspace.shared.selectFile(tempURL.path, inFileViewerRootedAtPath: tempURL.deletingLastPathComponent().path)
            #endif
            
            showingExportSheet = false
            selectedLayout = nil
            
        } catch {
            print("❌ Failed to export layout: \(error)")
        }
    }
    
    private func deleteLayout(_ layout: GridLayoutData) {
        do {
            try persistence.deleteLayout(layout)
        } catch {
            print("❌ Failed to delete layout: \(error)")
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                _ = try persistence.importLayout(from: data)
                print("✅ Imported layout successfully")
            } catch {
                print("❌ Failed to import layout: \(error)")
            }
            
        case .failure(let error):
            print("❌ Import failed: \(error)")
        }
    }
}

// MARK: - Layout Row View

private struct LayoutRowView: View {
    let layout: GridLayoutData
    let theme: any Theme
    let isCurrent: Bool
    let onLoad: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(layout.name)
                        .font(.headline)
                        .foregroundStyle(theme.primaryColor)
                    
                    if isCurrent {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(theme.accentColor)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Label("\(layout.widgets.count) widgets", systemImage: "square.grid.3x3")
                    Spacer()
                    Text(layout.lastModified, style: .relative)
                }
                .font(.caption)
                .foregroundStyle(theme.secondaryColor)
            }
            
            Menu {
                Button("Load", action: onLoad)
                Button("Export", action: onExport)
                Divider()
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(theme.secondaryColor)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isCurrent ? theme.accentColor.opacity(0.5) : theme.secondaryColor.opacity(0.2),
                    lineWidth: isCurrent ? 2 : 1
                )
        )
    }
}