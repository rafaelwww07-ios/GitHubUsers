//
//  UserRowView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Компонент для отображения пользователя в списке
struct UserRowView: View {
    let user: User
    let isFavorite: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Аватар с кэшированием
            CachedAsyncImage(url: user.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .accessibilityLabel("user.avatar".localized)
            .accessibilityHint("user.\(user.login)")
            
            // Информация
            VStack(alignment: .leading, spacing: 4) {
                Text(user.login)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                
                if let name = user.name {
                    Text(name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                
                HStack(spacing: 16) {
                    if user.publicRepos > 0 || user.followers > 0 {
                        if user.publicRepos > 0 {
                            Label("\(user.publicRepos)", systemImage: "folder")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if user.followers > 0 {
                            Label("\(user.followers)", systemImage: "person.2")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("repo.tap.details".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            
            Spacer()
            
            // Иконка избранного
            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    UserRowView(
        user: User(
            id: 1,
            login: "octocat",
            avatarURL: "https://github.com/images/error/octocat_happy.gif",
            name: "The Octocat",
            company: "GitHub",
            location: "San Francisco",
            bio: nil,
            publicRepos: 8,
            followers: 1000,
            following: 9,
            htmlURL: "https://github.com/octocat",
            blog: nil,
            createdAt: "2011-01-25T18:44:36Z"
        ),
        isFavorite: true
    )
    .padding()
}

