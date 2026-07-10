//
//  WarmGlowTheme.swift
//  With-OpenAI
//

import SwiftUI

// MARK: - Color System

enum WarmGlow {
    static let base = Color(red: 0.961, green: 0.941, blue: 0.922)       // #F5F0EB
    static let accent = Color(red: 0.910, green: 0.584, blue: 0.435)     // #E8956F
    static let ink = Color(red: 0.102, green: 0.102, blue: 0.102)         // #1A1A1A
    static let surface = Color.white                                         // #FFFFFF

    static let secondary = ink.opacity(0.4)
    static let border = ink.opacity(0.15)

    static let shadowLight = Color.white.opacity(0.8)
    static let shadowDark = Color.black.opacity(0.08)
}

// MARK: - Fibonacci Scale

enum Fib {
    static let s8: CGFloat = 8
    static let s13: CGFloat = 13
    static let s21: CGFloat = 21
    static let s34: CGFloat = 34
    static let s55: CGFloat = 55
    static let s89: CGFloat = 89

    static let radiusField: CGFloat = s13
    static let radiusCard: CGFloat = s21
    static let radiusHero: CGFloat = s34

    static let typeCaption: CGFloat = s13
    static let typeButton: CGFloat = s21
    static let typeHero: CGFloat = s34
}

// MARK: - Neumorphism

extension View {
    func warmGlowExtruded(
        radius: CGFloat,
        fill: Color = WarmGlow.surface,
        blur: CGFloat = Fib.s8
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius)
                .fill(fill)
                .shadow(color: WarmGlow.shadowLight, radius: blur, x: -4, y: -4)
                .shadow(color: WarmGlow.shadowDark, radius: blur, x: 4, y: 4)
        )
    }

    func warmGlowInset(radius: CGFloat, fill: Color = WarmGlow.base) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(WarmGlow.border, lineWidth: 1)
                )
                .shadow(color: WarmGlow.shadowDark, radius: Fib.s8, x: -4, y: -4)
                .shadow(color: WarmGlow.shadowLight, radius: Fib.s8, x: 4, y: 4)
        )
    }
}

// MARK: - Button Styles

struct WarmGlowShrinkButtonStyle: ButtonStyle {
    var emphasis: Double = 1.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(emphasis)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Message Card

struct WarmGlowMessageCard: View {
    let isLoading: Bool
    let message: String

    @State private var glowOpacity: Double = 0.35

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Fib.radiusHero)
                .fill(WarmGlow.surface)
                .shadow(color: WarmGlow.shadowLight, radius: Fib.s13, x: -4, y: -4)
                .shadow(color: WarmGlow.shadowDark, radius: Fib.s13, x: 4, y: 4)

            if isLoading {
                skeletonContent
            } else {
                Text(message)
                    .font(.system(size: Fib.typeHero, weight: .regular))
                    .foregroundStyle(WarmGlow.ink)
                    .multilineTextAlignment(.center)
                    .padding(Fib.s21)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .id(message)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: Fib.s89)
        .overlay {
            if isLoading {
                RoundedRectangle(cornerRadius: Fib.radiusHero)
                    .stroke(WarmGlow.accent.opacity(glowOpacity), lineWidth: 2)
            }
        }
        .onChange(of: isLoading) { loading in
            if loading {
                startGlowPulse()
            } else {
                glowOpacity = 0.35
            }
        }
        .onAppear {
            if isLoading {
                startGlowPulse()
            }
        }
    }

    private var skeletonContent: some View {
        VStack(spacing: Fib.s13) {
            RoundedRectangle(cornerRadius: Fib.s8)
                .fill(WarmGlow.border)
                .frame(height: Fib.s13)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Fib.s34)

            RoundedRectangle(cornerRadius: Fib.s8)
                .fill(WarmGlow.border)
                .frame(width: Fib.s89, height: Fib.s13)
        }
        .padding(Fib.s21)
        .opacity(glowOpacity + 0.45)
    }

    private func startGlowPulse() {
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            glowOpacity = 0.75
        }
    }
}

// MARK: - Tap Button

struct WarmGlowTapButton: View {
    let isDeemphasized: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Fib.s8) {
                Text("👇")
                    .font(.system(size: Fib.s34))

                Text("Tap Here")
                    .font(.system(size: Fib.typeButton, weight: .semibold))
                    .foregroundStyle(WarmGlow.surface)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Fib.s89)
        }
        .buttonStyle(WarmGlowShrinkButtonStyle(emphasis: isDeemphasized ? 0.45 : 1.0))
        .warmGlowExtruded(radius: Fib.radiusCard, fill: WarmGlow.accent, blur: Fib.s8)
        .disabled(isDeemphasized)
    }
}

// MARK: - Cooldown Button

struct WarmGlowCooldownButton: View {
    let countdown: Int
    let totalDuration: Int
    let action: () -> Void

    private var progress: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return CGFloat(totalDuration - countdown) / CGFloat(totalDuration)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Fib.s8) {
                Text("👇")
                    .font(.system(size: Fib.typeButton))
                    .opacity(0.35)

                Text("Wait \(countdown)s")
                    .font(.system(size: Fib.typeButton, weight: .semibold))
                    .foregroundStyle(WarmGlow.ink)

                Text("Tap to unlock surprise")
                    .font(.system(size: Fib.typeCaption))
                    .foregroundStyle(WarmGlow.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(WarmGlow.border)

                        Capsule()
                            .fill(WarmGlow.accent)
                            .frame(width: geometry.size.width * progress)
                            .animation(.linear(duration: 1), value: progress)
                    }
                }
                .frame(height: Fib.s8)
            }
            .padding(.horizontal, Fib.s21)
            .padding(.vertical, Fib.s13)
            .frame(maxWidth: .infinity)
            .frame(height: Fib.s89)
        }
        .buttonStyle(WarmGlowShrinkButtonStyle(emphasis: 0.85))
        .warmGlowInset(radius: Fib.radiusCard)
    }
}

// MARK: - Easter Egg

struct WarmGlowFlatButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Fib.typeButton, weight: .semibold))
                .foregroundStyle(WarmGlow.surface)
                .frame(maxWidth: .infinity)
                .frame(height: Fib.s55)
                .background(
                    RoundedRectangle(cornerRadius: Fib.radiusCard)
                        .fill(WarmGlow.accent)
                )
        }
        .buttonStyle(WarmGlowShrinkButtonStyle())
    }
}

struct WarmGlowInsetField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: Fib.typeCaption))
            .foregroundStyle(WarmGlow.ink)
            .padding(Fib.s13)
            .warmGlowInset(radius: Fib.radiusField)
    }
}
