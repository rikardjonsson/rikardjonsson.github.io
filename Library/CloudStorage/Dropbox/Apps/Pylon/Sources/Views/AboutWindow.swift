//
//  AboutWindow.swift
//  Pylon
//
//  Created on 08.08.25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

struct AboutWindow: View {
    var body: some View {
        VStack(spacing: 20) {
            // App Icon and Title
            VStack(spacing: 8) {
                Image(nsImage: NSApplication.shared.applicationIconImage ?? NSImage())
                    .resizable()
                    .frame(width: 128, height: 128)
                
                Text("Pylon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Next-Generation macOS Dashboard")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Version Information
            VStack(spacing: 4) {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Version \(version) (\(build))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Built with Swift 6.0 & SwiftUI")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text("A modular productivity dashboard that deeply integrates with the macOS ecosystem. Features drag-and-drop widget layouts, real-time data from EventKit and WeatherKit, and intelligent grid-based positioning.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            // Copyright
            Text("Copyright © 2025. All rights reserved.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
            
            Spacer()
        }
        .frame(width: 400, height: 500)
        .padding()
    }
}

#Preview {
    AboutWindow()
}