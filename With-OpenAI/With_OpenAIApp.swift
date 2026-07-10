//
//  With_OpenAIApp.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

@main
struct With_OpenAIApp: App {
    @State private var pendingAutoGenerate = false

    var body: some Scene {
        WindowGroup {
            ContentView(pendingAutoGenerate: $pendingAutoGenerate)
                .onOpenURL { url in
                    guard url.scheme == "withopenai", url.host == "generate" else { return }
                    pendingAutoGenerate = true
                }
        }
    }
}
