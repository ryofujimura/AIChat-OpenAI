//
//  MainView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct MainView: View {
    @State private var isShowingLaunchScreen = true
    
    var body: some View {
        ZStack {
            if isShowingLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Show launch screen for 2 seconds then transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingLaunchScreen = false
                }
            }
        }
    }
}

#Preview {
    MainView()
} 