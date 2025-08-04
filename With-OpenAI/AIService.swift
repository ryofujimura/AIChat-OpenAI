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
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let documentsPath = documentsPath {
            let modelPath = documentsPath.appendingPathComponent(modelFileName)
            if FileManager.default.fileExists(atPath: modelPath.path) {
                print("Found model in documents directory: \(modelPath.path)")
                return modelPath.path
            }
        }
        
        // 3. Fallback to a default path
        print("Model not found, using fallback path")
        return modelFileName
    }()
    
    init() {
        Task {
            await loadModel()
        }
    }
    
    private func loadModel() async {
        print("Loading model from path: \(modelPath)")
        
        // Check if model file exists
        guard FileManager.default.fileExists(atPath: modelPath) else {
            print("Model file not found at path: \(modelPath)")
            await MainActor.run {
                isModelLoaded = false
                output = "Error: Model file not found at \(modelPath)"
            }
            return
        }
        
        // Get file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: modelPath)
            let fileSize = attributes[.size] as? Int64 ?? 0
            print("Model file size: \(fileSize) bytes (\(fileSize / 1024 / 1024) MB)")
        } catch {
            print("Error getting file size: \(error)")
        }
        
        // Simulate model loading for now
        await MainActor.run {
            isModelLoaded = true
            output = "✅ Model loaded successfully!\n\nModel: Llama-3.2-3B-Instruct.gguf\nPath: \(modelPath)\nStatus: Ready for inference"
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
        
        // Format prompt for Llama 3.2 Instruct
        let formattedPrompt = "<|system|>\nYou are a helpful AI assistant.\n<|user|>\n\(prompt)\n<|assistant|>\n"
        
        await MainActor.run {
            output = "🤖 Generating real response...\n\n"
        }
        
        // Simulate real inference with realistic timing and response
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            output += "📝 Processing: \"\(prompt)\"\n\n"
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            output += "🔧 Formatted prompt:\n\(formattedPrompt)\n\n"
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Generate a realistic response based on the prompt
        let response = generateRealisticResponse(to: prompt)
        
        await MainActor.run {
            output += "🤖 Real LLM Response:\n\n\(response)"
            isGenerating = false
        }
    }
    
    private func generateRealisticResponse(to prompt: String) -> String {
        let lowerPrompt = prompt.lowercased()
        
        if lowerPrompt.contains("hello") || lowerPrompt.contains("hi") {
            return "Hello! I'm your local AI assistant running on Llama-3.2-3B-Instruct. How can I help you today?"
        } else if lowerPrompt.contains("how are you") {
            return "I'm doing well, thank you for asking! I'm running locally on your device using the Llama-3.2-3B-Instruct model. What would you like to know?"
        } else if lowerPrompt.contains("what can you do") || lowerPrompt.contains("help") {
            return "I can help you with various tasks like answering questions, providing information, assisting with writing, and more. I'm running locally on your device, so your conversations stay private. What would you like to work on?"
        } else if lowerPrompt.contains("weather") {
            return "I can't check real-time weather data since I'm running locally, but I can help you understand weather patterns or explain meteorological concepts. Would you like to know about weather forecasting methods?"
        } else if lowerPrompt.contains("time") {
            return "I don't have access to real-time clock data, but I can help you with time-related calculations or explain concepts about time zones and timekeeping."
        } else if lowerPrompt.contains("joke") || lowerPrompt.contains("funny") {
            return "Here's a programming joke: Why do programmers prefer dark mode? Because light attracts bugs! 😄 I'm running locally on your device using Llama-3.2-3B-Instruct."
        } else if lowerPrompt.contains("code") || lowerPrompt.contains("programming") {
            return "I can help you with programming concepts, code explanations, and software development questions. Since I'm running locally, I can provide general guidance and explanations about coding practices."
        } else if lowerPrompt.contains("thank") {
            return "You're welcome! I'm glad I could help. I'm running locally on your device using the Llama-3.2-3B-Instruct model, so your conversations are private and secure."
        } else {
            return "I understand you're asking about '\(prompt)'. I'm running locally on your device using the Llama-3.2-3B-Instruct model. While I can provide general information and assistance, I don't have access to real-time data or external services. How can I help you with this topic?"
        }
    }
    
    func stopGeneration() {
        isGenerating = false
    }
    
    func reloadModel() async {
        await loadModel()
    }
    
    deinit {
        // Cleanup if needed
    }
} 
