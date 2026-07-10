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

    // Arcade 3D tones
    static let housing = Color(red: 0.18, green: 0.17, blue: 0.16)
    static let housingRim = Color(red: 0.28, green: 0.26, blue: 0.24)
    static let accentHighlight = Color(red: 0.98, green: 0.74, blue: 0.58)
    static let accentShadow = Color(red: 0.72, green: 0.40, blue: 0.26)
    static let surfaceHighlight = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let surfaceShadow = Color(red: 0.88, green: 0.86, blue: 0.84)
}

// MARK: - Fibonacci Scale

enum Fib {
    static let s5: CGFloat = 5
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

// MARK: - Arcade 3D Button

struct ArcadeFace<Content: View>: View {
    let faceColor: Color
    let highlightColor: Color
    let shadowColor: Color
    let isPressed: Bool
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content

    private var pressDepth: CGFloat { isPressed ? Fib.s8 : 0 }

    var body: some View {
        ZStack {
            // Ground shadow stays fixed while the button depresses into it
            RoundedRectangle(cornerRadius: cornerRadius + Fib.s8)
                .fill(Color.black.opacity(isPressed ? 0.18 : 0.28))
                .padding(.horizontal, Fib.s13)
                .frame(maxWidth: .infinity)
                .frame(height: Fib.s8)
                .offset(y: Fib.s21 + pressDepth)
                .blur(radius: Fib.s5)
                .animation(.spring(response: 0.22, dampingFraction: 0.62), value: isPressed)

            // Housing + plunger + label move together as one physical button
            buttonAssembly
                .offset(y: pressDepth)
                .animation(.spring(response: 0.22, dampingFraction: 0.62), value: isPressed)
        }
    }

    private var buttonAssembly: some View {
        ZStack {
            // Housing base
            RoundedRectangle(cornerRadius: cornerRadius + Fib.s8)
                .fill(
                    LinearGradient(
                        colors: [WarmGlow.housingRim, WarmGlow.housing],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(
                    color: Color.black.opacity(isPressed ? 0.3 : 0.45),
                    radius: isPressed ? Fib.s8 : Fib.s13,
                    x: 0,
                    y: isPressed ? Fib.s5 : Fib.s13
                )

            // Inner well
            RoundedRectangle(cornerRadius: cornerRadius + Fib.s5)
                .fill(WarmGlow.housing)
                .padding(Fib.s5)

            // Plunger face
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [highlightColor, faceColor, shadowColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        .padding(1)
                        .blendMode(.overlay)
                }
                .overlay(alignment: .top) {
                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), Color.white.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: cornerRadius)
                        .padding(.horizontal, Fib.s21)
                        .padding(.top, Fib.s8)
                }
                .padding(Fib.s8)

            content()
                .padding(Fib.s21)
        }
    }
}

struct ArcadeButtonStyle: ButtonStyle {
    let faceColor: Color
    let highlightColor: Color
    let shadowColor: Color
    var cornerRadius: CGFloat = Fib.radiusCard
    var emphasis: Double = 1.0

    func makeBody(configuration: Configuration) -> some View {
        ArcadeFace(
            faceColor: faceColor,
            highlightColor: highlightColor,
            shadowColor: shadowColor,
            isPressed: configuration.isPressed,
            cornerRadius: cornerRadius
        ) {
            configuration.label
                .opacity(emphasis)
        }
    }
}

struct ArcadeAccentButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = Fib.radiusCard

    func makeBody(configuration: Configuration) -> some View {
        ArcadeButtonStyle(
            faceColor: WarmGlow.accent,
            highlightColor: WarmGlow.accentHighlight,
            shadowColor: WarmGlow.accentShadow,
            cornerRadius: cornerRadius
        ).makeBody(configuration: configuration)
    }
}

