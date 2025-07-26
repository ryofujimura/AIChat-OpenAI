//
//  EmojiBurstView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct EmojiBurstView: View {
    @State private var isAnimating = false
    
    let emojis = ["✨", "⭐", "💫", "🌟", "💥", "🔥", "🎉", "🎊", "💎", "🌸", "🌺", "🌼", "🌻", "🍀", "🌈", "🎈"]
    let lightShapes = ["○", "●", "◐", "◑", "◒", "◓", "◔", "◕", "◎", "◉", "◊", "◆", "◇", "◈", "◉", "◊"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Emoji burst
                ForEach(0..<emojis.count, id: \.self) { index in
                    EmojiParticle(
                        emoji: emojis[index],
                        angle: Double(index) * (360.0 / Double(emojis.count)),
                        isAnimating: isAnimating,
                        screenSize: geometry.size
                    )
                }
                
                // Light shapes burst
                ForEach(0..<lightShapes.count, id: \.self) { index in
                    LightShapeParticle(
                        shape: lightShapes[index],
                        angle: Double(index) * (360.0 / Double(lightShapes.count)) + 11.25, // Offset by half
                        isAnimating: isAnimating,
                        screenSize: geometry.size
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                isAnimating = true
            }
        }
    }
}

struct EmojiParticle: View {
    let emoji: String
    let angle: Double
    let isAnimating: Bool
    let screenSize: CGSize
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 24))
            .offset(
                x: isAnimating ? cos(angle * .pi / 180) * max(screenSize.width, screenSize.height) * 0.6 : 0,
                y: isAnimating ? sin(angle * .pi / 180) * max(screenSize.width, screenSize.height) * 0.6 : 0
            )
            .opacity(isAnimating ? 0 : 1)
            .scaleEffect(isAnimating ? 0.3 : 1.0)
            .animation(
                .easeOut(duration: 1.5)
                .delay(Double.random(in: 0...0.3)),
                value: isAnimating
            )
    }
}

struct LightShapeParticle: View {
    let shape: String
    let angle: Double
    let isAnimating: Bool
    let screenSize: CGSize
    
    var body: some View {
        Text(shape)
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
            .offset(
                x: isAnimating ? cos(angle * .pi / 180) * max(screenSize.width, screenSize.height) * 0.45 : 0,
                y: isAnimating ? sin(angle * .pi / 180) * max(screenSize.width, screenSize.height) * 0.45 : 0
            )
            .opacity(isAnimating ? 0 : 0.8)
            .scaleEffect(isAnimating ? 0.1 : 0.8)
            .animation(
                .easeOut(duration: 2.0)
                .delay(Double.random(in: 0.5...0.8)),
                value: isAnimating
            )
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        EmojiBurstView()
    }
} 
