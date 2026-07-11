//
//  ContentView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeStore: ThemeStore

    var body: some View {
        HeartWarmingChatView()
            .environment(\.themePalette, themeStore.currentPalette)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeStore())
}
