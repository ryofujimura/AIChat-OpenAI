//
//  WidgetTheme.swift
//  With-OpenAI
//

import SwiftUI

enum WidgetTheme {
    static let base = Color(red: 0.961, green: 0.941, blue: 0.922)
    static let accent = Color(red: 0.910, green: 0.584, blue: 0.435)
    static let ink = Color(red: 0.102, green: 0.102, blue: 0.102)
    static let surface = Color.white
    static let housing = Color(red: 0.18, green: 0.17, blue: 0.16)
    static let housingRim = Color(red: 0.28, green: 0.26, blue: 0.24)
    static let accentHighlight = Color(red: 0.98, green: 0.74, blue: 0.58)
    static let accentShadow = Color(red: 0.72, green: 0.40, blue: 0.26)
    static let surfaceHighlight = Color.white
    static let surfaceShadow = Color(red: 0.88, green: 0.86, blue: 0.84)
}

struct WidgetArcadeButtonFace: View {
    let message: String?
    let cornerRadius: CGFloat

    private var hasMessage: Bool {
        guard let message, !message.isEmpty else { return false }
        return true
    }

    var body: some View {
        GeometryReader { geometry in
            let inset = min(geometry.size.width, geometry.size.height) * 0.06

            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [WidgetTheme.housingRim, WidgetTheme.housing],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: faceColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(alignment: .top) {
                        Ellipse()
                            .fill(Color.white.opacity(hasMessage ? 0.25 : 0.45))
                            .frame(height: cornerRadius * 0.9)
                            .padding(.horizontal, inset * 2)
                            .padding(.top, inset)
                    }
                    .padding(inset)

                Group {
                    if hasMessage {
                        WidgetCheerMessageText(
                            message: message ?? "",
                            fontSize: min(geometry.size.width * 0.11, 34)
                        )
                        .padding(inset * 2.2)
                    } else {
                        VStack(spacing: inset * 0.4) {
                            Text("👇")
                                .font(.system(size: min(geometry.size.width * 0.18, 40)))
                            Text("Tap Here")
                                .font(.system(size: min(geometry.size.width * 0.09, 21), weight: .bold))
                                .foregroundStyle(WidgetTheme.surface)
                        }
                    }
                }
                .padding(inset * 1.5)
            }
        }
    }

    private var faceColors: [Color] {
        if hasMessage {
            return [WidgetTheme.surfaceHighlight, WidgetTheme.surface, WidgetTheme.surfaceShadow]
        }
        return [WidgetTheme.accentHighlight, WidgetTheme.accent, WidgetTheme.accentShadow]
    }
}

struct WidgetCheerMessageText: View {
    let message: String
    let fontSize: CGFloat

    private var lines: [String] {
        MessageFormatting.normalizedLines(from: message)
    }

    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundStyle(WidgetTheme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
