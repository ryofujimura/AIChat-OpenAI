//
//  AnimatedBackgroundView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var animationOffset: CGFloat = 0
    
    let emojis = ["💖", "✨", "💫", "🌟", "💎", "🌸", "🌺", "🌼", "🌻", "🍀", "🌈", "🎈", "🎉", "🎊", "💕", "💗"]
    
    var body: some View {
        ZStack {
            // Background color with light opacity
            Color(.systemBackground)
                .opacity(0.3)
                .ignoresSafeArea()
            
            // Vertical lines
            HStack(spacing: 60) {
                ForEach(0..<8, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            
            // Weaving emojis
            ForEach(0..<emojis.count, id: \.self) { index in
                WeavingEmoji(
                    emoji: emojis[index],
                    index: index,
                    animationOffset: animationOffset
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                animationOffset = 1.0
            }
        }
    }
}

struct WeavingEmoji: View {
    let emoji: String
    let index: Int
    let animationOffset: CGFloat
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 20))
            .offset(
                x: getXOffset(),
                y: getYOffset()
            )
            .opacity(0.7)
    }
    
    private func getXOffset() -> CGFloat {
        let baseX = CGFloat(index % 4) * 100 - 150
        let zigzagX = sin(animationOffset * .pi * 2 + Double(index)) * 30
        return baseX + zigzagX
    }
    
    private func getYOffset() -> CGFloat {
        let direction = index % 2 == 0 ? 1.0 : -1.0
        let baseY = direction * (animationOffset * 800 - 400)
        let zigzagY = cos(animationOffset * .pi * 4 + Double(index)) * 20
        return baseY + zigzagY
    }
}

#Preview {
    AnimatedBackgroundView()
} 