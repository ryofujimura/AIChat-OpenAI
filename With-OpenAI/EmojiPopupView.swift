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

    @State private var cardOffset: CGFloat = 120
    @State private var cardScale: CGFloat = 0.5
    @State private var cardOpacity: Double = 0
    @State private var floatingWaveID = UUID()

    var body: some View {
        ZStack {
            ForEach(Array(emojis.enumerated()), id: \.offset) { index, emoji in
                FloatingEmojiParticle(emoji: emoji, delay: Double(index) * 0.06)
                    .id(floatingWaveID)
            }

            VStack(spacing: Fib.s21) {
                Text("✨ Emojis ✨")
                    .font(.system(size: Fib.typeButton, weight: .semibold))
                    .foregroundStyle(WarmGlow.accent)

                HStack(spacing: Fib.s13) {
                    ForEach(emojis.indices, id: \.self) { index in
                        Text(emojis[index])
                            .font(.system(size: Fib.typeHero))
                            .scaleEffect(cardScale)
                            .animation(
                                .spring(response: 0.55, dampingFraction: 0.62)
                                    .delay(Double(index) * 0.08),
                                value: cardScale
                            )
                    }
                }

            WarmGlowFlatButton(title: "Close") {
                dismissPopup()
            }
            }
            .padding(Fib.s34)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: Fib.radiusHero + Fib.s8)
                        .fill(
                            LinearGradient(
                                colors: [WarmGlow.housingRim, WarmGlow.housing],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: Fib.s13, x: 0, y: Fib.s8)

                    RoundedRectangle(cornerRadius: Fib.radiusHero)
                        .fill(WarmGlow.surface)
                        .padding(Fib.s8)
                }
            }
            .offset(y: cardOffset)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .onChange(of: isShowing) { newValue in
            if newValue {
                showPopup()
            }
        }
    }

    private func showPopup() {
        floatingWaveID = UUID()
        cardOffset = 120
        cardScale = 0.5
        cardOpacity = 0

        withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) {
            cardOffset = 0
            cardScale = 1.05
            cardOpacity = 1
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.15)) {
            cardScale = 1.0
        }
    }

    private func dismissPopup() {
        floatingWaveID = UUID()

        withAnimation(.easeIn(duration: 0.25)) {
            cardOffset = 80
            cardScale = 0.85
            cardOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

private struct FloatingEmojiParticle: View {
    let emoji: String
    let delay: Double

    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var xOffset: CGFloat = 0

    var body: some View {
        Text(emoji)
            .font(.system(size: Fib.typeHero))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                xOffset = CGFloat.random(in: -50...50)
                withAnimation(.easeOut(duration: 1.4).delay(delay)) {
                    yOffset = -200
                    opacity = 0
                }
            }
    }
}

struct TapEmojiBurst: Identifiable {
    let id: UUID
    let point: CGPoint
    let emojis: [String]
}

struct TapLocationEmojiBurstView: View {
    let burst: TapEmojiBurst

    var body: some View {
        ZStack {
            ForEach(Array(burst.emojis.enumerated()), id: \.offset) { index, emoji in
                TapBurstEmojiParticle(emoji: emoji, delay: Double(index) * 0.05)
            }
        }
        .position(burst.point)
        .allowsHitTesting(false)
    }
}

private struct TapBurstEmojiParticle: View {
    let emoji: String
    let delay: Double

    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var xOffset: CGFloat = 0
    @State private var scale: CGFloat = 0.5

    var body: some View {
        Text(emoji)
            .font(.system(size: Fib.typeHero))
            .scaleEffect(scale)
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                xOffset = CGFloat.random(in: -34...34)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.62).delay(delay)) {
                    scale = 1.0
                }
                withAnimation(.easeOut(duration: 1.2).delay(delay)) {
                    yOffset = -120
                    opacity = 0
                }
            }
    }
}

#Preview {
    ZStack {
        WarmGlow.base.ignoresSafeArea()
        EmojiPopupView(emojis: ["😊", "🌟", "💖"], isShowing: .constant(true))
    }
}
