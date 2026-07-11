//
//  AppTheme.swift
//  With-OpenAI
//
//  Five warm, heartwarming color palettes grounded in analogous warm hues.
//

import SwiftUI

// MARK: - Theme Palette

struct ThemePalette: Equatable {
    let base: Color
    let accent: Color
    let ink: Color
    let surface: Color

    var secondary: Color { ink.opacity(0.4) }
    var border: Color { ink.opacity(0.15) }
    var overlay: Color { Color.black.opacity(0.3) }
    var shadowLight: Color { surface.opacity(0.8) }
    var shadowDark: Color { ink.opacity(0.08) }
}

// MARK: - Theme Definition

struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let palette: ThemePalette

    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Theme Catalog

enum ThemeCatalog {
    static let defaultID = "warm-glow"

    static let presets: [AppTheme] = [
        AppTheme(
            id: "warm-glow",
            name: "Warm Glow",
            description: "Soft linen and coral — like morning light through curtains.",
            palette: ThemePalette(
                base: Color(red: 0.961, green: 0.941, blue: 0.922),
                accent: Color(red: 0.910, green: 0.584, blue: 0.435),
                ink: Color(red: 0.102, green: 0.102, blue: 0.102),
                surface: Color.white
            )
        ),
        AppTheme(
            id: "honey-amber",
            name: "Honey Amber",
            description: "Golden cream and amber — the comfort of honeyed sunlight.",
            palette: ThemePalette(
                base: Color(red: 0.984, green: 0.957, blue: 0.902),
                accent: Color(red: 0.831, green: 0.627, blue: 0.337),
                ink: Color(red: 0.239, green: 0.169, blue: 0.122),
                surface: Color(red: 1.0, green: 0.992, blue: 0.973)
            )
        ),
        AppTheme(
            id: "terracotta-embrace",
            name: "Terracotta Embrace",
            description: "Clay blush and earth tones — grounded, sheltering warmth.",
            palette: ThemePalette(
                base: Color(red: 0.973, green: 0.929, blue: 0.910),
                accent: Color(red: 0.776, green: 0.482, blue: 0.361),
                ink: Color(red: 0.290, green: 0.173, blue: 0.165),
                surface: Color(red: 1.0, green: 0.980, blue: 0.969)
            )
        ),
        AppTheme(
            id: "rose-blush",
            name: "Rose Blush",
            description: "Gentle rose linen — nurturing, affectionate calm.",
            palette: ThemePalette(
                base: Color(red: 0.980, green: 0.941, blue: 0.933),
                accent: Color(red: 0.831, green: 0.518, blue: 0.478),
                ink: Color(red: 0.231, green: 0.165, blue: 0.165),
                surface: Color(red: 1.0, green: 0.988, blue: 0.984)
            )
        ),
        AppTheme(
            id: "golden-hour",
            name: "Golden Hour",
            description: "Sunlit parchment and marigold — late-afternoon optimism.",
            palette: ThemePalette(
                base: Color(red: 0.976, green: 0.945, blue: 0.890),
                accent: Color(red: 0.910, green: 0.647, blue: 0.294),
                ink: Color(red: 0.180, green: 0.149, blue: 0.094),
                surface: Color(red: 1.0, green: 0.992, blue: 0.961)
            )
        ),
    ]

    static func theme(for id: String) -> AppTheme {
        presets.first { $0.id == id } ?? presets[0]
    }
}

// MARK: - Shared Storage (App + Widget)

enum ThemeStorage {
    static let appGroupID = "group.ryofujimura.With-OpenAI"
    static let themeIDKey = "selectedThemeID"
    static let receiptMessageKey = "lastReceiptMessage"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func loadThemeID() -> String {
        sharedDefaults?.string(forKey: themeIDKey) ?? ThemeCatalog.defaultID
    }

    static func saveThemeID(_ id: String) {
        sharedDefaults?.set(id, forKey: themeIDKey)
    }

    static func loadReceiptMessage() -> String {
        sharedDefaults?.string(forKey: receiptMessageKey) ?? "Tap to receive warmth"
    }

    static func saveReceiptMessage(_ message: String) {
        sharedDefaults?.set(message, forKey: receiptMessageKey)
    }
}

// MARK: - SwiftUI Environment

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = ThemeCatalog.theme(for: ThemeCatalog.defaultID).palette
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
