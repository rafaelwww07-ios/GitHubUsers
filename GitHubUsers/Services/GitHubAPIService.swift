//
//  GitHubAPIService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

/// Протокол для работы с GitHub API
protocol GitHubAPIServiceProtocol {
    func searchUsers(query: String, page: Int) async throws -> [User]
    func getUser(username: String) async throws -> User
    func getRepositories(username: String, sort: RepositorySort?, order: RepositoryOrder?, page: Int) async throws -> [Repository]
    func getRepository(owner: String, repo: String) async throws -> RepositoryDetail
    func searchRepositories(query: String, sort: RepositorySort?, order: RepositoryOrder?, page: Int) async throws -> (repositories: [Repository], totalCount: Int, hasMore: Bool)
}

/// Сервис для работы с GitHub API
class GitHubAPIService: GitHubAPIServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func searchUsers(query: String, page: Int = 1) async throws -> [User] {
        guard !query.isEmpty else { return [] }
        
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return [] }
        
        if isValidGitHubUsername(cleanQuery) {
            do {
                let directUser = try await getUser(username: cleanQuery)
                return [directUser]
            } catch {
                // Fallback to search
            }
        }
        
        guard cleanQuery.count >= 1 else {
            throw AppError.networkError("Search query is too short")
        }
        
        let url = APIConstants.searchURL(query: cleanQuery, page: page)
        
        do {
            let response: UserSearchResponse = try await networkService.fetch(url: url)
            
            return response.items.map { searchUser in
                User(
                    id: searchUser.id,
                    login: searchUser.login,
                    avatarURL: searchUser.avatarURL,
                    name: nil,
                    company: nil,
                    location: nil,
                    bio: nil,
                    publicRepos: 0,
                    followers: 0,
                    following: 0,
                    htmlURL: searchUser.htmlURL,
                    blog: nil,
                    createdAt: ""
                )
            }
        } catch {
            throw error
        }
    }
    
    /// Проверяет, является ли строка валидным именем пользователя GitHub
    /// GitHub username может содержать только буквы, цифры и дефисы, не может начинаться с дефиса
    private func isValidGitHubUsername(_ username: String) -> Bool {
        // GitHub username: максимум 39 символов, только буквы, цифры, дефисы
        // Не может начинаться или заканчиваться дефисом
        guard username.count <= 39,
              !username.isEmpty,
              !username.hasPrefix("-"),
              !username.hasSuffix("-") else {
            return false
        }
        
        // Проверяем, что содержит только допустимые символы
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        return username.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
    
    func getUser(username: String) async throws -> User {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUsername.isEmpty else {
            throw AppError.networkError("Username cannot be empty")
        }
        
        let url = APIConstants.userURL(username: cleanUsername)
        
        do {
            let user = try await networkService.fetch(url: url) as User
            return user
        } catch {
            throw error
        }
    }
    
    func getRepositories(username: String, sort: RepositorySort? = nil, order: RepositoryOrder? = nil, page: Int = 1) async throws -> [Repository] {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUsername.isEmpty else {
            throw AppError.networkError("Username cannot be empty")
        }
        
        let url = APIConstants.repositoriesURL(username: cleanUsername, sort: sort, order: order, page: page)
        
        do {
            let repositories: [Repository] = try await networkService.fetch(url: url)
            return repositories
        } catch {
            throw error
        }
    }
    
    func getRepository(owner: String, repo: String) async throws -> RepositoryDetail {
        let cleanOwner = owner.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRepo = repo.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanOwner.isEmpty, !cleanRepo.isEmpty else {
            throw AppError.networkError("Owner and repo names cannot be empty")
        }
        
        let url = APIConstants.repositoryURL(owner: cleanOwner, repo: cleanRepo)
        
        do {
            let repository: RepositoryDetail = try await networkService.fetch(url: url)
            return repository
        } catch {
            throw error
        }
    }
    
    func searchRepositories(query: String, sort: RepositorySort? = nil, order: RepositoryOrder? = nil, page: Int = 1) async throws -> (repositories: [Repository], totalCount: Int, hasMore: Bool) {
        guard !query.isEmpty else { return ([], 0, false) }
        
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return ([], 0, false) }
        
        let url = APIConstants.searchRepositoriesURL(query: cleanQuery, sort: sort, order: order, page: page)
        
        do {
            let response: RepositorySearchResponse = try await networkService.fetch(url: url)
            let hasMore = (page * APIConstants.perPage) < response.totalCount
            return (response.items, response.totalCount, hasMore)
        } catch {
            throw error
        }
    }
}

