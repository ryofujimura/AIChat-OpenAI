//
//  HeartWarmingChatView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct HeartWarmingChatView: View {
    @Binding var pendingAutoGenerate: Bool
    @StateObject private var viewModel = HeartWarmingChatModel()
    @State private var userInput = ""
    @State private var displayedMessage: String?
    @State private var tapEmojiBursts: [TapEmojiBurst] = []
    @State private var showHistory = false

    private var isShowingResponse: Bool {
        guard let displayedMessage, !displayedMessage.isEmpty else { return false }
        return !viewModel.isCompleting
    }

    init(pendingAutoGenerate: Binding<Bool> = .constant(false)) {
        _pendingAutoGenerate = pendingAutoGenerate
    }

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
                        },
                        onMessageTapAt: { point in
                            spawnTapEmojis(at: point)
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

            ForEach(tapEmojiBursts) { burst in
                TapLocationEmojiBurstView(burst: burst)
            }

            if viewModel.showEmojiPopup {
                EmojiPopupView(
                    emojis: viewModel.responseEmojis,
                    isShowing: $viewModel.showEmojiPopup
                )
            }

            Button {
                showHistory = true
            } label: {
                Text("🧾")
                    .font(.system(size: Fib.typeButton))
                    .frame(width: Fib.s55, height: Fib.s55)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.horizontal, Fib.s21)
            .padding(.top, Fib.s8)
        }
        .sheet(isPresented: $showHistory) {
            ResponseHistoryView()
        }
        .onAppear {
            attemptAutoGenerate()
        }
        .onChange(of: pendingAutoGenerate) { _ in
            attemptAutoGenerate()
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

    private func attemptAutoGenerate() {
        guard pendingAutoGenerate else { return }
        pendingAutoGenerate = false
        guard !viewModel.isButtonDisabled, !viewModel.isCompleting else { return }
        viewModel.startCooldown()
        viewModel.generateCompletion()
    }

    private func spawnTapEmojis(at point: CGPoint) {
        guard isShowingResponse else { return }

        let emojis = viewModel.responseEmojis.isEmpty
            ? ["✨", "💖", "🌟"]
            : viewModel.responseEmojis
        let burst = TapEmojiBurst(id: UUID(), point: point, emojis: emojis)
        tapEmojiBursts.append(burst)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            tapEmojiBursts.removeAll { $0.id == burst.id }
        }
    }

    private var hasEasterEggInput: Bool {
        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var easterEggForm: some View {
        ArcadePanel(cornerRadius: Fib.radiusCard) {
            VStack(spacing: Fib.s13) {
                Text("Easter Egg 🥚🥚")
                    .font(.system(size: Fib.typeButton, weight: .semibold))
                    .foregroundStyle(WarmGlow.ink)

                WarmGlowInsetField(text: $userInput, placeholder: "enter your thoughts...")

                WarmGlowFlatButton(title: "push", isEnabled: hasEasterEggInput) {
                    guard hasEasterEggInput else { return }
                    viewModel.generatePositiveFeedback(for: userInput)
                    userInput = ""
                    viewModel.startCooldown()
                }
            }
        }
    }
}

#Preview {
    HeartWarmingChatView()
}
