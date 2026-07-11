//
//  HeartWarmingChatModel.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//  OpenAI API

import Foundation
import OpenAIKit

private struct HeartWarmingResponse: Decodable {
    let text: String
    let expressiveEmojis: [String]

    enum CodingKeys: String, CodingKey {
        case text
        case expressiveEmojis
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)

        if let emojis = try? container.decode([String].self, forKey: .expressiveEmojis) {
            expressiveEmojis = emojis
        } else if let emojiString = try? container.decode(String.self, forKey: .expressiveEmojis) {
            expressiveEmojis = HeartWarmingResponse.extractEmojis(from: emojiString)
        } else {
            expressiveEmojis = []
        }
    }

    static func extractEmojis(from text: String) -> [String] {
        var emojis: [String] = []
        var current = ""

        for character in text {
            let isEmoji = character.unicodeScalars.contains {
                $0.properties.isEmoji || $0.properties.isEmojiPresentation
            }

            if isEmoji {
                current.append(character)
            } else if !current.isEmpty {
                emojis.append(current)
                current = ""
            }
        }

        if !current.isEmpty {
            emojis.append(current)
        }

        return emojis
    }
}

class HeartWarmingChatModel: ObservableObject {
    @Published var responseText: String?
    @Published var responseEmojis: [String] = []
    @Published var isCompleting: Bool = false

    @Published var isButtonDisabled = false
    @Published var countdown = 0

    @Published var disabledTapCount = 0
    @Published var showEasterEggForm = false

    @Published var showEmojiPopup = false

    private var cooldownTimer: Timer?

    private static let responseFunction = Function(
        name: "deliverHeartWarmingMessage",
        description: "Return a warm message with complete text and separate mood emojis.",
        parameters: Parameters(
            type: "object",
            properties: [
                "text": ParameterDetail(
                    type: "string",
                    description: "A complete heart-warming sentence using words only. No emojis. Under 40 characters."
                ),
                "expressiveEmojis": ParameterDetail(
                    type: "string",
                    description: "Exactly 3 mood or feeling emojis only — not nouns from the sentence. Example: 😊✨💖"
                ),
            ],
            required: ["text", "expressiveEmojis"]
        )
    )

    private static let systemPrompt = """
    You are a warm, encouraging assistant. Always call deliverHeartWarmingMessage.
    - text: a complete sentence under 40 characters with words only. Never use emojis in text. If you mention coffee, flowers, or anything else, write the word.
    - expressiveEmojis: exactly 3 emojis that express mood or feeling only, not objects from the sentence.
    Be unique.
    """

    private static let easterEggSystemPrompt = """
    You are a kind and supportive friend. Always call deliverHeartWarmingMessage.
    - text: a gentle, encouraging sentence under 60 characters with words only. Never use emojis in text.
    - expressiveEmojis: exactly 3 emojis that express mood or feeling only, not objects from the sentence.
    """

    let chat: [ChatMessage] = [
        ChatMessage(role: .system, content: systemPrompt),
        ChatMessage(role: .user, content: "motivate me with heart warming words"),
    ]

    private func parseStructuredResponse(from message: ChatMessage) -> (text: String, emojis: [String])? {
        if let functionCall = message.functionCall,
           functionCall.name == Self.responseFunction.name,
           let data = functionCall.arguments.data(using: .utf8),
           let response = try? JSONDecoder().decode(HeartWarmingResponse.self, from: data) {
            let text = response.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            return (text, response.expressiveEmojis)
        }

        guard let content = message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty,
              let data = content.data(using: .utf8),
              let response = try? JSONDecoder().decode(HeartWarmingResponse.self, from: data) else {
            return nil
        }

        let text = response.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        return (text, response.expressiveEmojis)
    }

    private func applyResponse(from message: ChatMessage) {
        if let parsed = parseStructuredResponse(from: message) {
            responseText = parsed.text
            responseEmojis = parsed.emojis
            if !parsed.emojis.isEmpty {
                showEmojiPopup = true
            }
        } else if let content = message.content?.trimmingCharacters(in: .whitespacesAndNewlines), !content.isEmpty {
            responseText = content
            responseEmojis = []
        }
        isCompleting = false
    }

    private func chatParameters(messages: [ChatMessage]) -> ChatParameters {
        ChatParameters(
            model: .chatGPTTurbo,
            messages: messages,
            functionCall: "{\"name\": \"\(Self.responseFunction.name)\"}",
            functions: [Self.responseFunction]
        )
    }

    func generateCompletion() {
        isCompleting = true

        Task {
            do {
                let config = Configuration(
                    organizationId: openAIOrganizationId,
                    apiKey: openAIAPIKey
                )
                let openAI = OpenAI(config)
                let chatCompletion = try await openAI.generateChatCompletion(
                    parameters: chatParameters(messages: chat)
                )

                if let message = chatCompletion.choices.first?.message {
                    DispatchQueue.main.async {
                        self.applyResponse(from: message)
                    }
                } else {
                    DispatchQueue.main.async {
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

    func generatePositiveFeedback(for userInput: String) {
        isCompleting = true

        Task {
            do {
                let config = Configuration(
                    organizationId: openAIOrganizationId,
                    apiKey: openAIAPIKey
                )
                let openAI = OpenAI(config)
                let easterEggMessages: [ChatMessage] = [
                    ChatMessage(role: .system, content: Self.easterEggSystemPrompt),
                    ChatMessage(role: .user, content: "User's needs is \(userInput)\nPlease offer kind, encouraging words!"),
                ]

                let chatCompletion = try await openAI.generateChatCompletion(
                    parameters: chatParameters(messages: easterEggMessages)
                )

                if let message = chatCompletion.choices.first?.message {
                    DispatchQueue.main.async {
                        self.applyResponse(from: message)
                    }
                } else {
                    DispatchQueue.main.async {
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

    func startCooldown() {
        isButtonDisabled = true
        countdown = 10
        disabledTapCount = 0
        showEasterEggForm = false
        showEmojiPopup = false
        cooldownTimer?.invalidate()

        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                self.countdown = 0
                self.isButtonDisabled = false
                self.cooldownTimer?.invalidate()
                self.cooldownTimer = nil
            }
        }
    }

    func incrementDisabledTapCount() {
        guard isButtonDisabled && !showEasterEggForm else { return }

        disabledTapCount += 1
        if disabledTapCount > 20 {
            showEasterEggForm = true
        }
    }
}
