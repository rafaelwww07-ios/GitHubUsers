//
//  MockUserRepository.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
@testable import GitHubUsers

/// Мок для UserRepository для тестирования
class MockUserRepository: UserRepositoryProtocol {
    var searchUsersResult: Result<[User], Error> = .success([])
    var getUserResult: Result<User, Error> = .success(User(
        id: 1,
        login: "testuser",
        avatarURL: "https://example.com/avatar.png",
        name: "Test User",
        company: nil,
        location: nil,
        bio: nil,
        publicRepos: 10,
        followers: 100,
        following: 50,
        htmlURL: "https://github.com/testuser",
        blog: nil,
        createdAt: "2020-01-01T00:00:00Z"
    ))
    
    var searchUsersCallCount = 0
    var getUserCallCount = 0
    
    func searchUsers(query: String, page: Int) async throws -> [User] {
        searchUsersCallCount += 1
        switch searchUsersResult {
        case .success(let users):
            return users
        case .failure(let error):
            throw error
        }
    }
    
    func getUser(username: String) async throws -> User {
        getUserCallCount += 1
        switch getUserResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        }
    }
}

