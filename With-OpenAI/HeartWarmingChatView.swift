//
//  HeartWarmingChatView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct HeartWarmingChatView: View {
    @EnvironmentObject private var themeStore: ThemeStore
    @StateObject private var viewModel = HeartWarmingChatModel()
    @State private var userInput = ""
    @State private var showThemeSettings = false

    private let cooldownDuration = 10

    private var palette: ThemePalette { themeStore.currentPalette }

    var body: some View {
        NavigationStack {
            ZStack {
                palette.base
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    WarmGlowMessageCard(isLoading: viewModel.isCompleting) {
                        if let responseText = viewModel.responseText {
                            Text(responseText)
                        } else {
                            Text("...")
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
            .environment(\.themePalette, palette)
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showThemeSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: Fib.typeButton))
                            .foregroundStyle(palette.ink)
                    }
                    .accessibilityLabel("Color theme settings")
                }
            }
            .sheet(isPresented: $showThemeSettings) {
                ThemeSettingsView()
                    .environmentObject(themeStore)
                    .environment(\.themePalette, palette)
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
                .foregroundStyle(palette.ink)

            Text("Tell us your needs:")
                .font(.system(size: Fib.typeCaption))
                .foregroundStyle(palette.secondary)

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
                .fill(palette.surface)
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
        .environmentObject(ThemeStore())
}
