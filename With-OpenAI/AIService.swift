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
        if let bundlePath = Bundle.main.path(forResource: "Llama_3.2_Instruct_Q4_K_M", ofType: "gguf") {
            print("Found model in app bundle: \(bundlePath)")
            return bundlePath
        }
        
        // Fallback to documents directory if not in bundle
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let documentsModelPath = documentsPath?.appendingPathComponent("Llama_3.2_Instruct_Q4_K_M.gguf").path ?? ""
        
        print("Checking documents directory: \(documentsModelPath)")
        
        // Also check if the file exists in the documents directory
        if FileManager.default.fileExists(atPath: documentsModelPath) {
            print("Found model in documents directory: \(documentsModelPath)")
            return documentsModelPath
        }
        
        // If not found, return the documents path anyway for debugging
        print("Model not found in bundle or documents directory")
        return documentsModelPath
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
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
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
        
        // Configure model parameters for Llama 3.2
        var params = ModelAndContextParams.default
        params.context = 8192  // Llama 3.2 supports larger context
        params.use_metal = true
        // Use default prompt format for Llama 3.2
        
        print("Using Llama 3.2 Instruct model with default prompt format")
        
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
        DispatchQueue.main.async {
            self.isModelLoaded = false
        }
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
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

You are a cheerful assistant. Write a short uplifting message with exactly 3 emojis: 🌱 💛 😊. Keep it under 25 characters. No explanations.

<|eot_id|><|start_header_id|>user<|end_header_id|>

Give me a short supportive message.

<|eot_id|><|start_header_id|>assistant<|end_header_id|>

"""
        } else if prompt.hasPrefix("user: ") {
            // User-specific message
            let userInput = String(prompt.dropFirst(6)) // Remove "user: " prefix
            fullPrompt = """
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

You are a cheerful assistant. Write a short uplifting message with exactly 3 emojis: 🌱 💛 😊. Keep it under 35 characters. No explanations.

<|eot_id|><|start_header_id|>user<|end_header_id|>

Give me a short supportive message for: \(userInput)

<|eot_id|><|start_header_id|>assistant<|end_header_id|>

"""
        } else {
            // Fallback
            fullPrompt = """
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

You are a cheerful assistant. Write a short uplifting message with exactly 3 emojis: 🌱 💛 😊. Keep it under 25 characters. No explanations.

<|eot_id|><|start_header_id|>user<|end_header_id|>

Give me a short supportive message.

<|eot_id|><|start_header_id|>assistant<|end_header_id|>

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
        // Basic cleanup for Llama 3.2 responses
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove any Llama 3.2 specific tokens that might appear
        cleaned = cleaned.replacingOccurrences(of: "<|eot_id|>", with: "")
        cleaned = cleaned.replacingOccurrences(of: "<|end_of_text|>", with: "")
        cleaned = cleaned.replacingOccurrences(of: "<|start_header_id|>", with: "")
        cleaned = cleaned.replacingOccurrences(of: "<|end_header_id|>", with: "")
        
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
        DispatchQueue.main.async {
            self.currentResponse = ""
        }
    }
} 
