//
//  SettingsView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var aiService = AIService()

    
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
                    
                    // Model loading section
                    VStack(spacing: 20) {
                        // Model status
                        VStack(spacing: 8) {
                            Text("AI Model Status")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(aiService.isModelLoaded ? Color.green : Color.red)
                                    .frame(width: 12, height: 12)
                                
                                Text(aiService.isModelLoaded ? "Model Loaded" : "Model Not Loaded")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // AI Service Status
                        VStack(spacing: 10) {
                            Text("AI Service is ready to chat!")
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                        

                        
                        // Model info
                        VStack(spacing: 8) {
                            Text("Model: llama")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Size: ~770MB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
