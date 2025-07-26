//
//  SettingsView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var llmService: LLMService
    
    @State private var temperature: Float = 0.7
    @State private var topP: Float = 0.9
    @State private var mirostatTau: Float = 5.0
    
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
                    
                    // Model Status
                    VStack(spacing: 10) {
                        HStack {
                            Text("Model Status:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(llmService.isModelLoaded ? "✅ Loaded" : "⏳ Loading...")
                                .font(.subheadline)
                                .foregroundColor(llmService.isModelLoaded ? .green : .orange)
                        }
                        
                        if let errorMessage = llmService.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // LLM Settings
                    VStack(spacing: 15) {
                        Text("AI Model Settings")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Temperature: \(temperature, specifier: "%.1f")")
                                    .font(.subheadline)
                                Spacer()
                            }
                            Slider(value: $temperature, in: 0.1...2.0, step: 0.1)
                                .accentColor(.blue)
                            
                            HStack {
                                Text("Top-P: \(topP, specifier: "%.1f")")
                                    .font(.subheadline)
                                Spacer()
                            }
                            Slider(value: $topP, in: 0.1...1.0, step: 0.1)
                                .accentColor(.blue)
                            
                            HStack {
                                Text("Mirostat Tau: \(mirostatTau, specifier: "%.1f")")
                                    .font(.subheadline)
                                Spacer()
                            }
                            Slider(value: $mirostatTau, in: 1.0...10.0, step: 0.5)
                                .accentColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        Button("Apply Settings") {
                            llmService.updateModelSettings(
                                temperature: temperature,
                                topP: topP,
                                mirostatTau: mirostatTau
                            )
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                    
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