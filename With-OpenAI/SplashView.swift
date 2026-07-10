//
//  SplashView.swift
//  With-OpenAI
//

import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var nameOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.88

    var body: some View {
        ZStack {
            WarmGlow.base
                .ignoresSafeArea()

            VStack(spacing: Fib.s21) {
                AppLogoView(size: Fib.s89)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Text("With OpenAI")
                    .font(.system(size: Fib.typeButton, weight: .semibold))
                    .foregroundStyle(WarmGlow.ink)
                    .opacity(nameOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                logoOpacity = 1
                logoScale = 1
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.25)) {
                nameOpacity = 1
            }
        }
    }
}

struct AppLogoView: View {
    var size: CGFloat = Fib.s89

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [WarmGlow.housingRim, WarmGlow.housing],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size + Fib.s13, height: size + Fib.s13)
                .shadow(color: Color.black.opacity(0.4), radius: Fib.s8, x: 0, y: Fib.s8)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [WarmGlow.accentHighlight, WarmGlow.accent, WarmGlow.accentShadow],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .overlay {
                    Ellipse()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: size * 0.55, height: size * 0.25)
                        .offset(y: -size * 0.18)
                }

            Text("✨")
                .font(.system(size: size * 0.45))
                .shadow(color: Color.black.opacity(0.2), radius: 0, x: 0, y: 2)
        }
    }
}

#Preview {
    SplashView()
}
