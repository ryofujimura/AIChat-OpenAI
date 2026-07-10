//
//  MessageFormatting.swift
//  With-OpenAI
//

import Foundation

enum MessageFormatting {
    static func normalizedLines(from text: String) -> [String] {
        let normalized = normalize(text)
        return normalized
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    static func normalize(_ text: String) -> String {
        var result = strippingQuotations(from: text)
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        result = result
            .components(separatedBy: "\n")
            .map { line in
                line.split(whereSeparator: \.isWhitespace).joined(separator: " ")
            }
            .joined(separator: "\n")

        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func strippingQuotations(from text: String) -> String {
        let removableDoubles: Set<Character> = ["\"", "\u{201C}", "\u{201D}", "\u{00AB}", "\u{00BB}"]
        let wrappingSingles: Set<Character> = ["'", "\u{2018}", "\u{2019}"]

        var result = String(text.filter { !removableDoubles.contains($0) })
        var trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)

        while trimmed.count >= 2,
              let first = trimmed.first,
              let last = trimmed.last,
              wrappingSingles.contains(first),
              wrappingSingles.contains(last) {
            trimmed = String(trimmed.dropFirst().dropLast())
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        while let first = trimmed.first, wrappingSingles.contains(first) {
            trimmed = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        while let last = trimmed.last, wrappingSingles.contains(last) {
            trimmed = String(trimmed.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return trimmed
    }
}
