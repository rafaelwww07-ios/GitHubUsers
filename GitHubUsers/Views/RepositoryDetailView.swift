//
//  RepositoryDetailView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Детальный экран репозитория
struct RepositoryDetailView: View {
    let owner: String
    let repo: String
    @StateObject private var viewModel: RepositoryDetailViewModel
    
    init(owner: String, repo: String) {
        self.owner = owner
        self.repo = repo
        _viewModel = StateObject(wrappedValue: RepositoryDetailViewModel(owner: owner, repo: repo))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch viewModel.loadingState {
                case .loading:
                    LoadingView()
                        .frame(height: 400)
                    
                case .loaded:
                    if let repository = viewModel.repository {
                        repositoryContent(repository: repository)
                    }
                    
                case .error(let message):
                    ErrorView(message: message) {
                        viewModel.loadRepository()
                    }
                    .frame(height: 400)
                    
                case .idle:
                    EmptyView()
                }
            }
        }
        .navigationTitle(viewModel.repository?.name ?? repo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if let repository = viewModel.repository {
                    ShareLink(item: URL(string: repository.htmlURL)!) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    // MARK: - Repository Content
    @ViewBuilder
    private func repositoryContent(repository: RepositoryDetail) -> some View {
        VStack(spacing: 24) {
            // Заголовок
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(repository.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(repository.fullName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Описание
                if let description = repository.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Статистика
            HStack(spacing: 20) {
                StatItem(value: "\(repository.stars)", label: "repo.stars".localized, icon: "star.fill")
                StatItem(value: "\(repository.forks)", label: "repo.forks".localized, icon: "tuningfork")
                StatItem(value: "\(repository.watchers)", label: "repo.watchers".localized, icon: "eye")
                StatItem(value: "\(repository.openIssuesCount)", label: "repo.issues".localized, icon: "exclamationmark.circle")
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // Основная информация
            VStack(alignment: .leading, spacing: 16) {
                // Язык
                if let language = repository.language {
                    RepositoryInfoRow(icon: "circle.fill", text: language, color: .accentColor)
                }
                
                // Лицензия
                if let license = repository.license {
                    RepositoryInfoRow(icon: "doc.text", text: license.name)
                }
                
                // Домашняя страница
                if let homepage = repository.homepage, !homepage.isEmpty {
                    RepositoryInfoRow(icon: "house", text: homepage)
                }
                
                // Размер
                RepositoryInfoRow(icon: "internaldrive", text: viewModel.formatSize(repository.size))
                
                // Ветка по умолчанию
                RepositoryInfoRow(icon: "git.branch", text: repository.defaultBranch)
                
                // Статусы
                if repository.isPrivate {
                    RepositoryInfoRow(icon: "lock.fill", text: "repo.detail.private".localized, color: .orange)
                }
                
                if repository.isArchived {
                    RepositoryInfoRow(icon: "archivebox.fill", text: "repo.detail.archived".localized, color: .gray)
                }
                
                if repository.isFork {
                    RepositoryInfoRow(icon: "arrow.triangle.branch", text: "repo.detail.fork".localized, color: .blue)
                }
            }
            .padding(.horizontal)
            
            // Даты
            VStack(alignment: .leading, spacing: 12) {
                Text("repo.detail.dates".localized)
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    DateRow(label: "repo.detail.created".localized, date: viewModel.formatDate(repository.createdAt))
                    DateRow(label: "repo.detail.updated".localized, date: viewModel.formatDate(repository.updatedAt))
                    if let pushedAt = repository.pushedAt {
                        DateRow(label: "repo.detail.pushed".localized, date: viewModel.formatDate(pushedAt))
                    }
                }
                .padding(.horizontal)
            }
            
            // Топики
            if !repository.topics.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("repo.detail.topics".localized)
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(repository.topics, id: \.self) { topic in
                                Text(topic)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.1))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Кнопки действий
            VStack(spacing: 12) {
                Button(action: { viewModel.openInSafari() }) {
                    HStack {
                        Image(systemName: "safari")
                        Text("Open in Safari")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                if let cloneURL = URL(string: repository.cloneURL) {
                    ShareLink(item: cloneURL) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Clone URL")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Date Row
struct DateRow: View {
    let label: String
    let date: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(date)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Repository Info Row (с поддержкой цвета)
struct RepositoryInfoRow: View {
    let icon: String
    let text: String
    var color: Color = .accentColor
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        RepositoryDetailView(owner: "apple", repo: "swift")
    }
}

