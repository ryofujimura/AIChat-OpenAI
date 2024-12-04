//
//  HeartWarmingChatView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import Foundation
import SwiftUI

struct HeartWarmingChatView: View {
    @StateObject private var viewModel = HeartWarmingChatModel()

    var body: some View {
        VStack {
//            VStack(alignment: .leading) {
//                ForEach(viewModel.chat) { message in
//                    Text("\(message.role.rawValue.capitalized): \(message.content ?? "NO CONTENT")")
//                        .padding(.vertical, 10)
//                }
//            }
//            .padding(20)

            VStack {
                if let responseText = viewModel.responseText {
                    Text("\(responseText)")
                } else {
                    Text("...")
                }
                Button {
                    viewModel.generateCompletion()
                } label: {
                    Text("Generate Completion")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
            .padding()

            Spacer()
        }
    }
}

#Preview {
    HeartWarmingChatView()
}
