//
//  ContentView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ContentView: View {
    @Binding var pendingAutoGenerate: Bool
    @State private var showSplash = true

    init(pendingAutoGenerate: Binding<Bool> = .constant(false)) {
        _pendingAutoGenerate = pendingAutoGenerate
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                HeartWarmingChatView(pendingAutoGenerate: $pendingAutoGenerate)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showSplash)
        .onAppear {
            if pendingAutoGenerate {
                showSplash = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    showSplash = false
                }
            }
        }
        .onChange(of: pendingAutoGenerate) { pending in
            if pending {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
