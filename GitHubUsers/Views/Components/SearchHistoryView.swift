//
//  SearchHistoryView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Компонент для отображения истории поиска
struct SearchHistoryView: View {
    let history: [String]
    let onSelect: (String) -> Void
    let onRemove: (String) -> Void
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок
            HStack {
                Label("search.recent".localized, systemImage: "clock.arrow.circlepath")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !history.isEmpty {
                    Button("search.clear".localized) {
                        onClear()
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 4)
            
            // Список истории
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(history, id: \.self) { query in
                        HistoryChip(
                            text: query,
                            onTap: {
                                onSelect(query)
                            },
                            onRemove: {
                                onRemove(query)
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Чип для отображения элемента истории
struct HistoryChip: View {
    let text: String
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.subheadline)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    SearchHistoryView(
        history: ["octocat", "swift", "github"],
        onSelect: { _ in },
        onRemove: { _ in },
        onClear: {}
    )
    .padding()
}

