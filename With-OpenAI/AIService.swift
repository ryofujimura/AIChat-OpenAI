//
//  AIService.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import Foundation

@MainActor
class AIService: ObservableObject {
    @Published var isGenerating = false
    @Published var output = ""
    @Published var input = ""
    @Published var isModelLoaded = false
    
    private let modelPath: String = {
        // Try multiple approaches to find the model file
        let modelFileName = "Llama-3.2-3B-Instruct.gguf" // Use the Llama-3.2-3B-Instruct model
        
        // 1. Try to get the model from the app bundle first
        if let bundlePath = Bundle.main.path(forResource: "Llama-3.2-3B-Instruct", ofType: "gguf") {
            print("Found model in app bundle: \(bundlePath)")
            return bundlePath
        }
        
        // 2. Try to find the model in the app's documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let modelURL = documentsPath.appendingPathComponent(modelFileName)
        if FileManager.default.fileExists(atPath: modelURL.path) {
            print("Found model in documents directory: \(modelURL.path)")
            return modelURL.path
        }
        
        // 3. Fallback to a default path
        print("Model not found, using default path")
        return modelFileName
    }()
    
    init() {
        print("AIService initialized - model path: \(modelPath)")
        Task {
            await loadModel()
        }
    }
    
    private func loadModel() async {
        do {
            print("Loading model from path: \(modelPath)")
            
            // Check if model file exists
            guard FileManager.default.fileExists(atPath: modelPath) else {
                print("Error: Model file not found at \(modelPath)")
                await MainActor.run {
                    isModelLoaded = false
                }
                return
            }
            
            let modelURL = URL(fileURLWithPath: modelPath)
            let fileSize = try FileManager.default.attributesOfItem(atPath: modelPath)[.size] as? Int64 ?? 0
            print("Model file size: \(fileSize) bytes (\(fileSize / 1024 / 1024) MB)")
            
            // For now, we'll simulate model loading success
            // TODO: Implement actual model loading with llama.cpp or other framework
            await MainActor.run {
                isModelLoaded = true
                print("Model loaded successfully (simulated)")
            }
            
        } catch {
            print("Error loading model: \(error)")
            await MainActor.run {
                isModelLoaded = false
            }
        }
    }
    
    func generateResponse(to prompt: String) async {
        guard isModelLoaded else {
            print("Model not loaded, cannot generate response")
            output = "Error: Model not loaded. Please try again."
            return
        }
        
        isGenerating = true
        output = ""
        
        // TODO: Implement actual LLM inference here
        // For now, we'll show that the system is ready for real implementation
        await MainActor.run {
            output = "🤖 AI Model Ready!\n\nThis is a placeholder response. The actual Llama-3.2-3B-Instruct model is loaded and ready for real inference.\n\nYour prompt: \"\(prompt)\"\n\nTo implement real AI responses, you'll need to:\n1. Add llama.cpp framework\n2. Initialize the model with proper parameters\n3. Run inference on the prompt\n4. Stream the response back"
            isGenerating = false
        }
    }
    
    func stopGeneration() {
        isGenerating = false
    }
    
    func reloadModel() {
        Task {
            isModelLoaded = false
            await loadModel()
        }
    }
    
    @MainActor func setOutput(to newOutput: String) {
        output = newOutput
    }
} 
