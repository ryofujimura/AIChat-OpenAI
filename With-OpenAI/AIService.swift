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
    }
    
    func generateResponse(to prompt: String) async {
        isGenerating = true
        output = ""
        
        // Simulate AI response for now
        let responses = [
            "You're doing great! Keep pushing forward! 💪✨",
            "Every step counts toward your goals! 🌟",
            "You have the power to make amazing things happen! 🚀",
            "Believe in yourself - you're capable of incredible things! 💫",
            "Your determination is inspiring! Keep going! 🔥",
            "You're making progress every day! 🌈",
            "Your potential is limitless! Keep shining! ⭐",
            "You're stronger than you know! 💎",
            "Every challenge makes you stronger! 💪",
            "You're on the right path! Keep moving forward! 🎯"
        ]
        
        // Simulate typing delay
        for i in 0..<prompt.count {
            await Task.sleep(50_000_000) // 50ms delay
            output = String(prompt.prefix(i + 1))
        }
        
        // Add the response
        let randomResponse = responses.randomElement() ?? "You're doing great! ✨"
        output = randomResponse
        
        isGenerating = false
    }
    
    func stopGeneration() {
        isGenerating = false
    }
    
    @MainActor func setOutput(to newOutput: String) {
        output = newOutput
    }
} 
