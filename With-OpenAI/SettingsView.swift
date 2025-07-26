//
//  SettingsView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var temperature: Double = 0.7
    @State private var maxTokens: Double = 200
    @State private var topP: Double = 0.9
    @State private var topK: Double = 40
    
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
                    
                    // LLM Settings
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Temperature: \(temperature, specifier: "%.1f")")
                                .font(.headline)
                            
                            Slider(value: $temperature, in: 0.1...1.5, step: 0.1)
                                .accentColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Max Tokens: \(Int(maxTokens))")
                                .font(.headline)
                            
                            Slider(value: $maxTokens, in: 50...500, step: 10)
                                .accentColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Top P: \(topP, specifier: "%.1f")")
                                .font(.headline)
                            
                            Slider(value: $topP, in: 0.1...1.0, step: 0.1)
                                .accentColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Top K: \(Int(topK))")
                                .font(.headline)
                            
                            Slider(value: $topK, in: 1...100, step: 1)
                                .accentColor(.blue)
                        }
                        .padding(.horizontal, 20)
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