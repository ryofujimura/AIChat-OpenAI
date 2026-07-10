//
//  HeartWarmingChatView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct HeartWarmingChatView: View {
    @StateObject private var viewModel = HeartWarmingChatModel()
    @State private var userInput = ""
    @State private var displayedMessage = "..."

    private let cooldownDuration = 10

    var body: some View {
        ZStack {
            WarmGlow.base
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                WarmGlowMessageCard(
                    isLoading: viewModel.isCompleting,
                    message: displayedMessage
                )
                .animation(.easeInOut(duration: 0.4), value: displayedMessage)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isCompleting)

                Spacer()
                    .frame(height: Fib.s55)

                actionArea

                Spacer()
            }
            .padding(.horizontal, Fib.s21)
            .padding(.vertical, Fib.s34)

            if viewModel.showEmojiPopup {
                EmojiPopupView(
                    emojis: viewModel.responseEmojis,
                    isShowing: $viewModel.showEmojiPopup
                )
            }
        }
        .onChange(of: viewModel.responseText) { newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                displayedMessage = newValue ?? "..."
            }
        }
    }

    @ViewBuilder
    private var actionArea: some View {
        if viewModel.showEasterEggForm {
            easterEggForm
        } else if viewModel.isButtonDisabled {
            WarmGlowCooldownButton(
                countdown: viewModel.countdown,
                totalDuration: cooldownDuration
            ) {
                viewModel.incrementDisabledTapCount()
            }
        } else {
            WarmGlowTapButton(isDeemphasized: viewModel.isCompleting) {
                viewModel.startCooldown()
                viewModel.generateCompletion()
            }
        }
    }

    private var easterEggForm: some View {
        VStack(spacing: Fib.s13) {
            Text("Easter Egg Mode!")
                .font(.system(size: Fib.typeButton, weight: .semibold))
                .foregroundStyle(WarmGlow.ink)

            Text("Tell us your needs:")
                .font(.system(size: Fib.typeCaption))
                .foregroundStyle(WarmGlow.secondary)

            WarmGlowInsetField(text: $userInput, placeholder: "Enter your needs")

            WarmGlowFlatButton(title: "Get Positive Feedback") {
                viewModel.generatePositiveFeedback(for: userInput)
                viewModel.showEasterEggForm = false
                viewModel.isButtonDisabled = false
                viewModel.disabledTapCount = 0
            }
        }
        .padding(Fib.s21)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Fib.radiusCard)
                .fill(WarmGlow.surface)
        )
    }
}

#Preview {
    HeartWarmingChatView()
}
