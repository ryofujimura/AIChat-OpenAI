//
//  ContentView.swift
//  With
//
//  Created by ryo fujimura on 2025/8/4.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var aiService = AIService()
    @State private var motivationalSentence = "Tap to get your daily motivation! ✨"
    @State private var emojiCluster = ["😊", "💪", "🌈"]
    @State private var isAnimating = false
    @State private var showFloatingHearts = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.88, blue: 0.91), // #ffe0e9
                        Color(red: 1.0, green: 0.97, blue: 0.88)  // #fff7e0
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating Hearts Animation
                if showFloatingHearts {
                    ForEach(0..<3, id: \.self) { index in
                        Text("💖")
                            .font(.title2)
                            .opacity(0.6)
                            .offset(
                                x: CGFloat.random(in: -geometry.size.width/2...geometry.size.width/2),
                                y: CGFloat.random(in: -geometry.size.height/2...geometry.size.height/2)
                            )
                            .animation(
                                Animation.easeInOut(duration: 3.0)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.5),
                                value: showFloatingHearts
                            )
                    }
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Header
                    HStack(spacing: 12) {
                        Text("😊")
                            .font(.system(size: 32))
                        
                        Text("With")
                            .font(.custom("Poppins-Bold", size: 28))
                            .foregroundColor(Color(red: 0.24, green: 0.17, blue: 0.18)) // #3d2c2e
                            .tracking(0.03)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Main Content Area
                    VStack(spacing: 30) {
                        // Emoji Cluster
                        HStack(spacing: 20) {
                            ForEach(emojiCluster.indices, id: \.self) { index in
                                Text(emojiCluster[index])
                                    .font(.system(size: 44))
                                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(index) * 0.2),
                                        value: isAnimating
                                    )
                                    .shadow(color: Color(red: 1.0, green: 0.82, blue: 0.4), radius: 8)
                            }
                        }
                        .onAppear {
                            isAnimating = true
                        }
                        
                        // Motivational Sentence
                        Text(motivationalSentence)
                            .font(.custom("Poppins-Bold", size: 20))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.69, blue: 0.62), // #ffb09e
                                        Color(red: 1.0, green: 0.82, blue: 0.4)   // #ffd166
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .tracking(0.01)
                            .padding(.horizontal, 20)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                    }
                    
                    Spacer()
                    
                    // Action Button
                    Button(action: generateMotivation) {
                        HStack(spacing: 12) {
                            Text("❤️")
                                .font(.title2)
                            
                            Text("Get Motivation")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            Text("➡️")
                                .font(.title2)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(red: 1.0, green: 0.44, blue: 0.38)) // #ff6f61
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.1), value: isAnimating)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            showFloatingHearts = true
        }
    }
    
    private func generateMotivation() {
        // Update emoji cluster with random motivational emojis
        let motivationalEmojis = ["😊", "💪", "🌈", "✨", "🌟", "💖", "🎯", "🚀", "⭐", "🎉", "💫", "🔥"]
        emojiCluster = (0..<3).map { _ in motivationalEmojis.randomElement() ?? "😊" }
        
        // Generate motivational content using AI
        Task {
            let newSentence = await aiService.generateMotivationalMessage()
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    motivationalSentence = newSentence
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
