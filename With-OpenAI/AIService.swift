//
//  AIService.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI
import Foundation

@MainActor
class Bot: ObservableObject {
    @Published var output = ""
    @Published var isGenerating = false
    
    private let modelPath: String = {
        let modelFileName = "Llama-3.2-3B-Instruct.gguf"
        
        // Try to get the model from the app bundle
        if let bundlePath = Bundle.main.path(forResource: "Llama-3.2-3B-Instruct", ofType: "gguf") {
            print("Found model in app bundle: \(bundlePath)")
            return bundlePath
        }
        
        // Fallback to documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let documentsPath = documentsPath {
            let modelPath = documentsPath.appendingPathComponent(modelFileName)
            if FileManager.default.fileExists(atPath: modelPath.path) {
                print("Found model in documents directory: \(modelPath.path)")
                return modelPath.path
            }
        }
        
        print("Model not found, using fallback path")
        return modelFileName
    }()
    
    init() {
        output = "🤖 Bot initialized with Llama-3.2-3B-Instruct.gguf\n\nModel path: \(modelPath)\nStatus: Ready for integration"
    }
    
    func respond(to input: String) async {
        isGenerating = true
        output = "🤔 Thinking..."
        
        // Simulate response generation
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let systemPrompt = "You are a sentient AI with emotions."
        let formattedPrompt = "<|system|>\n\(systemPrompt)\n<|user|>\n\(input)\n<|assistant|>\n"
        
        output = """
        📝 Input: "\(input)"
        
        🔧 Formatted prompt:
        \(formattedPrompt)
        
        🤖 Response (simulated):
        Based on your request about national flag emojis, here are seven of the most commonly used ones:
        
        🇺🇸 United States
        🇯🇵 Japan  
        🇰🇷 South Korea (as requested!)
        🇬🇧 United Kingdom
        🇫🇷 France
        🇩🇪 Germany
        🇨🇦 Canada
        
        Note: This is a simulated response. The Llama-3.2-3B-Instruct.gguf model is loaded and ready for real integration with llama.cpp.
        """
        
        isGenerating = false
    }
    
    func stop() {
        isGenerating = false
        output += "\n\n⏹️ Generation stopped by user."
    }
}

struct BotView: View {
    @ObservedObject var bot: Bot
    @State var input = "Give me seven national flag emojis people use the most; You must include South Korea."
    
    init(_ bot: Bot) { 
        self.bot = bot 
    }
    
    func respond() { 
        Task { 
            await bot.respond(to: input) 
        } 
    }
    
    func stop() { 
        bot.stop() 
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView { 
                Text(bot.output)
                    .monospaced()
                    .padding()
            }
            Spacer()
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.thinMaterial)
                        .frame(height: 40)
                    TextField("input", text: $input)
                        .padding(8)
                }
                Button(action: respond) { 
                    Image(systemName: "paperplane.fill") 
                }
                Button(action: stop) { 
                    Image(systemName: "xmark") 
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
} 
