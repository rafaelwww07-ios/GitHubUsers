//
//  UserDetailView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Детальный экран пользователя
struct UserDetailView: View {
    let username: String
    @StateObject private var viewModel: UserDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(username: String) {
        self.username = username
        _viewModel = StateObject(wrappedValue: UserDetailViewModel(username: username))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch viewModel.loadingState {
                case .loading:
                    LoadingView()
                        .frame(height: 400)
                    
                case .loaded:
                    if let user = viewModel.user {
                        userContent(user: user)
                    }
                    
                case .error(let message):
                    ErrorView(message: message) {
                        viewModel.loadUser()
                    }
                    .frame(height: 400)
                    
                case .idle:
                    EmptyView()
                }
            }
        }
        .navigationTitle(viewModel.user?.login ?? "User")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if let user = viewModel.user {
                    // Share button
                    ShareLink(item: URL(string: user.htmlURL)!) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                    // Favorite button
                    Button(action: {
                        viewModel.toggleFavorite()
                        if viewModel.isFavorite {
                            HapticFeedbackManager.shared.success()
                        } else {
                            HapticFeedbackManager.shared.light()
                        }
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorite ? .red : .primary)
                    }
                    .accessibilityLabel(viewModel.isFavorite ? "Remove from favorites" : "Add to favorites")
                    .accessibilityHint("Double tap to toggle favorite status")
                }
            }
        }
    }
    
    // MARK: - User Content
    @ViewBuilder
    private func userContent(user: User) -> some View {
        VStack(spacing: 24) {
            // Аватар с кэшированием
            CachedAsyncImage(url: user.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
            .shadow(radius: 10)
            .padding(.top, 20)
            .accessibilityLabel("user.avatar".localized)
            .accessibilityHint(user.login)
            
            // Основная информация
            VStack(spacing: 8) {
                Text(user.login)
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                
                if let name = user.name {
                    Text(name)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            
            // Статистика
            HStack(spacing: 30) {
                NavigationLink(destination: RepositoryListView(username: user.login)) {
                    VStack(spacing: 8) {
                        Image(systemName: "folder")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        
                        Text("\(user.publicRepos)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 4) {
                        Text("user.repos".localized)
                            .font(.caption)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8))
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                StatView(
                    value: "\(user.followers)",
                    label: "user.followers".localized,
                    icon: "person.2"
                )
                
                StatView(
                    value: "\(user.following)",
                    label: "user.following".localized,
                    icon: "person"
                )
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // График статистики (опционально, если есть данные)
            if user.publicRepos > 0 || user.followers > 0 || user.following > 0 {
                UserStatsChartView(user: user)
            }
            
            Divider()
                .padding(.horizontal)
            
            // Дополнительная информация
            VStack(alignment: .leading, spacing: 16) {
                if let company = user.company {
                    InfoRow(icon: "building.2", text: company)
                }
                
                if let location = user.location {
                    InfoRow(icon: "location", text: location)
                }
                
                if let bio = user.bio {
                    InfoRow(icon: "text.alignleft", text: bio)
                }
                
                if let blog = user.blog, !blog.isEmpty {
                    InfoRow(icon: "link", text: blog)
                }
            }
            .padding(.horizontal)
            
            // Кнопка открытия профиля
            Button(action: {
                viewModel.openProfile()
                HapticFeedbackManager.shared.medium()
            }) {
                HStack {
                    Image(systemName: "safari")
                    Text("user.open.profile".localized)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            .accessibilityLabel("user.open.profile".localized)
            .accessibilityHint("Opens user profile in Safari")
        }
    }
}

// MARK: - Stat View
struct StatView: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        UserDetailView(username: "octocat")
    }
}

