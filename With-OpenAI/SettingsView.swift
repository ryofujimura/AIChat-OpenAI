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
                            
                            // Reload the model with updated prompt
                            DispatchQueue.global(qos: .userInitiated).async {
                                aiService.reloadModel()
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
                                
                                Text(isReloading || aiService.isLoading ? "Loading Model..." : "Reload Model")
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
                            VStack(spacing: 12) {
                                // Cute loading animation
                                ZStack {
                                    // Outer ring
                                    Circle()
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 3)
                                        .frame(width: 40, height: 40)
                                    
                                    // Animated ring
                                    Circle()
                                        .trim(from: 0, to: 0.7)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.blue, .purple, .pink]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                        )
                                        .frame(width: 40, height: 40)
                                        .rotationEffect(.degrees(isReloading || aiService.isLoading ? 360 : 0))
                                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isReloading || aiService.isLoading)
                                    
                                    // Center emoji
                                    Text("🤖")
                                        .font(.body)
                                        .scaleEffect(isReloading || aiService.isLoading ? 1.1 : 1.0)
                                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isReloading || aiService.isLoading)
                                }
                                
                                Text("Loading Llama 3.2 Instruct model... ✨")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        // Model info
                        VStack(spacing: 8) {
                            Text("Model: Llama_3.2_Instruct_Q4_K_M.gguf")
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

#Preview {
    SettingsView()
} 