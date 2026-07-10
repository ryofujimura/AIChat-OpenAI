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
            if isShowing {
                WarmGlow.overlay
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissPopup()
                    }
            }

            VStack(spacing: Fib.s21) {
                Text("✨ Emojis ✨")
                    .font(.system(size: Fib.typeButton, weight: .semibold))
                    .foregroundStyle(WarmGlow.accent)

                HStack(spacing: Fib.s13) {
                    ForEach(emojis.indices, id: \.self) { index in
                        Text(emojis[index])
                            .font(.system(size: Fib.typeHero))
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
                .font(.system(size: Fib.typeCaption, weight: .semibold))
                .foregroundStyle(WarmGlow.surface)
                .padding(.horizontal, Fib.s34)
                .padding(.vertical, Fib.s13)
                .background(
                    Capsule()
                        .fill(WarmGlow.accent)
                )
            }
            .padding(Fib.s34)
            .background(
                RoundedRectangle(cornerRadius: Fib.radiusHero)
                    .fill(WarmGlow.surface)
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
    ZStack {
        WarmGlow.base.ignoresSafeArea()
        EmojiPopupView(emojis: ["😊", "🌟", "💖"], isShowing: .constant(true))
    }
}