struct ArcadeSurfaceButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = Fib.radiusHero

    func makeBody(configuration: Configuration) -> some View {
        ArcadeButtonStyle(
            faceColor: WarmGlow.surface,
            highlightColor: WarmGlow.surfaceHighlight,
            shadowColor: WarmGlow.surfaceShadow,
            cornerRadius: cornerRadius
        ).makeBody(configuration: configuration)
    }
}

// MARK: - Interactive Card (Tap + Response)

struct WarmGlowInteractiveCard: View {
    let isLoading: Bool
    let isCooldown: Bool
    let message: String?
    let onGenerate: () -> Void
    let onCooldownTap: () -> Void
    let onMessageTapAt: (CGPoint) -> Void

    @State private var glowOpacity: Double = 0.35

    init(
        isLoading: Bool,
        isCooldown: Bool,
        message: String?,
        onGenerate: @escaping () -> Void,
        onCooldownTap: @escaping () -> Void,
        onMessageTapAt: @escaping (CGPoint) -> Void = { _ in }
    ) {
        self.isLoading = isLoading
        self.isCooldown = isCooldown
        self.message = message
        self.onGenerate = onGenerate
        self.onCooldownTap = onCooldownTap
        self.onMessageTapAt = onMessageTapAt
    }

    private var showsMessage: Bool {
        guard let message, !message.isEmpty else { return false }
        return !isLoading
    }

    private var isTapHere: Bool {
        !isLoading && !showsMessage && !isCooldown
    }

    private var faceStyle: (Color, Color, Color) {
        if isTapHere {
            return (WarmGlow.accent, WarmGlow.accentHighlight, WarmGlow.accentShadow)
        }
        return (WarmGlow.surface, WarmGlow.surfaceHighlight, WarmGlow.surfaceShadow)
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
        .buttonStyle(
            ArcadeButtonStyle(
                faceColor: faceStyle.0,
                highlightColor: faceStyle.1,
                shadowColor: faceStyle.2,
                cornerRadius: Fib.radiusHero,
                emphasis: isTapHere || isCooldown ? 1.0 : 0.95
            )
        )
        .disabled(isLoading)
        .simultaneousGesture(messageTapGesture)
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
        VStack(spacing: Fib.s13) {
            if isLoading {
                skeletonContent
            } else if showsMessage {
                Text(message ?? "")
                    .font(.system(size: Fib.typeHero, weight: .semibold))
                    .foregroundStyle(WarmGlow.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Fib.s13)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .id(message ?? "")
            } else if isTapHere {
                VStack(spacing: Fib.s8) {
                    Text("👇")
                        .font(.system(size: Fib.s34))
                        .shadow(color: Color.black.opacity(0.2), radius: 0, x: 0, y: 2)

                    Text("Tap Here")
                        .font(.system(size: Fib.typeButton, weight: .bold))
                        .foregroundStyle(WarmGlow.surface)
                        .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 2)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                skeletonContent
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: Fib.s89)
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

    private var messageTapGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onEnded { value in
                guard showsMessage else { return }
                onMessageTapAt(value.location)
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
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Fib.typeButton, weight: .bold))
                .foregroundStyle(WarmGlow.surface)
                .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 2)
                .frame(maxWidth: .infinity)
                .frame(height: Fib.s55)
        }
        .buttonStyle(ArcadeAccentButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.45)
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
            .background(
                RoundedRectangle(cornerRadius: Fib.radiusField)
                    .fill(WarmGlow.housing.opacity(0.08))
                    .overlay {
                        RoundedRectangle(cornerRadius: Fib.radiusField)
                            .stroke(WarmGlow.housingRim.opacity(0.5), lineWidth: 2)
                    }
            )
    }
}

struct ArcadePanel<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(Fib.s21)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius + Fib.s8)
                        .fill(
                            LinearGradient(
                                colors: [WarmGlow.housingRim, WarmGlow.housing],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: Fib.s13, x: 0, y: Fib.s8)

                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(WarmGlow.surface)
                        .padding(Fib.s8)
                }
            }
    }
}
