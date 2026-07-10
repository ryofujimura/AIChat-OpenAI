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
                .fill(WarmGlow.surface)
                .frame(width: size, height: size)
                .shadow(color: WarmGlow.shadowLight, radius: Fib.s8, x: -4, y: -4)
                .shadow(color: WarmGlow.shadowDark, radius: Fib.s8, x: 4, y: 4)

            Text("✨")
                .font(.system(size: size * 0.45))
        }
    }
}

#Preview {
    SplashView()
}
