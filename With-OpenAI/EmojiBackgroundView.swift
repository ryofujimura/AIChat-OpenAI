//
//  EmojiBackgroundView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct EmojiBackgroundView: View {
    @State private var animationOffset: CGFloat = 0
    let backgroundEmojis = ["✨", "⭐", "💫", "🌟", "💎", "🌸", "🌺", "🌼", "🌻", "🍀", "🌈", "🎈", "🎉", "🎊", "💖", "💕", "💗", "💓", "💝", "💘", "💞", "💟", "💌", "💋", "💍", "💎", "🎀", "🎁", "🎂", "🎄", "🎃", "🎆", "🎇", "🎈", "🎉", "🎊", "🎋", "🎍", "🎎", "🎏", "🎐", "🎑", "🎒", "🎓", "🎔", "🎕", "🎖", "🎗", "🎘", "🎙", "🎚", "🎛", "🎜", "🎝", "🎞", "🎟"]
    
    var body: some View {
        ZStack {
            // Vertical lines background
            HStack(spacing: 40) {
                ForEach(0..<15, id: \.self) { index in
                    Rectangle()
                        .fill(Color.gray.opacity(0.03))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .ignoresSafeArea()
            
            // Weaving emojis - upward moving
            ForEach(0..<8, id: \.self) { index in
                WeavingEmoji(
                    emoji: backgroundEmojis[index % backgroundEmojis.count],
                    startX: CGFloat(index) * 60,
                    direction: .up,
                    animationOffset: animationOffset
                )
            }
            
            // Weaving emojis - downward moving
            ForEach(0..<8, id: \.self) { index in
                WeavingEmoji(
                    emoji: backgroundEmojis[(index + 8) % backgroundEmojis.count],
                    startX: CGFloat(index) * 60 + 30,
                    direction: .down,
                    animationOffset: animationOffset
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animationOffset = 1000
            }
        }
    }
}

struct WeavingEmoji: View {
    let emoji: String
    let startX: CGFloat
    let direction: WeaveDirection
    let animationOffset: CGFloat
    
    enum WeaveDirection {
        case up, down
    }
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 16))
            .foregroundColor(.gray.opacity(0.08))
            .offset(
                x: startX + sin(animationOffset * 0.01) * 20,
                y: direction == .up ? -animationOffset : animationOffset
            )
            .opacity(0.6)
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        EmojiBackgroundView()
        
        Text("Preview Content")
            .font(.title)
            .foregroundColor(.primary)
    }
} 