//
//  NeomorphicText.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct NeomorphicText: View {
    let text: String
    let fontSize: Font
    let fontWeight: Font.Weight
    
    init(_ text: String, fontSize: Font = .largeTitle, fontWeight: Font.Weight = .bold) {
        self.text = text
        self.fontSize = fontSize
        self.fontWeight = fontWeight
    }
    
    var body: some View {
        ZStack {
            // Dark shadow (bottom-right)
            Text(text)
                .font(fontSize)
                .fontWeight(fontWeight)
                .foregroundColor(Color.black.opacity(0.3))
                .offset(x: 2, y: 2)
            
            // Light shadow (top-left)
            Text(text)
                .font(fontSize)
                .fontWeight(fontWeight)
                .foregroundColor(Color.white.opacity(0.8))
                .offset(x: -1, y: -1)
            
            // Main text
            Text(text)
                .font(fontSize)
                .fontWeight(fontWeight)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            NeomorphicText("With")
            NeomorphicText("your cheering assistant", fontSize: .title3, fontWeight: .medium)
        }
    }
} 