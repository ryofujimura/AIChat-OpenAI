//
//  ExampleChatModel.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI
import OpenAIKit

//CreateChatCompletionExample
struct CreateChatCompletionExample: View {
    @State private var responseText: String?
    @State private var isCompleting: Bool = false

    let chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "Answer under 40 letters and 3 fitting emojis"),
        ChatMessage(role: .user, content: "Cheer me up! with heart warming words"),
//        ChatMessage(role: .assistant, content: "You can do it!"),
//        ChatMessage(role: .user, content: "more love")
    ]

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ForEach(chat) { message in
                    Text("\(message.role.rawValue.capitalized): \(message.content ?? "NO CONTENT")")
                        .padding(.vertical, 10)
                }
            }
            .padding(20)

            if isCompleting {
                VStack {
                    if let responseText = self.responseText {
                        Text("Assistant: \(responseText)")
                    } else {
                        Text("Assistant: ...")
                    }
                }
                .padding()
            } else {
                VStack {
                    Button {
                        isCompleting = true

                        Task {
                            do {
                                let config = Configuration(
                                    organizationId: openAIorganizationId ,
                                    apiKey: openAIAPIKey
                                )
                                let openAI = OpenAI(config)
                                let chatParameters = ChatParameters(model: .chatGPTTurbo, messages: chat)
                                let chatCompletion = try await openAI.generateChatCompletion(
                                    parameters: chatParameters
                                )
                                
                                if let message = chatCompletion.choices[0].message {
                                    self.responseText = message.content
                                }
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Generate Completion")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 270, height: 50)
                            .background(.blue)
                            .clipShape(Capsule())
                            .padding(.top, 8)
                    }
                }
            }
        }

        Spacer()
    }
}

//CreateChatCompletionStreamingExample
struct CreateChatCompletionStreamingExample: View {
    @State private var responseText: String = ""
    @State private var isCompleting: Bool = false

    let chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "You are a helpful assistant."),
        ChatMessage(role: .user, content: "Who won the world series in 2020?"),
//        ChatMessage(role: .assistant, content: "The Los Angeles Dodgers won the World Series in 2020."),
//        ChatMessage(role: .user, content: "Where was it played?")
    ]

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ForEach(chat) { message in
                    Text("\(message.role.rawValue.capitalized): \(message.content ?? "NO CONTENT")")
                        .padding(.vertical, 10)
                }
            }
            .padding(20)

            if isCompleting {
                VStack {
                    Text(responseText)
                }
                .padding()
            } else {
                VStack {
                    Button {
                        self.isCompleting = true

                        Task {
                            do {
                                let config = Configuration(
                                    organizationId: openAIorganizationId ,
                                    apiKey: openAIAPIKey
                                )
                                let openAI = OpenAI(config)
                                let chatParameters = ChatParameters(model: .chatGPTTurbo, messages: chat)
                                let stream = try openAI.generateChatCompletionStreaming(
                                    parameters: chatParameters
                                )

                                for try await result in stream {
                                    if let delta = result.choices[0].delta {
                                        if let role = delta.role {
                                            self.responseText += "\(role.rawValue.capitalized): "
                                        } else if let content = delta.content {
                                            self.responseText += content
                                        }
                                    }
                                }
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Stream Completion")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 270, height: 50)
                            .background(.blue)
                            .clipShape(Capsule())
                            .padding(.top, 8)
                    }
                }
            }
        }

        Spacer()
    }
}

//CreateChatFunctionCallExample
struct CreateChatFunctionCallExample: View {
    @State private var isCompleting: Bool = false
    @State private var weatherInfo: WeatherInfo? = nil

    enum TemperatureUnit: String, Codable {
        case fahrenheit
        case celsius
    }

    struct WeatherInfo: Codable {
        let location: String
        let temperature: String
        let unit: TemperatureUnit
        let forecast: [String]
    }

    func getCurrentWeather(location: String, unit: TemperatureUnit = .fahrenheit) -> WeatherInfo {
        return WeatherInfo(location: location, temperature: "72", unit: unit, forecast: ["sunny", "windy"])
    }

    let messages: [ChatMessage] = [ChatMessage(role: .user, content: "What's the weather like in Boston?")]

    let functions: [Function] = [
        Function(
            name: "getCurrentWeather",
            description: "Get the current weather in a given location",
            parameters: Parameters(
                type: "object",
                properties: [
                    "location": ParameterDetail(type: "string", description: "The city and state, e.g. San Francisco, CA"),
                    "unit": ParameterDetail(type: "string", enumValues: ["fahrenheit", "celsius"])
                ],
                required: ["location"]
            )
        )
    ]

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ForEach(messages) { message in
                    Text("\(message.role.rawValue.capitalized): \(message.content ?? "NO CONTENT")")
                        .padding(.vertical, 10)
                }
            }
            .padding(20)

            if isCompleting {
                VStack {
                    if let weatherInfo {
                        Text("Assistant: The current weather in \(weatherInfo.location) is \(weatherInfo.temperature) degrees \(weatherInfo.unit.rawValue).")
                    } else {
                        Text("Assistant: ...")
                    }
                }
                .padding()
            } else {
                VStack {
                    Button {
                        isCompleting = true

                        Task {
                            do {
                                let config = Configuration(
                                    organizationId: openAIorganizationId ,
                                    apiKey: openAIAPIKey
                                )
                                let openAI = OpenAI(config)
                                let chatParameters = ChatParameters(
                                    model: .chatGPTTurbo,
                                    messages: messages,
                                    functionCall: "auto",
                                    functions: functions
                                )

                                let chatCompletion = try await openAI.generateChatCompletion(
                                    parameters: chatParameters
                                )

                                if let message = chatCompletion.choices[0].message, let functionCall = message.functionCall {
                                    let jsonString = functionCall.arguments
                                    if let data = jsonString.data(using: .utf8) {
                                        do {
                                            if
                                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                                let location = json["location"] as? String
                                            {
                                                self.weatherInfo = self.getCurrentWeather(location: location)
                                            }
                                        } catch {
                                            print("Error parsing JSON: \(error)")
                                        }
                                    }
                                }
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Generate Completion")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 270, height: 50)
                            .background(.blue)
                            .clipShape(Capsule())
                            .padding(.top, 8)
                    }
                }
            }
        }

        Spacer()
    }
}
