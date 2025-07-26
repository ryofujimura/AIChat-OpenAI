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
    let onInputSubmit: (String) -> Void
    
    @State private var isPressed = false
    @State private var isDisabled = false
    @State private var clickCount = 0
    @State private var showInputBox = false
    @State private var userInput = ""
    
    var body: some View {
        Button(action: {
            // Handle clicks during disabled state
            if isDisabled {
                clickCount += 1
                
                // Show input box after 10 clicks
                if clickCount >= 10 && !showInputBox {
                    // Call the submit callback to trigger input box in parent view
                    onInputSubmit("")
                }
                return
            }
            
            // Prevent action if disabled
            guard !isDisabled else { return }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Disable button for 10 seconds
            isDisabled = true
            clickCount = 0 // Reset click count
            
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
            
            // Re-enable button after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDisabled = false
                    clickCount = 0 // Reset click count
                }
            }
        }) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(isDisabled ? .secondary : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    ZStack {
                        // Base layer
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isDisabled ? Color(.systemGray5) : Color(.systemGray6))
                        
                        // Top shadow (light) - reduced when disabled
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(isDisabled ? 0.3 : 0.8))
                            .blur(radius: 1)
                            .offset(x: -2, y: -2)
                        
                        // Bottom shadow (dark) - reduced when disabled
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(isDisabled ? 0.05 : 0.1))
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
        
        NeomorphicButton(
            title: "Start Chat",
            action: {
                print("Button tapped!")
            },
            onInputSubmit: { input in
                print("Input submitted: \(input)")
            }
        )
        .padding(.horizontal, 40)
    }
} 