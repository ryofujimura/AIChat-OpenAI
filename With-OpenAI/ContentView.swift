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
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 15) {
                    Text("Please provide input:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your message...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        Button("Cancel") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInputBox = false
                                userInput = ""
                            }
                        }
                        .foregroundColor(.secondary)
                        
                        Button("Submit") {
                            // Trigger the same animation as button click
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInputBox = false
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
                        .foregroundColor(.blue)
                        .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
