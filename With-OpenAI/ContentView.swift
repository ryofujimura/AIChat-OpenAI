//
//  ContentView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App title
                Text("AI Chat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Subtitle
                Text("Your AI Assistant")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Neomorphic button
                NeomorphicButton(title: "Start Chat") {
                    // TODO: Implement chat functionality
                    print("Start Chat button tapped!")
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}
