//
//  ThemeSettingsView.swift
//  With-OpenAI
//

import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject private var themeStore: ThemeStore
    @Environment(\.dismiss) private var dismiss

    private var palette: ThemePalette { themeStore.currentPalette }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Fib.s13) {
                    ForEach(ThemeCatalog.presets) { theme in
                        themeRow(theme)
                    }
                }
                .padding(Fib.s21)
            }
            .background(palette.base.ignoresSafeArea())
            .navigationTitle("Color Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: Fib.typeCaption, weight: .semibold))
                        .foregroundStyle(palette.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func themeRow(_ theme: AppTheme) -> some View {
        let isSelected = themeStore.selectedThemeID == theme.id

        return Button {
            themeStore.selectTheme(theme)
        } label: {
            HStack(spacing: Fib.s13) {
                ThemeSwatchPreview(palette: theme.palette)

                VStack(alignment: .leading, spacing: Fib.s8) {
                    Text(theme.name)
                        .font(.system(size: Fib.typeButton, weight: .semibold))
                        .foregroundStyle(theme.palette.ink)

                    Text(theme.description)
                        .font(.system(size: Fib.typeCaption))
                        .foregroundStyle(theme.palette.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: Fib.typeButton))
                        .foregroundStyle(theme.palette.accent)
                }
            }
            .padding(Fib.s13)
            .background(
                RoundedRectangle(cornerRadius: Fib.radiusCard)
                    .fill(theme.palette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Fib.radiusCard)
                            .stroke(
                                isSelected ? theme.palette.accent : theme.palette.border,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ThemeSwatchPreview: View {
    let palette: ThemePalette

    var body: some View {
        HStack(spacing: 3) {
            swatch(palette.base)
            swatch(palette.accent)
            swatch(palette.ink)
            swatch(palette.border)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: Fib.s8)
                .stroke(palette.border, lineWidth: 1)
        )
    }

    private func swatch(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: Fib.s21, height: Fib.s34)
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(ThemeStore())
}
