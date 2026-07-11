//
//  With_OpenAIApp.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

@main
struct With_OpenAIApp: App {
    @StateObject private var themeStore = ThemeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeStore)
                .environment(\.themePalette, themeStore.currentPalette)
        }
    }
}
