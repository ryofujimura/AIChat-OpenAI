//
//  HeartWarmingChatView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct HeartWarmingChatView: View {
    @StateObject private var viewModel = HeartWarmingChatModel()
    @State private var userInput = ""
    
    var body: some View {
        VStack {
            if let responseText = viewModel.responseText {
                Text(responseText)
                    .padding(.bottom, 20)
            } else {
                Text("...")
                    .padding(.bottom, 20)
            }
            if viewModel.showEasterEggForm {
                VStack {
                    Text("Easter Egg Mode!")
                        .font(.headline)
                    Text("Tell us your needs:")
                        .padding(.bottom, 8)
                    
                    TextField("Enter your needs", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    Button("Get Positive Feedback") {
                        viewModel.generatePositiveFeedback(for: userInput)
                        // Optionally reset Easter egg state after submission
                        viewModel.showEasterEggForm = false
                        viewModel.isButtonDisabled = false
                        viewModel.disabledTapCount = 0
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(Color.green)
                    .clipShape(Capsule())
                }
            } else {
                Button(action: {
                    if viewModel.isButtonDisabled {
                        viewModel.incrementDisabledTapCount()
                    } else {
                        viewModel.startCooldown()
                        viewModel.generateCompletion()
                    }
                }) {
                    if viewModel.isButtonDisabled {
                        Text("Wait \(viewModel.countdown)s")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 270, height: 50)
                            .background(Color.gray)
                            .clipShape(Capsule())
                            .padding(.top, 8)
                    } else {
                        Text("Generate Completion")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 270, height: 50)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .padding(.top, 8)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    HeartWarmingChatView()
}
