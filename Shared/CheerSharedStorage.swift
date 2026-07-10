//
//  CheerSharedStorage.swift
//  With-OpenAI
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

enum CheerSharedStorage {
    static let appGroupID = "group.ryofujimura.With-OpenAI"
    static let lastMessageKey = "lastCheeringMessage"
    static let lastEmojisKey = "lastCheeringEmojis"
    static let widgetKind = "CheerWidget"
    static let generateURL = URL(string: "withopenai://generate")!

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static var lastMessage: String? {
        defaults?.string(forKey: lastMessageKey)
    }

    static var lastEmojis: [String] {
        guard let data = defaults?.data(forKey: lastEmojisKey),
              let emojis = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return emojis
    }

    static func saveLastResponse(message: String, emojis: [String]) {
        defaults?.set(message, forKey: lastMessageKey)
        if let data = try? JSONEncoder().encode(emojis) {
            defaults?.set(data, forKey: lastEmojisKey)
        } else {
            defaults?.removeObject(forKey: lastEmojisKey)
        }
        reloadWidget()
    }

    static func reloadWidget() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        #endif
    }
}
