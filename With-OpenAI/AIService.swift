//
//  AIService.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import Foundation

// Import llama.cpp C API
import llama

@MainActor
class AIService: ObservableObject {
    @Published var isGenerating = false
    @Published var output = ""
    @Published var input = ""
    @Published var isModelLoaded = false
    
    private var llamaContext: OpaquePointer?
    private var model: OpaquePointer?
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
            
            // Initialize llama.cpp model parameters
            var modelParams = llama_model_default_params()
            modelParams.n_gpu_layers = 0 // CPU only for iOS compatibility
            
            // Load the model
            model = llama_load_model_from_file(modelPath, modelParams)
            
            guard let model = model else {
                print("Failed to load model")
                await MainActor.run {
                    isModelLoaded = false
                }
                return
            }
            
            // Initialize context parameters
            var contextParams = llama_context_default_params()
            contextParams.n_ctx = 2048
            contextParams.n_batch = 512
            
            // Create context
            llamaContext = llama_new_context_with_model(model, contextParams)
            
            guard llamaContext != nil else {
                print("Failed to create context")
                llama_free_model(model)
                await MainActor.run {
                    isModelLoaded = false
                }
                return
            }
            
            await MainActor.run {
                isModelLoaded = true
                print("Model loaded successfully with llama.cpp")
            }
            
        } catch {
            print("Error loading model: \(error)")
            await MainActor.run {
                isModelLoaded = false
            }
        }
    }
    
    func generateResponse(to prompt: String) async {
        guard let llamaContext = llamaContext, isModelLoaded else {
            print("Model not loaded, cannot generate response")
            output = "Error: Model not loaded. Please try again."
            return
        }
        
        isGenerating = true
        output = ""
        
        do {
            // Format prompt for Llama 3.2 Instruct
            let formattedPrompt = "<|system|>\nYou are a helpful AI assistant.\n<|user|>\n\(prompt)\n<|assistant|>\n"
            
            // Get vocabulary from model
            guard let model = model else {
                print("Model not available")
                await MainActor.run {
                    output = "Error: Model not available"
                    isGenerating = false
                }
                return
            }
            
            let vocab = llama_model_get_vocab(model)
            
            // Tokenize the prompt
            var tokens = [llama_token]()
            tokens.reserveCapacity(2048)
            let initialTokenCount = llama_tokenize(vocab, formattedPrompt, Int32(formattedPrompt.count), &tokens, Int32(tokens.capacity), true, true)
            
            guard initialTokenCount > 0 else {
                print("Failed to tokenize prompt")
                await MainActor.run {
                    output = "Error: Failed to tokenize prompt"
                    isGenerating = false
                }
                return
            }
            
            // Create batch for evaluation
            var batch = llama_batch_get_one(&tokens, Int32(initialTokenCount))
            
            // Evaluate the prompt
            let evalResult = llama_decode(llamaContext, batch)
            guard evalResult == 0 else {
                print("Failed to evaluate prompt")
                await MainActor.run {
                    output = "Error: Failed to evaluate prompt"
                    isGenerating = false
                }
                return
            }
            
            // Generate response
            var response = ""
            let maxTokens = 512
            var generatedTokenCount = 0
            
            while generatedTokenCount < maxTokens {
                // Get logits
                let logitsPtr = llama_get_logits(llamaContext)
                guard logitsPtr != nil else {
                    print("Failed to get logits")
                    break
                }
                
                // Create token data array for sampling
                let vocabSize = llama_vocab_n_tokens(vocab)
                var tokenDataArray = llama_token_data_array()
                tokenDataArray.data = UnsafeMutablePointer<llama_token_data>.allocate(capacity: Int(vocabSize))
                tokenDataArray.size = Int(vocabSize)
                tokenDataArray.sorted = false
                
                // Fill token data array
                for i in 0..<Int(vocabSize) {
                    tokenDataArray.data[Int(i)].id = Int32(i)
                    tokenDataArray.data[Int(i)].logit = logitsPtr![Int(i)]
                    tokenDataArray.data[Int(i)].p = 0.0
                }
                
                // Create sampler for top-k and top-p
                let topKSampler = llama_sampler_init_top_k(40)
                let topPSampler = llama_sampler_init_top_p(0.9, 1)
                let tempSampler = llama_sampler_init_temp(0.7)
                
                // Apply samplers
                llama_sampler_apply(topKSampler, &tokenDataArray)
                llama_sampler_apply(topPSampler, &tokenDataArray)
                llama_sampler_apply(tempSampler, &tokenDataArray)
                
                // Sample next token
                var nextToken = llama_sampler_sample(topKSampler, llamaContext, 0)
                
                // Check for end of sequence
                if nextToken == llama_vocab_eos(vocab) {
                    break
                }
                
                // Convert token to string
                var tokenStr = [CChar](repeating: 0, count: 256)
                let tokenLen = llama_token_to_piece(vocab, nextToken, &tokenStr, 256, 0, false)
                if tokenLen > 0 {
                    let tokenString = String(cString: tokenStr)
                    response += tokenString
                }
                
                // Create batch for next token
                var nextBatch = llama_batch_get_one(&nextToken, 1)
                
                // Evaluate the new token
                let evalResult = llama_decode(llamaContext, nextBatch)
                if evalResult != 0 {
                    break
                }
                
                generatedTokenCount += 1
                
                // Update output incrementally
                await MainActor.run {
                    output = response
                }
                
                // Check if we should stop
                if isGenerating == false {
                    break
                }
                
                // Clean up samplers
                llama_sampler_free(topKSampler)
                llama_sampler_free(topPSampler)
                llama_sampler_free(tempSampler)
                tokenDataArray.data.deallocate()
            }
            
            await MainActor.run {
                isGenerating = false
            }
            
        } catch {
            print("Error generating response: \(error)")
            await MainActor.run {
                output = "Error generating response: \(error.localizedDescription)"
                isGenerating = false
            }
        }
    }
    
    func stopGeneration() {
        isGenerating = false
    }
    
    func reloadModel() {
        Task {
            // Clean up existing context and model
            if let llamaContext = llamaContext {
                llama_free(llamaContext)
                self.llamaContext = nil
            }
            if let model = model {
                llama_free_model(model)
                self.model = nil
            }
            isModelLoaded = false
            await loadModel()
        }
    }
    
    @MainActor func setOutput(to newOutput: String) {
        output = newOutput
    }
    
    deinit {
        if let llamaContext = llamaContext {
            llama_free(llamaContext)
        }
        if let model = model {
            llama_free_model(model)
        }
    }
} 
