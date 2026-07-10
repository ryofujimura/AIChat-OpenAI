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
    static let widgetKind = "CheerWidget"
    static let generateURL = URL(string: "withopenai://generate")!

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static var lastMessage: String? {
        defaults?.string(forKey: lastMessageKey)
    }

    static func saveLastMessage(_ message: String) {
        defaults?.set(message, forKey: lastMessageKey)
        reloadWidget()
    }

    static func reloadWidget() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        #endif
    }
}
