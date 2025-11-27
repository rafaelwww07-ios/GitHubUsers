//
//  UserDetailViewModelTests.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import XCTest
import Combine
@testable import GitHubUsers

@MainActor
final class UserDetailViewModelTests: XCTestCase {
    var viewModel: UserDetailViewModel!
    var mockRepository: MockUserRepository!
    var mockFavoritesService: MockFavoritesService!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        mockFavoritesService = MockFavoritesService()
        
        viewModel = UserDetailViewModel(
            username: "testuser",
            repository: mockRepository,
            favoritesService: mockFavoritesService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        mockFavoritesService = nil
        super.tearDown()
    }
    
    // MARK: - Load User Tests
    
    func testLoadUser_Success() async {
        // Given
        let expectedUser = User(
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
        )
        mockRepository.getUserResult = .success(expectedUser)
        
        // When
        viewModel.loadUser()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.login, "testuser")
        XCTAssertEqual(viewModel.loadingState, .loaded)
        XCTAssertEqual(mockRepository.getUserCallCount, 1)
    }
    
    func testLoadUser_Error() async {
        // Given
        mockRepository.getUserResult = .failure(AppError.notFound)
        
        // When
        viewModel.loadUser()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNil(viewModel.user)
        if case .error(let message) = viewModel.loadingState {
            XCTAssertTrue(message.contains("not found") || message.contains("User not found"))
        } else {
            XCTFail("Expected error state")
        }
    }
    
    // MARK: - Favorites Tests
    
    func testToggleFavorite_AddToFavorites() async {
        // Given
        let user = User(
            id: 1,
            login: "testuser",
            avatarURL: "https://example.com/avatar.png",
            name: nil,
            company: nil,
            location: nil,
            bio: nil,
            publicRepos: 0,
            followers: 0,
            following: 0,
            htmlURL: "https://github.com/testuser",
            blog: nil,
            createdAt: "2020-01-01T00:00:00Z"
        )
        mockRepository.getUserResult = .success(user)
        viewModel.loadUser()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        viewModel.toggleFavorite()
        
        // Then
        XCTAssertTrue(viewModel.isFavorite)
        XCTAssertTrue(mockFavoritesService.isFavorite(user))
    }
    
    func testToggleFavorite_RemoveFromFavorites() async {
        // Given
        let user = User(
            id: 1,
            login: "testuser",
            avatarURL: "https://example.com/avatar.png",
            name: nil,
            company: nil,
            location: nil,
            bio: nil,
            publicRepos: 0,
            followers: 0,
            following: 0,
            htmlURL: "https://github.com/testuser",
            blog: nil,
            createdAt: "2020-01-01T00:00:00Z"
        )
        mockRepository.getUserResult = .success(user)
        mockFavoritesService.addToFavorites(user)
        viewModel.loadUser()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        viewModel.toggleFavorite()
        
        // Then
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertFalse(mockFavoritesService.isFavorite(user))
    }
}

