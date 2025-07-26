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
    @State private var isReloading = false
    
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
                        
                        // Load model button
                        Button(action: {
                            isReloading = true
                            
                            // Reload the model
                            DispatchQueue.global(qos: .userInitiated).async {
                                aiService.loadModel()
                                DispatchQueue.main.async {
                                    isReloading = false
                                }
                            }
                        }) {
                            HStack(spacing: 10) {
                                if isReloading || aiService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.body)
                                }
                                
                                Text(isReloading || aiService.isLoading ? "Loading Model..." : "Load Model")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isReloading || aiService.isLoading ? Color.gray : Color.blue)
                            )
                        }
                        .disabled(isReloading || aiService.isLoading)
                        .padding(.horizontal, 40)
                        
                        // Loading progress
                        if isReloading || aiService.isLoading {
                            VStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .frame(height: 4)
                                
                                Text("Loading TinyLlama model...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        // Model info
                        VStack(spacing: 8) {
                            Text("Model: TinyLlama-1.1B-Chat-v1.0.Q4_K_M.gguf")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Size: ~0.7GB")
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

#Preview {
    SettingsView()
} 