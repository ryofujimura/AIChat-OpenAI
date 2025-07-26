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
        // Get the path to the GGUF file in the app bundle
        guard let modelPath = Bundle.main.path(forResource: "Phi-4-mini-instruct.Q3_K_S", ofType: "gguf") else {
            errorMessage = "Model file not found in bundle"
            return
        }
        
        // Initialize AI with model path and chat name
        ai = AI(_modelPath: modelPath, _chatName: "WithAssistant")
        
        // Configure model parameters
        modelParams.promptFormat = .Custom
        modelParams.custom_prompt_format = """
        SYSTEM: You are a supportive and encouraging AI assistant. Your role is to provide helpful, positive, and motivating responses. Keep your responses concise, friendly, and uplifting.
        
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
        
        // Load the model
        loadModel()
    }
    
    private func loadModel() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let ai = self.ai else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to initialize AI"
                }
                return
            }
            
            do {
                // Initialize the model
                ai.initModel(ModelInference.LLama_gguf, contextParams: self.modelParams)
                
                guard ai.model != nil else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Model load error"
                    }
                    return
                }
                
                // Load model synchronously
                try ai.loadModel_sync()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isModelLoaded = true
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Model loading failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func generateResponse(for input: String, completion: @escaping (String?) -> Void) {
        guard isModelLoaded, let ai = ai, let model = ai.model else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var response = ""
            var totalOutput = 0
            let maxOutputLength = 200
            
            let callback: (String, Double) -> Bool = { str, _ in
                response += str
                totalOutput += str.count
                return totalOutput > maxOutputLength
            }
            
            do {
                let _ = try model.predict(input, callback)
                DispatchQueue.main.async {
                    completion(response.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func updateModelSettings(temperature: Float, topP: Float, mirostatTau: Float) {
        modelParams.sampleParams.temperature = temperature
        modelParams.sampleParams.top_p = topP
        modelParams.sampleParams.mirostat_tau = mirostatTau
        
        // Reload model with new settings if already loaded
        if isModelLoaded {
            loadModel()
        }
    }
} 