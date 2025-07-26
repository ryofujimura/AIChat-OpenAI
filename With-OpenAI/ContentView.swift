//
//  ContentView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ContentView: View {
    @State private var showThinking = false
    @State private var showPlaceholder = false
    @State private var showInputBox = false
    @State private var userInput = ""
    @State private var showSettings = false
    @State private var aiResponse = ""
    
    @StateObject private var llmService = LLMService()
    
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
                
                Spacer()
                
                // Thinking emoji or AI response
                if showThinking {
                    Text("🤔")
                        .font(.system(size: 80))
                        .transition(.scale.combined(with: .opacity))
                } else if showPlaceholder {
                    VStack(spacing: 10) {
                        if !aiResponse.isEmpty {
                            NeomorphicText(aiResponse, fontSize: .title3, fontWeight: .medium)
                                .transition(.scale.combined(with: .opacity))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        } else {
                            NeomorphicText("placeholder", fontSize: .title2, fontWeight: .medium)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                Spacer()
                
                // Neomorphic button
                NeomorphicButton(
                    title: "How am I doing?",
                    action: {
                        generateAIResponse(for: "How am I doing?")
                    },
                    onInputSubmit: { input in
                        if input.isEmpty {
                            // Show input box when triggered from button (10 clicks)
                            userInput = "" // Reset text field
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInputBox = true
                            }
                        } else {
                            // Generate AI response for custom input
                            generateAIResponse(for: input)
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
                            // Generate AI response for user input
                            generateAIResponse(for: userInput)
                            
                            // Reset text field after submission
                            userInput = ""
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
            SettingsView(llmService: llmService)
        }
    }
    
    private func generateAIResponse(for input: String) {
        // Show thinking emoji
        withAnimation(.easeInOut(duration: 0.3)) {
            showThinking = true
            showPlaceholder = false
            showInputBox = false
        }
        
        // Generate AI response
        llmService.generateResponse(for: input) { response in
            DispatchQueue.main.async {
                if let response = response {
                    self.aiResponse = response
                } else {
                    self.aiResponse = "Sorry, I couldn't generate a response right now."
                }
                
                // Show response with animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showThinking = false
                    self.showPlaceholder = true
                }
            }
        }
    }
}
