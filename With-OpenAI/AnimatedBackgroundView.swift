//
//  AnimatedBackgroundView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var animationOffset: CGFloat = 0
    
    let emojis = ["💖", "✨", "💫", "🌟", "💎", "🌸", "🌺", "🌼", "🌻", "🍀", "🌈", "🎈", "🎉", "🎊", "💕", "💗", "💝", "💞", "💟", "💌", "💋", "💍", "💎", "💐", "🌹", "🌷", "🌱", "🌲", "🌳", "🌴", "🌵", "🌾", "🌿", "☘️", "🍀", "🍁", "🍂", "🍃", "🍄", "🌰", "🦀", "🦞", "🦐", "🦑", "🦪", "🐚", "🐌", "🐛", "🐜", "🐝", "🐞", "🦋", "🦗", "🕷️", "🕸️", "🦂", "🦟", "🦠", "💐", "🌸", "💮", "🏵️", "🌹", "🥀", "🌺", "🌻", "🌼", "🌷", "🌱", "🌲", "🌳", "🌴", "🌵", "🌾", "🌿", "☘️", "🍀", "🍁", "🍂", "🍃", "🍄", "🌰", "🦀", "🦞", "🦐", "🦑", "🦪", "🐚", "🐌", "🐛", "🐜", "🐝", "🐞", "🦋", "🦗", "🕷️", "🕸️", "🦂", "🦟", "🦠"]
    
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
            
            // Dense emoji background
            ForEach(0..<100, id: \.self) { index in
                BackgroundEmoji(
                    emoji: emojis[index % emojis.count],
                    index: index,
                    animationOffset: animationOffset
                )
            }
            
            // Weaving emojis
            ForEach(0..<emojis.count, id: \.self) { index in
                WeavingEmoji(
                    emoji: emojis[index],
                    index: index,
                    animationOffset: animationOffset
                )
            }
            
            // White circle with fade for content visibility
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 100,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .blur(radius: 20)
        }
        .onAppear {
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                animationOffset = 1.0
            }
        }
    }
}

struct BackgroundEmoji: View {
    let emoji: String
    let index: Int
    let animationOffset: CGFloat
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 16))
            .offset(
                x: getXOffset(),
                y: getYOffset()
            )
            .opacity(0.3)
    }
    
    private func getXOffset() -> CGFloat {
        let baseX = CGFloat(index % 10) * 80 - 400
        let driftX = sin(animationOffset * .pi + Double(index) * 0.1) * 20
        return baseX + driftX
    }
    
    private func getYOffset() -> CGFloat {
        let baseY = CGFloat(index / 10) * 60 - 300
        let driftY = cos(animationOffset * .pi + Double(index) * 0.1) * 15
        return baseY + driftY
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