//
//  MockGitHubAPIService.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
@testable import GitHubUsers

/// Мок для GitHubAPIService для тестирования
class MockGitHubAPIService: GitHubAPIServiceProtocol {
    var searchUsersResult: Result<[User], Error> = .success([])
    var getUserResult: Result<User, Error> = .success(User(
        id: 1,
        login: "testuser",
        avatarURL: "https://example.com/avatar.png",
        name: "Test User",
        company: "Test Company",
        location: "Test Location",
        bio: "Test Bio",
        publicRepos: 10,
        followers: 100,
        following: 50,
        htmlURL: "https://github.com/testuser",
        blog: "https://testuser.com",
        createdAt: "2020-01-01T00:00:00Z"
    ))
    var getRepositoriesResult: Result<[Repository], Error> = .success([])
    var getRepositoryResult: Result<RepositoryDetail, Error> = .success(RepositoryDetail(
        id: 1,
        name: "test-repo",
        fullName: "testuser/test-repo",
        description: "Test repository",
        language: "Swift",
        stars: 100,
        forks: 10,
        watchers: 50,
        htmlURL: "https://github.com/testuser/test-repo",
        cloneURL: "https://github.com/testuser/test-repo.git",
        defaultBranch: "main",
        createdAt: "2020-01-01T00:00:00Z",
        updatedAt: "2024-01-01T00:00:00Z",
        pushedAt: "2024-01-01T00:00:00Z",
        homepage: nil,
        topics: ["swift", "ios"],
        license: License(key: "mit", name: "MIT License", spdxId: "MIT", url: "https://opensource.org/licenses/MIT"),
        owner: RepositoryOwner(login: "testuser", avatarURL: "https://example.com/avatar.png", htmlURL: "https://github.com/testuser"),
        isPrivate: false,
        isArchived: false,
        isFork: false,
        openIssuesCount: 5,
        size: 1024
    ))
    
    var searchUsersCallCount = 0
    var getUserCallCount = 0
    var getRepositoriesCallCount = 0
    var getRepositoryCallCount = 0
    
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
    
    func getRepositories(username: String, sort: RepositorySort?, order: RepositoryOrder?, page: Int) async throws -> [Repository] {
        getRepositoriesCallCount += 1
        switch getRepositoriesResult {
        case .success(let repos):
            return repos
        case .failure(let error):
            throw error
        }
    }
    
    func getRepository(owner: String, repo: String) async throws -> RepositoryDetail {
        getRepositoryCallCount += 1
        switch getRepositoryResult {
        case .success(let repo):
            return repo
        case .failure(let error):
            throw error
        }
    }
}

