//
//  SettingsView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Settings icon
                    Text("⚙️")
                        .font(.system(size: 80))
                    
                    // Title
                    NeomorphicText("Settings", fontSize: .largeTitle, fontWeight: .bold)
                    
                    // Subtitle
                    Text("Configure your experience")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Placeholder for future settings
                    VStack(spacing: 15) {
                        Text("Settings will be added here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Text("Coming soon...")
                            .font(.caption)
                            .foregroundColor(.tertiary)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 