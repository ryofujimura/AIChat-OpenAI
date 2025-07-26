//
//  EmojiBackgroundView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct EmojiBackgroundView: View {
    let backgroundEmojis = ["✨", "⭐", "💫", "🌟", "💎", "🌸", "🌺", "🌼", "🌻", "🍀", "🌈", "🎈", "🎉", "🎊", "💖", "💕", "💗", "💓", "💝", "💘", "💞", "💟", "💌", "💋", "💍", "💎", "🎀", "🎁", "🎂", "🎄", "🎃", "🎆", "🎇", "🎈", "🎉", "🎊", "🎋", "🎍", "🎎", "🎏", "🎐", "🎑", "🎒", "🎓", "🎔", "🎕", "🎖", "🎗", "🎘", "🎙", "🎚", "🎛", "🎜", "🎝", "🎞", "🎟"]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<20, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<15, id: \.self) { column in
                        Text(backgroundEmojis[(row * 15 + column) % backgroundEmojis.count])
                            .font(.system(size: 20))
                            .foregroundColor(.gray.opacity(0.1))
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .ignoresSafeArea()
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