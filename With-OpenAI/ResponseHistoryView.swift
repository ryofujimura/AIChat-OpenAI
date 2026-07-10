//
//  ResponseHistoryView.swift
//  With-OpenAI
//

import SwiftUI

struct ResponseHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    private let entries = CheerResponseHistory.load()

    var body: some View {
        NavigationStack {
            ZStack {
                WarmGlow.base
                    .ignoresSafeArea()

                if entries.isEmpty {
                    Text("No responses yet")
                        .font(.system(size: Fib.typeCaption))
                        .foregroundStyle(WarmGlow.secondary)
                } else {
                    ScrollView {
                        LazyVStack(spacing: Fib.s13) {
                            ForEach(entries) { entry in
                                historyCard(entry)
                            }
                        }
                        .padding(Fib.s21)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(WarmGlow.accent)
                }
            }
        }
    }

    private func historyCard(_ entry: CheerHistoryEntry) -> some View {
        ArcadePanel(cornerRadius: Fib.radiusCard) {
            VStack(alignment: .leading, spacing: Fib.s13) {
                CheerMessageText(message: entry.message, fontSize: Fib.typeButton)

                if !entry.emojis.isEmpty {
                    HStack(spacing: Fib.s8) {
                        ForEach(entry.emojis.indices, id: \.self) { index in
                            Text(entry.emojis[index])
                                .font(.system(size: Fib.typeButton))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: Fib.typeCaption))
                    .foregroundStyle(WarmGlow.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#Preview {
    ResponseHistoryView()
}
