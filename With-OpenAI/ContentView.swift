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
    @State private var showFirework = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
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
                    ZStack {
                        // Firework emojis
                        if showFirework {
                            // Emoji 1 - top right
                            Text("🎉")
                                .font(.system(size: 40))
                                .offset(x: showFirework ? 60 : 0, y: showFirework ? -40 : 0)
                                .opacity(showFirework ? 1 : 0)
                                .animation(.easeOut(duration: 0.8).delay(0.1), value: showFirework)
                            
                            // Emoji 2 - bottom left
                            Text("✨")
                                .font(.system(size: 40))
                                .offset(x: showFirework ? -50 : 0, y: showFirework ? 50 : 0)
                                .opacity(showFirework ? 1 : 0)
                                .animation(.easeOut(duration: 0.8).delay(0.2), value: showFirework)
                            
                            // Emoji 3 - top left
                            Text("🌟")
                                .font(.system(size: 40))
                                .offset(x: showFirework ? -60 : 0, y: showFirework ? -30 : 0)
                                .opacity(showFirework ? 1 : 0)
                                .animation(.easeOut(duration: 0.8).delay(0.3), value: showFirework)
                        }
                        
                        // Placeholder text
                        NeomorphicText("placeholder", fontSize: .title2, fontWeight: .medium)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Neomorphic button
                NeomorphicButton(title: "How am I doing?") {
                    // Show thinking emoji
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showThinking = true
                        showPlaceholder = false
                        showFirework = false
                    }
                    
                    // After 2 seconds, show placeholder text
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showThinking = false
                            showPlaceholder = true
                        }
                        
                        // Start firework animation after placeholder appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showFirework = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}
