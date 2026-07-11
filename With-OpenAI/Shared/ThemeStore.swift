//
//  ThemeStore.swift
//  With-OpenAI
//

import SwiftUI
import WidgetKit

@MainActor
final class ThemeStore: ObservableObject {
    @Published var selectedThemeID: String {
        didSet {
            guard selectedThemeID != oldValue else { return }
            ThemeStorage.saveThemeID(selectedThemeID)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    var currentTheme: AppTheme {
        ThemeCatalog.theme(for: selectedThemeID)
    }

    var currentPalette: ThemePalette {
        currentTheme.palette
    }

    init() {
        selectedThemeID = ThemeStorage.loadThemeID()
    }

    func selectTheme(_ theme: AppTheme) {
        selectedThemeID = theme.id
    }
}
