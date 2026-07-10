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
    @State private var displayedMessage: String?

    var body: some View {
        ZStack {
            WarmGlow.base
                .ignoresSafeArea()

            VStack(spacing: Fib.s21) {
                Spacer()

                if viewModel.showEasterEggForm {
                    easterEggForm
                } else {
                    WarmGlowInteractiveCard(
                        isLoading: viewModel.isCompleting,
                        isCooldown: viewModel.isButtonDisabled,
                        message: displayedMessage,
                        onGenerate: {
                            viewModel.startCooldown()
                            viewModel.generateCompletion()
                        },
                        onCooldownTap: {
                            viewModel.incrementDisabledTapCount()
                        }
                    )
                    .animation(.easeInOut(duration: 0.4), value: displayedMessage)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isCompleting)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isButtonDisabled)
                }

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
                displayedMessage = newValue
            }
        }
        .onChange(of: viewModel.countdown) { countdown in
            if countdown == 0 && viewModel.isButtonDisabled == false && displayedMessage != nil {
                withAnimation(.easeInOut(duration: 0.4)) {
                    displayedMessage = nil
                }
            }
        }
    }

    private var easterEggForm: some View {
        ArcadePanel(cornerRadius: Fib.radiusCard) {
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
        }
    }
}

#Preview {
    HeartWarmingChatView()
}
