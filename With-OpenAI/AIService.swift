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
    private let modelPath = "/Users/ryofujimura/GitHub/AIChat-OpenAI/With-OpenAI/Phi-4-mini-instruct.Q3_K_S.gguf"
    
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var currentResponse = ""
    
    init() {
        // Load model immediately when service is initialized
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadModel()
        }
    }
    
    private func loadModel() {
        isLoading = true
        
        // Initialize AI with the Phi model
        ai = AI(_modelPath: modelPath, _chatName: "with_chat")
        
        // Configure model parameters
        var params = ModelAndContextParams.default
        params.context = 2048
        params.use_metal = true
        params.promptFormat = .Custom
        params.custom_prompt_format = "### Instruction: {{prompt}}\n\n### Response:"
        
        // Load the model
        do {
            let success = try ai?.loadModel(ModelInference.LLama_gguf, contextParams: params)
            DispatchQueue.main.async {
                self.isModelLoaded = success ?? false
                self.isLoading = false
            }
        } catch {
            print("Error loading model: \(error)")
            DispatchQueue.main.async {
                self.isModelLoaded = false
                self.isLoading = false
            }
        }
    }
    
    func generateResponse(to prompt: String, completion: @escaping (String) -> Void) {
        guard let ai = ai, isModelLoaded else {
            completion("Sorry, the AI model is not ready yet.")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            ai.conversation(prompt, { [weak self] token, time in
                // Token callback - update UI with streaming response
                DispatchQueue.main.async {
                    self?.currentResponse += token
                }
            }, { [weak self] fullResponse in
                // Completion callback
                DispatchQueue.main.async {
                    self?.currentResponse = ""
                    completion(fullResponse)
                }
            })
        }
    }
    
    func resetResponse() {
        currentResponse = ""
    }
} 