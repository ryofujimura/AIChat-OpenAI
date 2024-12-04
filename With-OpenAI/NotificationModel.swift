//
//  NotificationModel.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Permission granted")
        } else if let error = error {
            print("Error requesting permission: \(error.localizedDescription)")
        }
    }
}

import SwiftUI
import OpenAIKit

class HeartWarmingChatModel: ObservableObject {
    @Published var responseText: String?
    @Published var isCompleting: Bool = false

    let chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "Answer under 40 letters and 3 fitting emojis. be unique."),
        ChatMessage(role: .user, content: "motivate me with heart warming words"),
        // ChatMessage(role: .assistant, content: "You can do it!"),
        // ChatMessage(role: .user, content: "more love")
    ]

    func generateCompletion() {
        isCompleting = true

        Task {
            do {
                let config = Configuration(
                    organizationId: openAIorganizationId,
                    apiKey: openAIAPIKey
                )
                let openAI = OpenAI(config)
                let chatParameters = ChatParameters(model: .chatGPTTurbo, messages: chat)
                let chatCompletion = try await openAI.generateChatCompletion(
                    parameters: chatParameters
                )

                if let message = chatCompletion.choices.first?.message {
                    DispatchQueue.main.async {
                        self.responseText = message.content
                        self.isCompleting = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isCompleting = false
                }
                print("ERROR DETAILS - \(error)")
            }
        }
    }
}
