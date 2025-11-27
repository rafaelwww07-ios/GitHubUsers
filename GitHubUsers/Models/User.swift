//
//  User.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

/// Модель пользователя GitHub
struct User: Codable, Identifiable, Equatable {
    let id: Int
    let login: String
    let avatarURL: String
    let name: String?
    let company: String?
    let location: String?
    let bio: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
    let htmlURL: String
    let blog: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL = "avatar_url"
        case name
        case company
        case location
        case bio
        case publicRepos = "public_repos"
        case followers
        case following
        case htmlURL = "html_url"
        case blog
        case createdAt = "created_at"
    }
}

/// Упрощённая модель пользователя из результатов поиска
struct SearchUser: Codable {
    let id: Int
    let login: String
    let avatarURL: String
    let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

/// Модель для поиска пользователей
struct UserSearchResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [SearchUser]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}
