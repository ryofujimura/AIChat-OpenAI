//
//  NeomorphicButton.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct NeomorphicButton: View {
    let title: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Button press animation
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            // Execute action
            action()
            
            // Reset button state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    ZStack {
                        // Base layer
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                        
                        // Top shadow (light)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .blur(radius: 1)
                            .offset(x: -2, y: -2)
                        
                        // Bottom shadow (dark)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.1))
                            .blur(radius: 1)
                            .offset(x: 2, y: 2)
                    }
                )
                .overlay(
                    // Pressed state overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.05))
                        .opacity(isPressed ? 1 : 0)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: isPressed ? Color.black.opacity(0.1) : Color.clear,
                    radius: isPressed ? 2 : 0,
                    x: 0,
                    y: isPressed ? 1 : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        NeomorphicButton(title: "Start Chat") {
            print("Button tapped!")
        }
        .padding(.horizontal, 40)
    }
} 