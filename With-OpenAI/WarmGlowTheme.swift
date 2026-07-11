//
//  WarmGlowTheme.swift
//  With-OpenAI
//

import SwiftUI

// MARK: - Legacy Accessors (default palette)

enum WarmGlow {
    static var base: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.base }
    static var accent: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.accent }
    static var ink: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.ink }
    static var surface: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.surface }
    static var secondary: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.secondary }
    static var border: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.border }
    static var overlay: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.overlay }
    static var shadowLight: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.shadowLight }
    static var shadowDark: Color { ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette.shadowDark }
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
        palette: ThemePalette,
        radius: CGFloat,
        fill: Color? = nil,
        blur: CGFloat = Fib.s8
    ) -> some View {
        let fillColor = fill ?? palette.surface
        return background(
            RoundedRectangle(cornerRadius: radius)
                .fill(fillColor)
                .shadow(color: palette.shadowLight, radius: blur, x: -4, y: -4)
                .shadow(color: palette.shadowDark, radius: blur, x: 4, y: 4)
        )
    }

    func warmGlowInset(palette: ThemePalette, radius: CGFloat, fill: Color? = nil) -> some View {
        let fillColor = fill ?? palette.base
        return background(
            RoundedRectangle(cornerRadius: radius)
                .fill(fillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(palette.border, lineWidth: 1)
                )
                .shadow(color: palette.shadowDark, radius: Fib.s8, x: -4, y: -4)
                .shadow(color: palette.shadowLight, radius: Fib.s8, x: 4, y: 4)
        )
    }
}

// MARK: - Reusable Components

struct WarmGlowMessageCard<Content: View>: View {
    @Environment(\.themePalette) private var palette

    let isLoading: Bool
    @ViewBuilder let content: () -> Content

    @State private var pulseOpacity: Double = 1.0

    var body: some View {
        content()
            .font(.system(size: Fib.typeHero, weight: .regular))
            .foregroundStyle(palette.ink)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(Fib.s21)
            .warmGlowExtruded(palette: palette, radius: Fib.radiusHero, fill: palette.surface, blur: Fib.s13)
            .opacity(isLoading ? pulseOpacity : 1.0)
            .onChange(of: isLoading) { _, loading in
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
    @Environment(\.themePalette) private var palette

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Fib.typeButton, weight: .semibold))
                .foregroundStyle(palette.surface)
                .frame(maxWidth: .infinity)
                .frame(height: Fib.s55)
        }
        .warmGlowExtruded(palette: palette, radius: Fib.radiusCard, fill: palette.accent, blur: Fib.s8)
    }
}

struct WarmGlowCooldownButton: View {
    @Environment(\.themePalette) private var palette

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
                    .foregroundStyle(palette.ink)

                Text("Tap to unlock surprise")
                    .font(.system(size: Fib.typeCaption))
                    .foregroundStyle(palette.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(palette.border)

                        Capsule()
                            .fill(palette.accent)
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
        .warmGlowInset(palette: palette, radius: Fib.radiusCard)
    }
}

struct WarmGlowFlatButton: View {
    @Environment(\.themePalette) private var palette

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Fib.typeButton, weight: .semibold))
                .foregroundStyle(palette.surface)
                .frame(maxWidth: .infinity)
                .frame(height: Fib.s55)
                .background(
                    RoundedRectangle(cornerRadius: Fib.radiusCard)
                        .fill(palette.accent)
                )
        }
    }
}

struct WarmGlowInsetField: View {
    @Environment(\.themePalette) private var palette

    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: Fib.typeCaption))
            .foregroundStyle(palette.ink)
            .padding(Fib.s13)
            .warmGlowInset(palette: palette, radius: Fib.radiusField)
    }
}
