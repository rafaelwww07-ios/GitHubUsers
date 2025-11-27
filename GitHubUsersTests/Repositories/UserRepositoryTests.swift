//
//  UserRepositoryTests.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import XCTest
@testable import GitHubUsers

final class UserRepositoryTests: XCTestCase {
    var repository: UserRepository!
    var mockAPIService: MockGitHubAPIService!
    var mockCacheService: MockCacheService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockGitHubAPIService()
        mockCacheService = MockCacheService()
        
        repository = UserRepository(
            apiService: mockAPIService,
            cacheService: mockCacheService
        )
    }
    
    override func tearDown() {
        repository = nil
        mockAPIService = nil
        mockCacheService = nil
        super.tearDown()
    }
    
    // MARK: - Search Users Tests
    
    func testSearchUsers_FirstPage_CachesResult() async throws {
        // Given
        let expectedUsers = [
            createTestUser(id: 1, login: "user1"),
            createTestUser(id: 2, login: "user2")
        ]
        mockAPIService.searchUsersResult = .success(expectedUsers)
        
        // When
        let users = try await repository.searchUsers(query: "test", page: 1)
        
        // Then
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(mockAPIService.searchUsersCallCount, 1)
        
        // Verify caching
        let cachedUsers: [User]? = mockCacheService.getCached([User].self, forKey: "search_test_page1")
        XCTAssertNotNil(cachedUsers)
        XCTAssertEqual(cachedUsers?.count, 2)
    }
    
    func testSearchUsers_SecondPage_DoesNotCache() async throws {
        // Given
        let expectedUsers = [createTestUser(id: 3, login: "user3")]
        mockAPIService.searchUsersResult = .success(expectedUsers)
        
        // When
        let users = try await repository.searchUsers(query: "test", page: 2)
        
        // Then
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(mockAPIService.searchUsersCallCount, 1)
        
        // Verify not cached
        let cachedUsers: [User]? = mockCacheService.getCached([User].self, forKey: "search_test_page2")
        XCTAssertNil(cachedUsers)
    }
    
    func testSearchUsers_UsesCache_WhenAvailable() async throws {
        // Given
        let cachedUsers = [
            createTestUser(id: 1, login: "cached1"),
            createTestUser(id: 2, login: "cached2")
        ]
        mockCacheService.cache(cachedUsers, forKey: "search_test_page1")
        
        // When
        let users = try await repository.searchUsers(query: "test", page: 1)
        
        // Then
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users.first?.login, "cached1")
        // API should still be called in background, but we return cached immediately
    }
    
    // MARK: - Get User Tests
    
    func testGetUser_CachesResult() async throws {
        // Given
        let expectedUser = createTestUser(id: 1, login: "testuser")
        mockAPIService.getUserResult = .success(expectedUser)
        
        // When
        let user = try await repository.getUser(username: "testuser")
        
        // Then
        XCTAssertEqual(user.login, "testuser")
        XCTAssertEqual(mockAPIService.getUserCallCount, 1)
        
        // Verify caching
        let cachedUser: User? = mockCacheService.getCached(User.self, forKey: "user_testuser")
        XCTAssertNotNil(cachedUser)
        XCTAssertEqual(cachedUser?.login, "testuser")
    }
    
    func testGetUser_UsesCache_WhenAvailable() async throws {
        // Given
        let cachedUser = createTestUser(id: 1, login: "cacheduser")
        mockCacheService.cache(cachedUser, forKey: "user_testuser")
        
        // When
        let user = try await repository.getUser(username: "testuser")
        
        // Then
        XCTAssertEqual(user.login, "cacheduser")
        // API should still be called in background
    }
    
    // MARK: - Error Handling Tests
    
    func testSearchUsers_PropagatesError() async {
        // Given
        mockAPIService.searchUsersResult = .failure(AppError.networkError("Network error"))
        
        // When/Then
        do {
            _ = try await repository.searchUsers(query: "test", page: 1)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
    
    func testGetUser_PropagatesError() async {
        // Given
        mockAPIService.getUserResult = .failure(AppError.notFound)
        
        // When/Then
        do {
            _ = try await repository.getUser(username: "testuser")
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestUser(id: Int, login: String) -> User {
        User(
            id: id,
            login: login,
            avatarURL: "https://example.com/avatar\(id).png",
            name: nil,
            company: nil,
            location: nil,
            bio: nil,
            publicRepos: 0,
            followers: 0,
            following: 0,
            htmlURL: "https://github.com/\(login)",
            blog: nil,
            createdAt: "2020-01-01T00:00:00Z"
        )
    }
}

