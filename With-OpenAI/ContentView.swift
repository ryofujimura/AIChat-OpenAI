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
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackgroundView()
            
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
                NeomorphicButton(title: "How am I doing?") {
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
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}
