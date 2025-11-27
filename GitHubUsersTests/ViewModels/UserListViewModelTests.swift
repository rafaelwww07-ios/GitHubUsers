//
//  UserListViewModelTests.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import XCTest
import Combine
@testable import GitHubUsers

@MainActor
final class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var mockRepository: MockUserRepository!
    var mockFavoritesService: MockFavoritesService!
    var mockSearchHistoryService: MockSearchHistoryService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockRepository = MockUserRepository()
        mockFavoritesService = MockFavoritesService()
        mockSearchHistoryService = MockSearchHistoryService()
        
        viewModel = UserListViewModel(
            repository: mockRepository,
            favoritesService: mockFavoritesService,
            searchHistoryService: mockSearchHistoryService
        )
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockRepository = nil
        mockFavoritesService = nil
        mockSearchHistoryService = nil
        super.tearDown()
    }
    
    // MARK: - Search Tests
    
    func testSearchUsers_Success() async {
        // Given
        let expectedUsers = [
            User(
                id: 1,
                login: "user1",
                avatarURL: "https://example.com/avatar1.png",
                name: "User One",
                company: nil,
                location: nil,
                bio: nil,
                publicRepos: 10,
                followers: 100,
                following: 50,
                htmlURL: "https://github.com/user1",
                blog: nil,
                createdAt: "2020-01-01T00:00:00Z"
            )
        ]
        mockRepository.searchUsersResult = .success(expectedUsers)
        
        // When
        viewModel.searchText = "user1"
        
        // Wait for debounce and search
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms
        
        // Then
        XCTAssertEqual(viewModel.users.count, 1)
        XCTAssertEqual(viewModel.users.first?.login, "user1")
        XCTAssertEqual(viewModel.loadingState, .loaded)
        XCTAssertEqual(mockRepository.searchUsersCallCount, 1)
    }
    
    func testSearchUsers_EmptyQuery() {
        // When
        viewModel.searchText = ""
        
        // Then
        XCTAssertEqual(viewModel.users.count, 0)
        XCTAssertEqual(viewModel.loadingState, .idle)
    }
    
    func testSearchUsers_Error() async {
        // Given
        mockRepository.searchUsersResult = .failure(AppError.networkError("Network error"))
        
        // When
        viewModel.searchText = "test"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // Then
        if case .error(let message) = viewModel.loadingState {
            XCTAssertTrue(message.contains("Network error"))
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertEqual(viewModel.users.count, 0)
    }
    
    // MARK: - Favorites Tests
    
    func testIsFavorite_ReturnsTrue() {
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
        mockFavoritesService.addToFavorites(user)
        
        // When
        let isFavorite = viewModel.isFavorite(user)
        
        // Then
        XCTAssertTrue(isFavorite)
    }
    
    func testIsFavorite_ReturnsFalse() {
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
        
        // When
        let isFavorite = viewModel.isFavorite(user)
        
        // Then
        XCTAssertFalse(isFavorite)
    }
    
    // MARK: - History Tests
    
    func testSelectHistoryItem() {
        // Given
        mockSearchHistoryService.addToHistory("testquery")
        
        // When
        viewModel.selectHistoryItem("testquery")
        
        // Then
        XCTAssertEqual(viewModel.searchText, "testquery")
        XCTAssertFalse(viewModel.showHistory)
    }
    
    func testClearHistory() {
        // Given
        mockSearchHistoryService.addToHistory("query1")
        mockSearchHistoryService.addToHistory("query2")
        
        // When
        viewModel.clearHistory()
        
        // Then
        XCTAssertEqual(viewModel.searchHistory.count, 0)
    }
    
    // MARK: - Pagination Tests
    
    func testLoadNextPage() async {
        // Given
        let firstPageUsers = (1...30).map { id in
            User(
                id: id,
                login: "user\(id)",
                avatarURL: "https://example.com/avatar\(id).png",
                name: nil,
                company: nil,
                location: nil,
                bio: nil,
                publicRepos: 0,
                followers: 0,
                following: 0,
                htmlURL: "https://github.com/user\(id)",
                blog: nil,
                createdAt: "2020-01-01T00:00:00Z"
            )
        }
        let secondPageUsers = (31...60).map { id in
            User(
                id: id,
                login: "user\(id)",
                avatarURL: "https://example.com/avatar\(id).png",
                name: nil,
                company: nil,
                location: nil,
                bio: nil,
                publicRepos: 0,
                followers: 0,
                following: 0,
                htmlURL: "https://github.com/user\(id)",
                blog: nil,
                createdAt: "2020-01-01T00:00:00Z"
            )
        }
        
        mockRepository.searchUsersResult = .success(firstPageUsers)
        viewModel.searchText = "test"
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // When
        mockRepository.searchUsersResult = .success(secondPageUsers)
        viewModel.loadNextPage()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.users.count, 60)
        XCTAssertTrue(viewModel.hasMorePages)
    }
}

