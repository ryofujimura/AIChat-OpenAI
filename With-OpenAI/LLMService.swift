//
//  LLMService.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import Foundation
import llmfarm_core

class LLMService: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var ai: AI?
    private var modelParams: ModelAndContextParams = .default
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        // Set custom prompt format for cheering assistant
        modelParams.promptFormat = .Custom
        modelParams.custom_prompt_format = """
SYSTEM: You are a supportive and encouraging AI assistant. Your role is to provide positive, uplifting responses that cheer up the user. Keep responses concise, friendly, and motivational.
USER: {prompt}
ASSISTANT:
"""
        
        // Enable Metal for better performance on supported devices
        modelParams.use_metal = true
        
        // Set sampling parameters for better response quality
        modelParams.sampleParams.mirostat = 2
        modelParams.sampleParams.mirostat_eta = 0.1
        modelParams.sampleParams.mirostat_tau = 5.0
        modelParams.sampleParams.temperature = 0.7
        modelParams.sampleParams.top_p = 0.9
        modelParams.sampleParams.top_k = 40
    }
    
    func loadModel() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Get model URL from bundle
            guard let modelURL = Bundle.main.url(forResource: "Phi-4-mini-instruct.Q3_K_S", withExtension: "gguf") else {
                await MainActor.run {
                    errorMessage = "Model file not found in bundle"
                    isLoading = false
                }
                return
            }
            
            // Initialize AI with model path
            ai = AI(_modelPath: modelURL.path, _chatName: "cheering_assistant")
            
            // Initialize model
            ai?.initModel(ModelInference.LLama_gguf, contextParams: modelParams)
            
            guard ai?.model != nil else {
                await MainActor.run {
                    errorMessage = "Failed to load model"
                    isLoading = false
                }
                return
            }
            
            // Load model synchronously
            try ai?.loadModel_sync()
            
            await MainActor.run {
                isModelLoaded = true
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Model loading error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func generateResponse(to prompt: String) async -> String {
        guard let ai = ai, isModelLoaded else {
            return "I'm still loading up my cheering powers! 🚀"
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        var generatedText = ""
        let maxOutputLength = 200
        
        let callback: (String, Double) -> Bool = { str, _ in
            generatedText += str
            return generatedText.count > maxOutputLength
        }
        
        do {
            let output = try ai.model?.predict(prompt, callback)
            await MainActor.run {
                isLoading = false
            }
            return generatedText.isEmpty ? "I'm here to cheer you on! 💪" : generatedText
        } catch {
            await MainActor.run {
                isLoading = false
            }
            return "Oops! Something went wrong with my cheering engine. Let me try again! ��"
        }
    }
} 