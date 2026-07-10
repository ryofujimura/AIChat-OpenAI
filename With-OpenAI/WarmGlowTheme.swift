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
    static let overlay = Color.black.opacity(0.3)

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

// MARK: - Reusable Components

struct WarmGlowMessageCard<Content: View>: View {
    let isLoading: Bool
    @ViewBuilder let content: () -> Content

    @State private var pulseOpacity: Double = 1.0

    var body: some View {
        content()
            .font(.system(size: Fib.typeHero, weight: .regular))
            .foregroundStyle(WarmGlow.ink)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(Fib.s21)
            .warmGlowExtruded(radius: Fib.radiusHero, fill: WarmGlow.surface, blur: Fib.s13)
            .opacity(isLoading ? pulseOpacity : 1.0)
            .onChange(of: isLoading) { loading in
                if loading {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseOpacity = 0.55
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        pulseOpacity = 1.0
                    }
                }
            }
            .onAppear {
                if isLoading {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseOpacity = 0.55
                    }
                }
            }
    }
}

struct WarmGlowPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Fib.typeButton, weight: .semibold))
                .foregroundStyle(WarmGlow.surface)
                .frame(maxWidth: .infinity)
                .frame(height: Fib.s55)
        }
        .warmGlowExtruded(radius: Fib.radiusCard, fill: WarmGlow.accent, blur: Fib.s8)
    }
}

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
                    }
                }
                .frame(height: Fib.s8)
            }
            .padding(.horizontal, Fib.s21)
            .padding(.vertical, Fib.s13)
            .frame(maxWidth: .infinity)
            .frame(height: Fib.s55)
        }
        .warmGlowInset(radius: Fib.radiusCard)
    }
}

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
