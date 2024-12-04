//
//  NotificationView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        NavigationStack {
            NavigationLink(destination: CreateChatCompletionExample()) {
                Text("Generate Chat Completion Example")
            }
            NavigationLink(destination: HeartWarmingChatView()){
                Text("Heartwarming")
            }
//            NavigationLink(destination: CreateChatCompletionStreamingExample()) {
//                Text("Generate Chat Completion Streaming Example")
//            }
//
//            NavigationLink(destination: CreateChatFunctionCallExample()) {
//                Text("Generate Chat Completion Function Call Example")
//            }
        }
        .listStyle(.plain)
        .navigationTitle("Chat")
    }
}


#Preview {
    NotificationView()
}
