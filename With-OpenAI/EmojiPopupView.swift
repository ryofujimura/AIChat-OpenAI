//
//  EmojiPopupView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct EmojiPopupView: View {
    let emojis: [String]
    @Binding var isShowing: Bool
    
    @State private var animationOffset: CGFloat = 100
    @State private var animationScale: CGFloat = 0.5
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissPopup()
                    }
            }
            
            // Emoji popup
            VStack(spacing: 20) {
                Text("✨ Emojis ✨")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 15) {
                    ForEach(emojis.indices, id: \.self) { index in
                        Text(emojis[index])
                            .font(.system(size: 40))
                            .scaleEffect(animationScale)
                            .opacity(animationOpacity)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                                value: animationScale
                            )
                    }
                }
                
                Button("Close") {
                    dismissPopup()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 120, height: 40)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
            .offset(y: animationOffset)
            .scaleEffect(animationScale)
            .opacity(animationOpacity)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationOffset)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationScale)
            .animation(.easeInOut(duration: 0.3), value: animationOpacity)
        }
        .onChange(of: isShowing) { newValue in
            if newValue {
                showPopup()
            }
        }
    }
    
    private func showPopup() {
        animationOffset = 0
        animationScale = 1.0
        animationOpacity = 1.0
    }
    
    private func dismissPopup() {
        animationOffset = 100
        animationScale = 0.5
        animationOpacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

#Preview {
    EmojiPopupView(emojis: ["😊", "🌟", "💖"], isShowing: .constant(true))
} 