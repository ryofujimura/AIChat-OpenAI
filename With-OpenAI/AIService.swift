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
        
        // Initialize AI with the Phi model
        ai = AI(_modelPath: modelPath, _chatName: "with_chat")
        
        // Configure model parameters for TinyLlama
        var params = ModelAndContextParams.default
        params.context = 2048
        params.use_metal = true
        params.promptFormat = .Custom
        params.custom_prompt_format = "<|system|>Answer under 40 letters and 3 fitting emojis. Be unique. Motivate me with heart warming words.</s><|user|>{{prompt}}</s><|assistant|>"
        
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