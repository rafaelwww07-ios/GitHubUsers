//
//  RepositoryRowView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Компонент для отображения репозитория в списке
struct RepositoryRowView: View {
    let repository: Repository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Название и полное имя
            HStack {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.accentColor)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(repository.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(repository.fullName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Описание
            if let description = repository.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Метаданные
            HStack(spacing: 16) {
                // Язык программирования
                if let language = repository.language {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(languageColor(for: language))
                            .frame(width: 8, height: 8)
                        Text(language)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Звезды
                Label("\(repository.stars)", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Форки
                Label("\(repository.forks)", systemImage: "tuningfork")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    /// Цвет для языка программирования
    private func languageColor(for language: String) -> Color {
        // Базовые цвета для популярных языков
        switch language.lowercased() {
        case "swift":
            return .orange
        case "javascript", "typescript":
            return .yellow
        case "python":
            return .blue
        case "java":
            return .red
        case "kotlin":
            return .purple
        case "go":
            return .cyan
        case "rust":
            return .orange
        case "c++", "cpp":
            return .blue
        case "c":
            return .gray
        default:
            return .gray
        }
    }
}

#Preview {
    RepositoryRowView(
        repository: Repository(
            id: 1,
            name: "awesome-project",
            fullName: "octocat/awesome-project",
            description: "An awesome project that does amazing things",
            language: "Swift",
            stars: 1234,
            forks: 56,
            htmlURL: "https://github.com/octocat/awesome-project",
            updatedAt: "2024-01-15T10:30:00Z"
        )
    )
    .padding()
}

