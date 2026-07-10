//
//  CheerWidget.swift
//  CheerWidgetExtension
//

import WidgetKit
import SwiftUI

struct CheerEntry: TimelineEntry {
    let date: Date
    let message: String?
}

struct CheerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CheerEntry {
        CheerEntry(date: .now, message: "You got this!")
    }

    func getSnapshot(in context: Context, completion: @escaping (CheerEntry) -> Void) {
        completion(CheerEntry(date: .now, message: CheerSharedStorage.lastMessage))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CheerEntry>) -> Void) {
        let entry = CheerEntry(date: .now, message: CheerSharedStorage.lastMessage)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CheerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: CheerSharedStorage.widgetKind,
            provider: CheerWidgetProvider()
        ) { entry in
            CheerWidgetView(entry: entry)
                .containerBackground(WidgetTheme.base, for: .widget)
        }
        .configurationDisplayName("Cheer Me Up")
        .description("Shows your last heartwarming message. Tap to get a new one.")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}
