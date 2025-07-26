//
//  HeartWarmingChatModel.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//  OpenAI API

import Foundation
import OpenAIKit

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
    
    let chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "Answer under 40 letters and 3 fitting emojis. be unique."),
        ChatMessage(role: .user, content: "motivate me with heart warming words"),
    ]
    
    private func separateEmojisFromText(_ text: String) -> (text: String, emojis: [String]) {
        var cleanText = text
        var emojis: [String] = []
        
        // Extract emojis using Unicode scalar properties
        let emojiPattern = "\\p{Emoji}"
        let regex = try? NSRegularExpression(pattern: emojiPattern, options: [])
        
        if let regex = regex {
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, options: [], range: range)
            
            // Extract emojis in reverse order to maintain indices
            for match in matches.reversed() {
                if let range = Range(match.range, in: text) {
                    let emoji = String(text[range])
                    emojis.insert(emoji, at: 0) // Insert at beginning to maintain order
                    cleanText.removeSubrange(range)
                }
            }
        }
        
        // Clean up extra whitespace
        cleanText = cleanText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (cleanText, emojis)
    }
    
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
                let chatCompletion = try await openAI.generateChatCompletion(parameters: chatParameters)
                
                if let message = chatCompletion.choices.first?.message {
                    DispatchQueue.main.async {
                        let separated = self.separateEmojisFromText(message.content ?? "")
                        self.responseText = separated.text
                        self.responseEmojis = separated.emojis
                        self.isCompleting = false
                        
                        // Show emoji popup if we have emojis
                        if !separated.emojis.isEmpty {
                            self.showEmojiPopup = true
                        }
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
                    organizationId: openAIorganizationId,
                    apiKey: openAIAPIKey
                )
                let openAI = OpenAI(config)
                let easterEggMessages: [ChatMessage] = [
                    ChatMessage(role: .system, content: "You are a kind and supportive friend. Respond to the user's needs with gentle, warm positivity and under 60 letters and 3 emojis."),
                    ChatMessage(role: .user, content: "User's needs is \(userInput)\nPlease offer kind, encouraging words!")
                ]
                
                let chatParameters = ChatParameters(model: .chatGPTTurbo, messages: easterEggMessages)
                let chatCompletion = try await openAI.generateChatCompletion(parameters: chatParameters)
                
                if let message = chatCompletion.choices.first?.message {
                    DispatchQueue.main.async {
                        let separated = self.separateEmojisFromText(message.content ?? "")
                        self.responseText = separated.text
                        self.responseEmojis = separated.emojis
                        self.isCompleting = false
                        
                        // Show emoji popup if we have emojis
                        if !separated.emojis.isEmpty {
                            self.showEmojiPopup = true
                        }
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
