//
//  ContentView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bot = Bot()
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
                if bot.isGenerating {
                    VStack(spacing: 15) {
                        // Cute loading animation
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)
                            
                            // Animated ring
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple, .pink]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(bot.isGenerating ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: bot.isGenerating)
                            
                            // Center emoji
                            Text("🤖")
                                .font(.title2)
                                .scaleEffect(bot.isGenerating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: bot.isGenerating)
                        }
                        
                        // Loading text with emojis
                        VStack(spacing: 5) {
                            Text("AI is thinking...")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("✨ Generating your response ✨")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Response display
                if !aiResponse.isEmpty {
                    VStack(spacing: 15) {
                        Text(aiResponse)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .transition(.scale.combined(with: .opacity))
                        
                        // Stop button
                        Button(action: {
                            bot.stop()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showThinking = false
                                showPlaceholder = true
                            }
                        }) {
                            Text("🛑 Stop")
                                .font(.body)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                        .opacity(bot.isGenerating ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: bot.isGenerating)
                    }
                }
                
                // Main action button
                NeomorphicButton(
                    title: "💬 Chat with me!",
                    action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showInputBox = true
                        }
                    },
                    onInputSubmit: { input in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showInputBox = true
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
                            // Reset response
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
                            
                            // Generate AI response using async/await
                            Task {
                                await bot.respond(to: currentInput)
                                
                                await MainActor.run {
                                    aiResponse = bot.output
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
