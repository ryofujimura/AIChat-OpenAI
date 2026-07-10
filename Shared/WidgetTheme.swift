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
            let inset = min(geometry.size.width, geometry.size.height) * 0.028
            let innerSize = CGSize(
                width: geometry.size.width - inset * 2,
                height: geometry.size.height - inset * 2
            )
            let innerShape = RoundedRectangle(cornerRadius: cornerRadius)

            ZStack {
                // Square outer housing — sharp corners on the outside
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [WidgetTheme.housingRim, WidgetTheme.housing],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                ZStack {
                    innerShape
                        .fill(
                            LinearGradient(
                                colors: faceColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    if hasMessage, !emojis.isEmpty {
                        WidgetEmojiBackground(emojis: emojis, size: innerSize)
                            .clipShape(innerShape)
                    }

                    Group {
                        if hasMessage {
                            WidgetCheerMessageText(
                                message: message ?? "",
                                fontSize: min(geometry.size.width * 0.12, 36)
                            )
                            .padding(.horizontal, inset * 0.8)
                            .padding(.vertical, inset * 0.4)
                        } else {
                            VStack(spacing: inset * 0.3) {
                                Text("👇")
                                    .font(.system(size: min(geometry.size.width * 0.2, 44)))
                                Text("Tap Here")
                                    .font(.system(size: min(geometry.size.width * 0.1, 23), weight: .bold))
                                    .foregroundStyle(WidgetTheme.surface)
                            }
                        }
                    }
                }
                .padding(inset)
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

struct WidgetEmojiBackground: View {
    let emojis: [String]
    let size: CGSize

    private var tiledEmojis: [WidgetEmojiPlacement] {
        guard !emojis.isEmpty else { return [] }

        let columns = 4
        let rows = 5
        var placements: [WidgetEmojiPlacement] = []
        var index = 0

        for row in 0..<rows {
            for col in 0..<columns {
                let stagger = row.isMultiple(of: 2) ? 0.0 : 0.14
                let xFraction = (CGFloat(col) + 0.5 + stagger) / CGFloat(columns)
                let yFraction = (CGFloat(row) + 0.5) / CGFloat(rows)
                let scale = 0.92 + CGFloat(index % 4) * 0.08
                let rotation = Double((index % 8) * 9 - 28)

                placements.append(
                    WidgetEmojiPlacement(
                        emoji: emojis[index % emojis.count],
                        x: xFraction * size.width,
                        y: yFraction * size.height,
                        scale: scale,
                        rotation: rotation
                    )
                )
                index += 1
            }
        }

        return placements
    }

    var body: some View {
        ZStack {
            ForEach(Array(tiledEmojis.enumerated()), id: \.offset) { _, placement in
                Text(placement.emoji)
                    .font(.system(size: size.width * 0.44 * placement.scale))
                    .opacity(0.15)
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
