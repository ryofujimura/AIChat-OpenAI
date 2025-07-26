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
                Spacer()
                
                // App title
                NeomorphicText("With")
                
                // Subtitle
                NeomorphicText("your cheering assistant", fontSize: .title3, fontWeight: .medium)
                
                Spacer()
                
                // Thinking emoji or placeholder text
                if showThinking {
                    Text("🤔")
                        .font(.system(size: 80))
                        .transition(.scale.combined(with: .opacity))
                } else if showPlaceholder {
                    NeomorphicText("placeholder", fontSize: .title2, fontWeight: .medium)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Neomorphic button
                NeomorphicButton(
                    title: "How am I doing?",
                    action: {
                        // Show thinking emoji
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showThinking = true
                            showPlaceholder = false
                        }
                        
                        // After 2 seconds, show placeholder text
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showThinking = false
                                showPlaceholder = true
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
                            // Show thinking emoji when input is submitted
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showThinking = true
                                showPlaceholder = false
                            }
                            
                            // After 2 seconds, show placeholder text
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showThinking = false
                                    showPlaceholder = true
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
                            // Trigger the same animation as button click
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInputBox = false
                                showThinking = true
                                showPlaceholder = false
                            }
                            
                            // Reset text field after submission
                            userInput = ""
                            
                            // After 2 seconds, show placeholder text
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showThinking = false
                                    showPlaceholder = true
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
    }
}
