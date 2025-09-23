//
//  ContentView.swift
//  With
//
//  Created by ryo fujimura on 2025/8/4.
//

import SwiftUI

struct ContentView: View {
    @State private var currentEmojis = ["😊", "💪", "🌈"]
    @State private var motivationalText = "You've got this! Keep shining bright!"
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.88, blue: 0.91), Color(red: 1.0, green: 0.97, blue: 0.88)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating hearts animation
            FloatingHeartsView()
            
            VStack(spacing: 0) {
                // Header
                HeaderView()
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                
                Spacer()
                
                // Main content area
                VStack(spacing: 30) {
                    // Emoji cluster
                    EmojiClusterView(emojis: currentEmojis, isAnimating: $isAnimating)
                    
                    // Motivational sentence
                    MotivationalTextView(text: motivationalText)
                        .padding(.horizontal, 20)
                    
                    // Action button
                    ActionButtonView()
                        .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.8)) {
            isAnimating = true
        }
    }
}

// MARK: - Header Component
struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("😊")
                .font(.system(size: 32))
            
            Text("With")
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(Color(red: 0.24, green: 0.17, blue: 0.18))
                .tracking(0.5)
        }
    }
}

// MARK: - Emoji Cluster Component
struct EmojiClusterView: View {
    let emojis: [String]
    @Binding var isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(emojis.indices, id: \.self) { index in
                Text(emojis[index])
                    .font(.system(size: 48))
                    .scaleEffect(isAnimating ? 1.0 : 0.3)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)
                        .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
                    .shadow(color: Color(red: 1.0, green: 0.82, blue: 0.4), radius: 8, x: 0, y: 4)
                    .onAppear {
                        startPulseAnimation(for: index)
                    }
            }
        }
    }
    
    private func startPulseAnimation(for index: Int) {
        Timer.scheduledTimer(withTimeInterval: 2.0 + Double(index) * 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                // Pulse effect will be handled by scaleEffect
            }
        }
    }
}

// MARK: - Motivational Text Component
struct MotivationalTextView: View {
    let text: String
    @State private var isVisible = false
    
    var body: some View {
        Text(text)
            .font(.custom("Poppins-Bold", size: 22))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.69, blue: 0.62), Color(red: 1.0, green: 0.82, blue: 0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .tracking(0.2)
            .multilineTextAlignment(.center)
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.5), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

// MARK: - Action Button Component
struct ActionButtonView: View {
    @State private var isPressed = false
    @State private var rippleEffect = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                rippleEffect = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                rippleEffect = false
            }
        }) {
            HStack(spacing: 12) {
                Text("❤️")
                    .font(.system(size: 20))
                
                Text("Start Your Journey")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundColor(.white)
                
                Text("➡️")
                    .font(.system(size: 16))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 1.0, green: 0.44, blue: 0.38))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .scaleEffect(rippleEffect ? 3.0 : 0.0)
                    .opacity(rippleEffect ? 0.0 : 1.0)
                    .animation(.easeOut(duration: 0.6), value: rippleEffect)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Floating Hearts Animation
struct FloatingHeartsView: View {
    @State private var hearts: [FloatingHeart] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(hearts.indices, id: \.self) { index in
                    Text(hearts[index].emoji)
                        .font(.system(size: hearts[index].size))
                        .opacity(hearts[index].opacity)
                        .position(hearts[index].position)
                        .animation(.linear(duration: hearts[index].duration), value: hearts[index].position)
                }
            }
            .onAppear {
                startFloatingAnimation(geometry: geometry)
            }
        }
    }
    
    private func startFloatingAnimation(geometry: GeometryProxy) {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            createNewHeart(geometry: geometry)
        }
        
        // Create initial hearts
        for _ in 0..<3 {
            createNewHeart(geometry: geometry)
        }
    }
    
    private func createNewHeart(geometry: GeometryProxy) {
        let heart = FloatingHeart(
            emoji: ["💖", "✨", "🌟", "💫"].randomElement() ?? "💖",
            size: CGFloat.random(in: 16...24),
            opacity: Double.random(in: 0.3...0.7),
            position: CGPoint(
                x: CGFloat.random(in: 50...geometry.size.width - 50),
                y: geometry.size.height + 50
            ),
            duration: Double.random(in: 4.0...6.0)
        )
        
        hearts.append(heart)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + heart.duration) {
            hearts.removeAll { $0.id == heart.id }
        }
        
        withAnimation(.linear(duration: heart.duration)) {
            if let index = hearts.firstIndex(where: { $0.id == heart.id }) {
                hearts[index].position.y = -50
            }
        }
    }
}

struct FloatingHeart {
    let id = UUID()
    let emoji: String
    let size: CGFloat
    let opacity: Double
    var position: CGPoint
    let duration: Double
}

#Preview {
    ContentView()
}
