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
        if let bundlePath = Bundle.main.path(forResource: "TinyLlama-1.1B-Chat-v1.0.Q4_K_M", ofType: "gguf") {
            return bundlePath
        }
        
        // Fallback to documents directory if not in bundle
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsPath?.appendingPathComponent("TinyLlama-1.1B-Chat-v1.0.Q4_K_M.gguf").path ?? ""
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
        
        // Configure model parameters for TinyLlama
        var params = ModelAndContextParams.default
        params.context = 2048
        params.use_metal = true
        // Use default prompt format since TinyLlama format doesn't exist
        
        print("Using default prompt format")
        
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
        
        // Create a very restrictive system prompt that forces concise responses
        let systemPrompt = "You are a concise assistant. CRITICAL RULES: 1) Respond with ONLY the final answer - no explanations, no reasoning, no greetings. 2) Keep responses under 50 characters. 3) Do not use phrases like 'Here's' or 'I think'. 4) Start directly with your answer. 5) If asked for a motivational message, give ONLY the message with emojis."
        
        // Combine system prompt with user prompt
        let fullPrompt = "\(systemPrompt)\n\nUser: \(prompt)\n\nAssistant:"
        
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
        // Remove common prefixes that indicate reasoning
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        
        // Remove any text after common reasoning indicators
        let reasoningIndicators = [
            " because ",
            " since ",
            " as ",
            " therefore ",
            " thus ",
            " so ",
            " however ",
            " but ",
            " although ",
            " while "
        ]
        
        for indicator in reasoningIndicators {
            if let range = cleaned.lowercased().range(of: indicator) {
                cleaned = String(cleaned[..<range.lowerBound])
                cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Limit to first sentence or 50 characters, whichever is shorter
        if let firstSentenceEnd = cleaned.firstIndex(of: ".") {
            cleaned = String(cleaned[..<firstSentenceEnd])
        }
        
        if cleaned.count > 50 {
            cleaned = String(cleaned.prefix(50))
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func resetResponse() {
        currentResponse = ""
    }
} 
