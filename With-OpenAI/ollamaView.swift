//
//  ollamaView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/10.
//

import SwiftUI

struct ollamaView: View {
    // Access the shared DataInterface instance
    @EnvironmentObject var appModel: DataInterface
    
    var body: some View {
        VStack(spacing: 20) {
            // TextField for user to enter the prompt
            TextField("Enter your prompt here...", text: $appModel.prompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing], 20)
                .onSubmit {
                    appModel.sendPrompt()
                }
            
            // Divider to separate input from response
            Divider()
                .padding([.leading, .trailing], 20)
            
            // Display a progress view while sending
            if appModel.isSending {
                ProgressView("Processing...")
                    .padding()
            } else {
                // Display the response text
                ScrollView {
                    Text(appModel.response)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding([.leading, .trailing], 20)
            }
            
            Spacer()
            
            // HStack containing Send and Clear buttons
            HStack {
                Spacer()
                
                // Send Button
                Button(action: {
                    appModel.sendPrompt()
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Send")
                    }
                }
                .disabled(appModel.prompt.isEmpty || appModel.isSending)
                .padding()
                .background(appModel.prompt.isEmpty || appModel.isSending ? Color.gray.opacity(0.5) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Clear Button
                Button(action: {
                    appModel.prompt = ""
                    appModel.response = ""
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Clear")
                    }
                }
                .disabled(appModel.prompt.isEmpty && appModel.response.isEmpty)
                .padding()
                .background(appModel.prompt.isEmpty && appModel.response.isEmpty ? Color.gray.opacity(0.5) : Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding([.bottom], 20)
        }
        .padding()
    }
}

#Preview {
    ollamaView()
        .environmentObject(DataInterface())
}
