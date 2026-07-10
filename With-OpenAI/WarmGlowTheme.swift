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

// MARK: - Interactive Card (Tap + Response)

struct WarmGlowInteractiveCard: View {
    let isLoading: Bool
    let isCooldown: Bool
    let countdown: Int
    let totalDuration: Int
    let message: String?
    let onGenerate: () -> Void
    let onCooldownTap: () -> Void

    @State private var glowOpacity: Double = 0.35

    private var progress: CGFloat {
        guard totalDuration > 0, isCooldown else { return 0 }
        return CGFloat(totalDuration - countdown) / CGFloat(totalDuration)
    }

    private var showsMessage: Bool {
        guard let message, !message.isEmpty else { return false }
        return !isLoading
    }

    private var isTapHere: Bool {
        !isLoading && !showsMessage && !isCooldown
    }

    var body: some View {
        Button {
            if isCooldown {
                onCooldownTap()
            } else if !isLoading {
                onGenerate()
            }
        } label: {
            cardContent
        }
        .buttonStyle(WarmGlowShrinkButtonStyle(emphasis: isTapHere || isCooldown ? 1.0 : 0.95))
        .disabled(isLoading)
        .onChange(of: isLoading) { loading in
            if loading {
                startGlowPulse()
            } else {
                glowOpacity = 0.35
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Fib.radiusHero)
                .fill(isTapHere ? WarmGlow.accent : WarmGlow.surface)
                .shadow(color: WarmGlow.shadowLight, radius: Fib.s13, x: -4, y: -4)
                .shadow(color: WarmGlow.shadowDark, radius: Fib.s13, x: 4, y: 4)

            VStack(spacing: Fib.s13) {
                if isLoading {
                    skeletonContent
                } else if showsMessage {
                    Text(message ?? "")
                        .font(.system(size: Fib.typeHero, weight: .regular))
                        .foregroundStyle(WarmGlow.ink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Fib.s13)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        .id(message ?? "")
                } else if isTapHere {
                    VStack(spacing: Fib.s8) {
                        Text("👇")
                            .font(.system(size: Fib.s34))
                        Text("Tap Here")
                            .font(.system(size: Fib.typeButton, weight: .semibold))
                            .foregroundStyle(WarmGlow.surface)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    skeletonContent
                }

                if isCooldown {
                    cooldownProgress
                }
            }
            .padding(Fib.s21)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: Fib.s89)
        .overlay {
            if isLoading {
                RoundedRectangle(cornerRadius: Fib.radiusHero)
                    .stroke(WarmGlow.accent.opacity(glowOpacity), lineWidth: 2)
            }
        }
    }

    private var skeletonContent: some View {
        VStack(spacing: Fib.s13) {
            RoundedRectangle(cornerRadius: Fib.s8)
                .fill(WarmGlow.border)
                .frame(height: Fib.s13)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Fib.s13)

            RoundedRectangle(cornerRadius: Fib.s8)
                .fill(WarmGlow.border)
                .frame(width: Fib.s89, height: Fib.s13)
        }
        .opacity(glowOpacity + 0.45)
    }

    private var cooldownProgress: some View {
        VStack(spacing: Fib.s8) {
            Text("Wait \(countdown)s")
                .font(.system(size: Fib.typeCaption, weight: .semibold))
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
    }

    private func startGlowPulse() {
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            glowOpacity = 0.75
        }
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
