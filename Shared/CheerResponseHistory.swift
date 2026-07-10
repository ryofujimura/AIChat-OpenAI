//
//  CheerResponseHistory.swift
//  With-OpenAI
//

import Foundation

struct CheerHistoryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let message: String
    let emojis: [String]
    let createdAt: Date
}

enum CheerResponseHistory {
    private static let historyKey = "cheeringResponseHistory"
    private static let maxEntries = 100

    static func append(message: String, emojis: [String]) {
        guard !message.isEmpty, let defaults = CheerSharedStorage.defaults else { return }

        var entries = load()
        let entry = CheerHistoryEntry(
            id: UUID(),
            message: message,
            emojis: emojis,
            createdAt: Date()
        )
        entries.insert(entry, at: 0)

        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }

        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: historyKey)
    }

    static func load() -> [CheerHistoryEntry] {
        guard
            let defaults = CheerSharedStorage.defaults,
            let data = defaults.data(forKey: historyKey),
            let entries = try? JSONDecoder().decode([CheerHistoryEntry].self, from: data)
        else {
            return []
        }
        return entries
    }
}
