//
//  Repository.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

/// Модель репозитория GitHub
struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let language: String?
    let stars: Int
    let forks: Int
    let htmlURL: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case language
        case stars = "stargazers_count"
        case forks
        case htmlURL = "html_url"
        case updatedAt = "updated_at"
    }
}

/// Детальная модель репозитория с полной информацией
struct RepositoryDetail: Codable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let language: String?
    let stars: Int
    let forks: Int
    let watchers: Int
    let htmlURL: String
    let cloneURL: String
    let defaultBranch: String
    let createdAt: String
    let updatedAt: String
    let pushedAt: String?
    let homepage: String?
    let topics: [String]
    let license: License?
    let owner: RepositoryOwner
    let isPrivate: Bool
    let isArchived: Bool
    let isFork: Bool
    let openIssuesCount: Int
    let size: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case language
        case stars = "stargazers_count"
        case forks
        case watchers
        case htmlURL = "html_url"
        case cloneURL = "clone_url"
        case defaultBranch = "default_branch"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case homepage
        case topics
        case license
        case owner
        case isPrivate = "private"
        case isArchived = "archived"
        case isFork = "fork"
        case openIssuesCount = "open_issues_count"
        case size
    }
}

/// Модель лицензии репозитория
struct License: Codable {
    let key: String
    let name: String
    let spdxId: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case spdxId = "spdx_id"
        case url
    }
}

/// Модель владельца репозитория
struct RepositoryOwner: Codable {
    let login: String
    let avatarURL: String
    let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

/// Модель ответа поиска репозиториев
struct RepositorySearchResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

