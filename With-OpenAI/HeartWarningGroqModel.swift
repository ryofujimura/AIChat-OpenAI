//
//  HeartWarningGroqModel.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/10.
//

import Foundation
import AIProxy

class HeartWarmingGroqModel: ObservableObject {
    @Published var responseText: String = ""
    @Published var streamingResponseText: String = ""

    private let groqService: GroqService

    init() {
        // Replace these placeholders with your actual partialKey and serviceURL from the AIProxy dashboard
        let partialKey = "your-partial-key"
        let serviceURL = "your-local-or-remote-service-url"

        self.groqService = AIProxy.groqService(
            partialKey: partialKey,
            serviceURL: serviceURL
        )
    }

    // MARK: - Non-Streaming Chat Completion
    func fetchNonStreamingCompletion() async {
        do {
            let request = GroqChatCompletionRequestBody(
                messages: [.assistant(content: "Hello world!")],
                model: "llama3.2-1b" // Make sure this matches your locally hosted model name
            )

            let response = try await groqService.chatCompletionRequest(body: request)
            if let message = response.choices.first?.message.content {
                DispatchQueue.main.async {
                    self.responseText = message
                }
            }
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
            print("Received non-200 status code: \(statusCode) with response body: \(responseBody)")
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Streaming Chat Completion
    func fetchStreamingCompletion() async {
        do {
            let request = GroqChatCompletionRequestBody(
                messages: [.assistant(content: "Can you tell me a heartwarming story?")],
                model: "llama3.2-1b"
            )

            let stream = try await groqService.streamingChatCompletionRequest(body: request)
            for try await chunk in stream {
                if let delta = chunk.choices.first?.delta.content {
                    DispatchQueue.main.async {
                        self.streamingResponseText.append(delta)
                    }
                }
            }
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
            print("Received \(statusCode) status code with response body: \(responseBody)")
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Audio Transcription Example (Optional)
    func transcribeAudio() async {
        do {
            guard let url = Bundle.main.url(forResource: "helloworld", withExtension: "m4a") else {
                print("Audio file not found in the bundle.")
                return
            }

            let requestBody = GroqTranscriptionRequestBody(
                file: try Data(contentsOf: url),
                model: "whisper-large-v3-turbo",
                responseFormat: "json"
            )

            let response = try await groqService.createTranscriptionRequest(body: requestBody)
            let transcript = response.text ?? "None"
            print("Groq transcribed: \(transcript)")
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
            print("Received non-200 status code: \(statusCode) with response body: \(responseBody)")
        } catch {
            print("Could not get audio transcription from Groq: \(error.localizedDescription)")
        }
    }
}
