//
//  HeartWarmingChatModel.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//  OpenAI API

import Foundation
import OpenAIKit

private struct HeartWarmingResponse: Decodable {
    let sentences: [String]
    let expressiveEmojis: [String]

    enum CodingKeys: String, CodingKey {
        case sentences
        case text
        case expressiveEmojis
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sentences = Self.decodeSentences(from: container)
        expressiveEmojis = Self.decodeExpressiveEmojis(from: container)
    }

    private static func decodeSentences(from container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let sentences = try? container.decode([String].self, forKey: .sentences) {
            return sentences
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        if let sentenceString = try? container.decode(String.self, forKey: .sentences) {
            return parseSentenceString(sentenceString)
        }

        if let text = try? container.decode(String.self, forKey: .text) {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? [] : [trimmed]
        }

        return []
    }

    private static func decodeExpressiveEmojis(from container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let emojis = try? container.decode([String].self, forKey: .expressiveEmojis) {
            return emojis
        }

        if let emojiString = try? container.decode(String.self, forKey: .expressiveEmojis) {
            return extractEmojis(from: emojiString)
        }

        return []
    }

    private static func parseSentenceString(_ value: String) -> [String] {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        if trimmed.hasPrefix("["),
           let data = trimmed.data(using: .utf8),
           let sentences = try? JSONDecoder().decode([String].self, from: data) {
            return sentences
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return trimmed
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
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
    @Published var responseSentences: [String] = []
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
        description: "Return a warm message with one sentence per array item and separate mood emojis.",
        parameters: Parameters(
            type: "object",
            properties: [
                "sentences": ParameterDetail(
                    type: "string",
                    description: "JSON array where each item is exactly one complete sentence. Use one item for a single sentence. Example: [\"Enjoy your coffee\"] or [\"You are enough.\", \"Keep going today.\"]"
                ),
                "expressiveEmojis": ParameterDetail(
                    type: "string",
                    description: "Exactly 3 mood or feeling emojis only — not nouns from the sentence. Example: 😊✨💖"
                ),
            ],
            required: ["sentences", "expressiveEmojis"]
        )
    )

    private static let systemPrompt = """
    You are a warm, encouraging assistant. Always call deliverHeartWarmingMessage.
    - sentences: a JSON array with exactly 1 sentence. Each array item must be one complete sentence. Use words only — no emojis. Total length under 40 characters. If you mention coffee, flowers, or anything else, write the word.
    - expressiveEmojis: exactly 3 emojis that express mood or feeling only, not objects from the sentence.
    Be unique.
    """

    private static let easterEggSystemPrompt = """
    You are a kind and supportive friend. Always call deliverHeartWarmingMessage.
    - sentences: a JSON array with 1 or 2 sentences. Each array item must be one complete sentence. Use words only — no emojis. Total length under 60 characters.
    - expressiveEmojis: exactly 3 emojis that express mood or feeling only, not objects from the sentence.
    """

    let chat: [ChatMessage] = [
        ChatMessage(role: .system, content: systemPrompt),
        ChatMessage(role: .user, content: "motivate me with heart warming words"),
    ]

    private func parseStructuredResponse(from message: ChatMessage) -> (sentences: [String], emojis: [String])? {
        if let functionCall = message.functionCall,
           functionCall.name == Self.responseFunction.name,
           let data = functionCall.arguments.data(using: .utf8),
           let response = try? JSONDecoder().decode(HeartWarmingResponse.self, from: data),
           !response.sentences.isEmpty {
            return (response.sentences, response.expressiveEmojis)
        }

        guard let content = message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty,
              let data = content.data(using: .utf8),
              let response = try? JSONDecoder().decode(HeartWarmingResponse.self, from: data),
              !response.sentences.isEmpty else {
            return nil
        }

        return (response.sentences, response.expressiveEmojis)
    }

    private func applyResponse(from message: ChatMessage) {
        if let parsed = parseStructuredResponse(from: message) {
            responseSentences = parsed.sentences
            responseEmojis = parsed.emojis
            if !parsed.emojis.isEmpty {
                showEmojiPopup = true
            }
        } else if let content = message.content?.trimmingCharacters(in: .whitespacesAndNewlines), !content.isEmpty {
            responseSentences = [content]
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
