//
//  LaunchScreenView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background color
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Centered smile emoji
            Text("😊")
                .font(.system(size: 120))
                .scaleEffect(1.0)
        }
    }
}
