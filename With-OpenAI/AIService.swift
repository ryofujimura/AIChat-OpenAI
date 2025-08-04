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
    
    private var llamaProcess: Process?
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
            
            let fileSize = try FileManager.default.attributesOfItem(atPath: modelPath)[.size] as? Int64 ?? 0
            print("Model file size: \(fileSize) bytes (\(fileSize / 1024 / 1024) MB)")
            
            // Check if llama.cpp binary exists
            let llamaBinary = "/usr/local/bin/llama" // Common installation path
            if FileManager.default.fileExists(atPath: llamaBinary) {
                print("Found llama.cpp binary at: \(llamaBinary)")
                await MainActor.run {
                    isModelLoaded = true
                    print("Model loaded successfully")
                }
            } else {
                print("llama.cpp binary not found. Please install llama.cpp first.")
                await MainActor.run {
                    isModelLoaded = false
                }
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
        
        // Format prompt for Llama 3.2 Instruct
        let formattedPrompt = "<|system|>\nYou are a helpful AI assistant.\n<|user|>\n\(prompt)\n<|assistant|>\n"
        
        do {
            // Create a temporary file for the prompt
            let tempDir = FileManager.default.temporaryDirectory
            let promptFile = tempDir.appendingPathComponent("prompt.txt")
            try formattedPrompt.write(to: promptFile, atomically: true, encoding: .utf8)
            
            // Run llama.cpp process
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/local/bin/llama")
            process.arguments = [
                "-m", modelPath,
                "-f", promptFile.path,
                "-n", "512",  // max tokens
                "--temp", "0.7",
                "--top-p", "0.9",
                "--repeat-penalty", "1.1"
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            try process.run()
            
            // Read output asynchronously
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let response = String(data: data, encoding: .utf8) ?? "No response generated"
            
            await MainActor.run {
                output = response
                isGenerating = false
            }
            
            process.waitUntilExit()
            
        } catch {
            print("Error running llama.cpp: \(error)")
            await MainActor.run {
                output = "Error: Failed to generate response. Please ensure llama.cpp is installed."
                isGenerating = false
            }
        }
    }
    
    func stopGeneration() {
        llamaProcess?.terminate()
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
