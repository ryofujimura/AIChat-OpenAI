//
//  ContentView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                HeartWarmingChatView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
