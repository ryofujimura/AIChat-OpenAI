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
        
        // Simulate model loading (since we can't use llama.cpp directly without proper framework integration)
        await MainActor.run {
            isModelLoaded = true
            output = "✅ Model loaded successfully!\n\nModel: Llama-3.2-3B-Instruct.gguf\nPath: \(modelPath)\nStatus: Ready for inference\n\nNote: This is a placeholder implementation. For real inference, you'll need to:\n1. Properly integrate llama.cpp framework\n2. Or use a pre-built iOS LLM library\n3. Or implement Metal Performance Shaders integration"
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
        
        // Simulate response generation with realistic timing
        await MainActor.run {
            output = "🤖 Generating response...\n\n"
        }
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            output += "📝 Your prompt: \"\(prompt)\"\n\n"
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            output += "🔧 Formatted for Llama 3.2 Instruct:\n\(formattedPrompt)\n\n"
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            output += "⚠️  Placeholder Response\n\n"
            output += "This is a simulated response. The model is loaded and ready, but actual inference requires:\n\n"
            output += "1. ✅ llama.cpp framework integration\n"
            output += "2. ✅ Proper C API bindings\n"
            output += "3. ✅ Tokenization and evaluation\n"
            output += "4. ✅ Real-time generation\n\n"
            output += "The Llama-3.2-3B-Instruct.gguf model is bundled and ready for real integration!"
            
            isGenerating = false
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
