//
//  ContentView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var aiService = AIService()
    @State private var showThinking = false
    @State private var showPlaceholder = false
    @State private var showInputBox = false
    @State private var userInput = ""
    @State private var showSettings = false
    @State private var aiResponse = ""
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Full screen emoji burst animation (when placeholder is shown)
            if showPlaceholder {
                EmojiBurstView()
                    .ignoresSafeArea()
            }
            
            // Main content layer
            VStack(spacing: 30) {
                // Settings button in top right
                HStack {
                    Spacer()
                    Button(action: {
                        showSettings = true
                    }) {
                        Text("⚙️")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // App title
                NeomorphicText("With")
                
                // Subtitle
                NeomorphicText("your cheering assistant", fontSize: .title3, fontWeight: .medium)
                
                // Loading indicator
                if aiService.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading AI model...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
                
                // Thinking emoji or AI response
                if showThinking {
                    VStack(spacing: 15) {
                        Text("🤔")
                            .font(.system(size: 60))
                            .transition(.scale.combined(with: .opacity))
                        
                        if !aiService.currentResponse.isEmpty {
                            Text(aiService.currentResponse)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                        }
                    }
                } else if showPlaceholder {
                    VStack(spacing: 15) {
                        NeomorphicText(aiResponse.isEmpty ? "AI Response" : aiResponse, fontSize: .title2, fontWeight: .medium)
                            .transition(.scale.combined(with: .opacity))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        if !aiResponse.isEmpty {
                            EmojiBurstView()
                        }
                    }
                }
                
                Spacer()
                
                // Neomorphic button
                NeomorphicButton(
                    title: aiService.isLoading ? "Loading AI..." : "How am I doing?",
                    action: {
                        // Check if model is ready
                        guard aiService.isModelLoaded else {
                            // Show loading message if model isn't ready
                            aiResponse = "AI model is still loading... Please wait a moment and try again."
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showThinking = false
                                showPlaceholder = true
                            }
                            return
                        }
                        
                        // Reset response
                        aiService.resetResponse()
                        aiResponse = ""
                        
                        // Show thinking emoji
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showThinking = true
                            showPlaceholder = false
                        }
                        
                        // Generate AI response
                        aiService.generateResponse(to: "How am I doing? Please give me a brief, encouraging response.") { response in
                            DispatchQueue.main.async {
                                aiResponse = response
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showThinking = false
                                    showPlaceholder = true
                                }
                            }
                        }
                    },
                    onInputSubmit: { input in
                        if input.isEmpty {
                            // Show input box when triggered from button (10 clicks)
                            userInput = "" // Reset text field
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInputBox = true
                            }
                        } else {
                            // Check if model is ready
                            guard aiService.isModelLoaded else {
                                // Show loading message if model isn't ready
                                aiResponse = "AI model is still loading... Please wait a moment and try again."
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showThinking = false
                                    showPlaceholder = true
                                }
                                return
                            }
                            
                            // Reset response
                            aiService.resetResponse()
                            aiResponse = ""
                            
                            // Show thinking emoji when input is submitted
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showThinking = true
                                showPlaceholder = false
                            }
                            
                            // Generate AI response
                            aiService.generateResponse(to: input) { response in
                                DispatchQueue.main.async {
                                    aiResponse = response
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showThinking = false
                                        showPlaceholder = true
                                    }
                                }
                            }
                        }
                    }
                )
                .padding(.horizontal, 40)
                
                Spacer()
            }
            
            // Input box overlay - centered on screen
            if showInputBox {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 12) {
                    Text("💬 Tell me something!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    TextField("Type your message here...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .padding(.horizontal, 8)
                    
                    HStack(spacing: 12) {
                        Button("❌ Cancel") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInputBox = false
                                userInput = "" // Reset text field
                            }
                        }
                        .foregroundColor(.secondary)
                        .font(.body)
                        
                        Button("✨ Submit") {
                            // Check if model is ready
                            guard aiService.isModelLoaded else {
                                // Show loading message if model isn't ready
                                aiResponse = "AI model is still loading... Please wait a moment and try again."
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showInputBox = false
                                    showThinking = false
                                    showPlaceholder = true
                                }
                                return
                            }
                            
                            // Reset response
                            aiService.resetResponse()
                            aiResponse = ""
                            
                            // Trigger the same animation as button click
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInputBox = false
                                showThinking = true
                                showPlaceholder = false
                            }
                            
                            // Generate AI response with current input
                            let currentInput = userInput
                            
                            // Reset text field after submission
                            userInput = ""
                            
                            // Generate AI response
                            aiService.generateResponse(to: currentInput) { response in
                                DispatchQueue.main.async {
                                    aiResponse = response
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showThinking = false
                                        showPlaceholder = true
                                    }
                                }
                            }
                        }
                        .foregroundColor(.blue)
                        .font(.body)
                        .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
                )
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}
