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

    private let cooldownDuration = 10

    var body: some View {
        ZStack {
            WarmGlow.base
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                WarmGlowMessageCard(isLoading: viewModel.isCompleting) {
                    if viewModel.responseSentences.isEmpty {
                        Text("...")
                    } else if viewModel.responseSentences.count == 1 {
                        Text(viewModel.responseSentences[0])
                    } else {
                        VStack(spacing: Fib.s13) {
                            ForEach(Array(viewModel.responseSentences.enumerated()), id: \.offset) { _, sentence in
                                Text(sentence)
                            }
                        }
                    }
                }

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
    }

    @ViewBuilder
    private var actionArea: some View {
        if viewModel.showEasterEggForm {
            easterEggForm
        } else {
            generateOrCooldownButton
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

    @ViewBuilder
    private var generateOrCooldownButton: some View {
        if viewModel.isButtonDisabled {
            WarmGlowCooldownButton(
                countdown: viewModel.countdown,
                totalDuration: cooldownDuration
            ) {
                viewModel.incrementDisabledTapCount()
            }
        } else {
            WarmGlowPrimaryButton(title: "Generate Completion") {
                viewModel.startCooldown()
                viewModel.generateCompletion()
            }
        }
    }
}

#Preview {
    HeartWarmingChatView()
}
