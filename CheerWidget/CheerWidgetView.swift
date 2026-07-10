//
//  CheerWidgetView.swift
//  CheerWidgetExtension
//

import SwiftUI
import WidgetKit

struct CheerWidgetView: View {
    let entry: CheerEntry

    var body: some View {
        WidgetArcadeButtonFace(
            message: entry.message,
            emojis: entry.emojis,
            cornerRadius: 28
        )
        .widgetURL(CheerSharedStorage.generateURL)
    }
}

#Preview(as: .systemLarge) {
    CheerWidget()
} timeline: {
    CheerEntry(date: .now, message: "Keep going!", emojis: ["🌟", "💪", "😊"])
    CheerEntry(date: .now, message: nil, emojis: [])
}
