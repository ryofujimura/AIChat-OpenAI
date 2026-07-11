//
//  ReceiptWidget.swift
//  ReceiptWidget
//

import WidgetKit
import SwiftUI

struct ReceiptEntry: TimelineEntry {
    let date: Date
    let message: String
    let palette: ThemePalette
    let themeName: String
}

struct ReceiptTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReceiptEntry {
        ReceiptEntry(
            date: Date(),
            message: "You are enough.",
            palette: ThemeCatalog.presets[0].palette,
            themeName: ThemeCatalog.presets[0].name
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ReceiptEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReceiptEntry>) -> Void) {
        let entry = makeEntry()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func makeEntry() -> ReceiptEntry {
        let themeID = ThemeStorage.loadThemeID()
        let theme = ThemeCatalog.theme(for: themeID)
        return ReceiptEntry(
            date: Date(),
            message: ThemeStorage.loadReceiptMessage(),
            palette: theme.palette,
            themeName: theme.name
        )
    }
}

struct ReceiptWidgetEntryView: View {
    let entry: ReceiptEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Fib.s8) {
            Text("Receipt")
                .font(.system(size: Fib.typeCaption, weight: .semibold))
                .foregroundStyle(entry.palette.secondary)

            Text(entry.message)
                .font(.system(size: Fib.typeButton, weight: .regular))
                .foregroundStyle(entry.palette.ink)
                .lineLimit(4)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            Text(entry.themeName)
                .font(.system(size: Fib.s8 + 2, weight: .medium))
                .foregroundStyle(entry.palette.accent)
        }
        .padding(Fib.s13)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(entry.palette.base)
        .overlay(
            RoundedRectangle(cornerRadius: Fib.radiusCard)
                .stroke(entry.palette.border, lineWidth: 1)
        )
    }
}

struct ReceiptWidget: Widget {
    let kind: String = "ReceiptWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReceiptTimelineProvider()) { entry in
            ReceiptWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    entry.palette.base
                }
        }
        .configurationDisplayName("Receipt")
        .description("Your latest heartwarming message, styled in your chosen theme.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    ReceiptWidget()
} timeline: {
    ReceiptEntry(
        date: Date(),
        message: "You shine brighter than you know.",
        palette: ThemeCatalog.presets[0].palette,
        themeName: "Warm Glow"
    )
}
