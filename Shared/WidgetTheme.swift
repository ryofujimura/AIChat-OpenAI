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
    let emojis: [String]
    let cornerRadius: CGFloat

    private var hasMessage: Bool {
        guard let message, !message.isEmpty else { return false }
        return true
    }

    var body: some View {
        GeometryReader { geometry in
            let inset = min(geometry.size.width, geometry.size.height) * 0.06

            ZStack {
                WidgetEmojiBackground(emojis: emojis, size: geometry.size)

                // Square outer housing — sharp corners on the outside
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [WidgetTheme.housingRim, WidgetTheme.housing],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Inner plunger keeps rounded corners; slightly translucent when emojis show through
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: faceColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(innerFaceOpacity)
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

    private var innerFaceOpacity: Double {
        hasMessage && !emojis.isEmpty ? 0.84 : 1.0
    }
}

struct WidgetEmojiBackground: View {
    let emojis: [String]
    let size: CGSize

    private var tiledEmojis: [WidgetEmojiPlacement] {
        guard !emojis.isEmpty else { return [] }

        var expanded: [String] = []
        while expanded.count < 9 {
            expanded.append(contentsOf: emojis)
        }

        let anchors: [(CGFloat, CGFloat, CGFloat, Double)] = [
            (0.12, 0.16, 0.72, -18),
            (0.82, 0.14, 0.68, 14),
            (0.48, 0.46, 0.88, -8),
            (0.10, 0.58, 0.64, 22),
            (0.88, 0.56, 0.70, -12),
            (0.30, 0.86, 0.60, 10),
            (0.72, 0.84, 0.66, -16),
            (0.50, 0.12, 0.58, 6),
            (0.22, 0.38, 0.54, 18),
        ]

        return anchors.enumerated().map { index, anchor in
            WidgetEmojiPlacement(
                emoji: expanded[index % expanded.count],
                x: anchor.0 * size.width,
                y: anchor.1 * size.height,
                scale: anchor.2,
                rotation: anchor.3
            )
        }
    }

    var body: some View {
        ZStack {
            ForEach(Array(tiledEmojis.enumerated()), id: \.offset) { _, placement in
                Text(placement.emoji)
                    .font(.system(size: size.width * 0.38 * placement.scale))
                    .opacity(0.16)
                    .rotationEffect(.degrees(placement.rotation))
                    .position(x: placement.x, y: placement.y)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct WidgetEmojiPlacement {
    let emoji: String
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat
    let rotation: Double
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
