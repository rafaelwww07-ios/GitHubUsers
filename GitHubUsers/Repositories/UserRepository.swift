//
//  UserRepository.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

protocol UserRepositoryProtocol {
    func searchUsers(query: String, page: Int) async throws -> [User]
    func getUser(username: String) async throws -> User
}

class UserRepository: UserRepositoryProtocol {
    private let apiService: GitHubAPIServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    init(
        apiService: GitHubAPIServiceProtocol = GitHubAPIService(),
        cacheService: CacheServiceProtocol = CacheService()
    ) {
        self.apiService = apiService
        self.cacheService = cacheService
    }
    
    func searchUsers(query: String, page: Int = 1) async throws -> [User] {
        if page == 1 {
            let cacheKey = "search_\(query)_page1"
            
            if let cached: [User] = cacheService.getCached([User].self, forKey: cacheKey) {
                Task {
                    await updateCache(query: query, page: 1, cacheKey: cacheKey)
                }
                return cached
            }
        }
        
        let users = try await apiService.searchUsers(query: query, page: page)
        
        if page == 1 {
            let cacheKey = "search_\(query)_page1"
            cacheService.cache(users, forKey: cacheKey)
        }
        
        return users
    }
    
    func getUser(username: String) async throws -> User {
        let cacheKey = "user_\(username)"
        
        if let cached: User = cacheService.getCached(User.self, forKey: cacheKey) {
            Task {
                await updateUserCache(username: username, cacheKey: cacheKey)
            }
            return cached
        }
        
        let user = try await apiService.getUser(username: username)
        cacheService.cache(user, forKey: cacheKey)
        return user
    }
    
    private func updateCache(query: String, page: Int, cacheKey: String) async {
        do {
            let users = try await apiService.searchUsers(query: query, page: page)
            cacheService.cache(users, forKey: cacheKey)
        } catch {
            // Ignore background update errors
        }
    }
    
    private func updateUserCache(username: String, cacheKey: String) async {
        do {
            let user = try await apiService.getUser(username: username)
            cacheService.cache(user, forKey: cacheKey)
        } catch {
            // Ignore background update errors
        }
    }
}

