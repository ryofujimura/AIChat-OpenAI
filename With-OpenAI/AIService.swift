//
//  AIService.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import Foundation
import llmfarm_core

class AIService: ObservableObject {
    private var ai: AI?
    private let modelPath: String = {
        // Try to get the model from the app bundle first
        if let bundlePath = Bundle.main.path(forResource: "Dolphin_2.1_Mistral_7B", ofType: "gguf") {
            return bundlePath
        }
        
        // Fallback to documents directory if not in bundle
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsPath?.appendingPathComponent("Dolphin_2.1_Mistral_7B.gguf").path ?? ""
    }()
    
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var currentResponse = ""
    
    init() {
        // Load model immediately when service is initialized
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadModel()
        }
    }
    
    func loadModel() {
        isLoading = true
        
        // Log the model path for debugging
        print("Loading model from path: \(modelPath)")
        
        // Check if model file exists
        guard FileManager.default.fileExists(atPath: modelPath) else {
            print("Error: Model file not found at path: \(modelPath)")
            DispatchQueue.main.async {
                self.isModelLoaded = false
                self.isLoading = false
            }
            return
        }
        
        // Initialize AI with the model
        ai = AI(_modelPath: modelPath, _chatName: "with_chat")
        
        // Configure model parameters for Dolphin Mistral
        var params = ModelAndContextParams.default
        params.context = 4096  // Mistral supports larger context
        params.use_metal = true
        // Use default prompt format for Mistral
        
        print("Using Dolphin Mistral model with default prompt format")
        
        // Load the model
        do {
            let success = try ai?.loadModel(ModelInference.LLama_gguf, contextParams: params)
            DispatchQueue.main.async {
                self.isModelLoaded = success ?? false
                self.isLoading = false
                if success == true {
                    print("Model loaded successfully with new prompt format")
                }
            }
        } catch {
            print("Error loading model: \(error)")
            DispatchQueue.main.async {
                self.isModelLoaded = false
                self.isLoading = false
            }
        }
    }
    
    func reloadModel() {
        print("Reloading model with updated prompt...")
        isModelLoaded = false
        loadModel()
    }
    
    func generateResponse(to prompt: String, completion: @escaping (String) -> Void) {
        guard let ai = ai, isModelLoaded else {
            completion("Sorry, the AI model is not ready yet.")
            return
        }
        
        // Create rigid, template-based prompt based on input type
        let fullPrompt: String
        
        if prompt == "default" {
            // Default motivational message
            fullPrompt = """
<|im_start|>system
You respond with ONLY a short uplifting message. 
Rules: Max 25 letters. Include 🌱 💛 😊. 
No explanation. No hashtags. No extra text.
<|im_end|>
<|im_start|>user
Give me a short supportive message.
<|im_end|>
<|im_start|>assistant
"""
        } else if prompt.hasPrefix("user: ") {
            // User-specific message
            let userInput = String(prompt.dropFirst(6)) // Remove "user: " prefix
            fullPrompt = """
<|im_start|>system
You respond with ONLY a short uplifting message. 
Rules: Max 35 letters. Include 🌱 💛 😊. 
No explanation. No hashtags. No extra text.
<|im_end|>
<|im_start|>user
Give me a short supportive message for: \(userInput)
<|im_end|>
<|im_start|>assistant
"""
        } else {
            // Fallback
            fullPrompt = """
<|im_start|>system
You respond with ONLY a short uplifting message. 
Rules: Max 25 letters. Include 🌱 💛 😊. 
No explanation. No hashtags. No extra text.
<|im_end|>
<|im_start|>user
Give me a short supportive message.
<|im_end|>
<|im_start|>assistant
"""
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            ai.conversation(fullPrompt, { [weak self] token, time in
                // Token callback - update UI with streaming response
                DispatchQueue.main.async {
                    self?.currentResponse += token
                }
            }, { [weak self] fullResponse in
                // Completion callback - clean up the response
                DispatchQueue.main.async {
                    self?.currentResponse = ""
                    
                    // Clean up the response to remove any remaining reasoning
                    let cleanedResponse = self?.cleanResponse(fullResponse) ?? fullResponse
                    completion(cleanedResponse)
                }
            })
        }
    }
    
    private func cleanResponse(_ response: String) -> String {
        // Basic cleanup for Dolphin responses
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove any remaining <|im_end|> tags that might appear
        cleaned = cleaned.replacingOccurrences(of: "<|im_end|>", with: "")
        
        // Remove common reasoning prefixes
        let prefixesToRemove = [
            "Here's",
            "I think",
            "Let me",
            "Well,",
            "So,",
            "Based on",
            "According to",
            "I would say",
            "I believe",
            "In my opinion",
            "The answer is",
            "Here is",
            "I'll give you",
            "I can provide"
        ]
        
        for prefix in prefixesToRemove {
            if cleaned.lowercased().hasPrefix(prefix.lowercased()) {
                cleaned = String(cleaned.dropFirst(prefix.count))
                cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Limit to first sentence or 50 characters, whichever is shorter
        if let firstSentenceEnd = cleaned.firstIndex(of: ".") {
            cleaned = String(cleaned[..<firstSentenceEnd])
        }
        
        // Post-trim: Keep only first 50 characters as suggested
        if cleaned.count > 50 {
            cleaned = String(cleaned.prefix(50))
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func resetResponse() {
        currentResponse = ""
    }
} 
