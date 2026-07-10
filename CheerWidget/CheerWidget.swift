//
//  CheerWidget.swift
//  CheerWidgetExtension
//

import WidgetKit
import SwiftUI

struct CheerEntry: TimelineEntry {
    let date: Date
    let message: String?
    let emojis: [String]
}

struct CheerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CheerEntry {
        CheerEntry(date: .now, message: "You got this!", emojis: ["✨", "💖", "🌟"])
    }

    func getSnapshot(in context: Context, completion: @escaping (CheerEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CheerEntry>) -> Void) {
        let timeline = Timeline(entries: [currentEntry()], policy: .never)
        completion(timeline)
    }

    private func currentEntry() -> CheerEntry {
        CheerEntry(
            date: .now,
            message: CheerSharedStorage.lastMessage,
            emojis: CheerSharedStorage.lastEmojis
        )
    }
}

struct CheerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: CheerSharedStorage.widgetKind,
            provider: CheerWidgetProvider()
        ) { entry in
            CheerWidgetView(entry: entry)
                .containerBackground(WidgetTheme.housing, for: .widget)
        }
        .configurationDisplayName("Cheer Me Up")
        .description("Shows your last heartwarming message. Tap to get a new one.")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}
