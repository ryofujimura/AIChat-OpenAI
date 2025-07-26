//
//  LaunchScreenView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct LaunchScreenView: View {
    let backgroundEmojis = ["✨", "⭐", "💫", "🌟", "💎", "🌸", "🌺", "🌼", "🌻", "🍀", "🌈", "🎈", "🎉", "🎊", "💖", "💕", "💗", "💓", "💝", "💘", "💞", "💟", "💌", "💋", "💍", "💎", "🎀", "🎁", "🎂", "🎄", "🎃", "🎆", "🎇", "🎈", "🎉", "🎊", "🎋", "🎍", "🎎", "🎏", "🎐", "🎑", "🎒", "🎓", "🎔", "🎕", "🎖", "🎗", "🎘", "🎙", "🎚", "🎛", "🎜", "🎝", "🎞", "🎟"]
    
    var body: some View {
        ZStack {
            // Background color
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Background emoji layer
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
            
            // Centered heart emoji
            Text("❤️")
                .font(.system(size: 120))
                .scaleEffect(1.0)
        }
    }
}
