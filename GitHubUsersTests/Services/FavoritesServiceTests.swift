//
//  FavoritesServiceTests.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import XCTest
import Combine
@testable import GitHubUsers

final class FavoritesServiceTests: XCTestCase {
    var service: FavoritesService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        service = FavoritesService()
    }
    
    override func tearDown() {
        // Очищаем избранное
        let favorites = service.getFavorites()
        favorites.forEach { service.removeFromFavorites($0) }
        cancellables = nil
        service = nil
        super.tearDown()
    }
    
    // MARK: - Add to Favorites Tests
    
    func testAddToFavorites() {
        // Given
        let user = createTestUser(id: 1, login: "user1")
        
        // When
        service.addToFavorites(user)
        
        // Then
        XCTAssertTrue(service.isFavorite(user))
        XCTAssertEqual(service.getFavorites().count, 1)
    }
    
    func testAddToFavorites_Duplicate() {
        // Given
        let user = createTestUser(id: 1, login: "user1")
        service.addToFavorites(user)
        
        // When
        service.addToFavorites(user)
        
        // Then
        XCTAssertTrue(service.isFavorite(user))
        XCTAssertEqual(service.getFavorites().count, 1) // Should not add duplicate
    }
    
    // MARK: - Remove from Favorites Tests
    
    func testRemoveFromFavorites() {
        // Given
        let user = createTestUser(id: 1, login: "user1")
        service.addToFavorites(user)
        
        // When
        service.removeFromFavorites(user)
        
        // Then
        XCTAssertFalse(service.isFavorite(user))
        XCTAssertEqual(service.getFavorites().count, 0)
    }
    
    // MARK: - Publisher Tests
    
    func testFavoritesPublisher_EmitsOnAdd() {
        // Given
        let user = createTestUser(id: 1, login: "user1")
        let expectation = expectation(description: "Publisher emits")
        var receivedFavorites: [User] = []
        
        service.favoritesPublisher
            .sink { favorites in
                receivedFavorites = favorites
                if favorites.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        service.addToFavorites(user)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedFavorites.count, 1)
        XCTAssertEqual(receivedFavorites.first?.id, 1)
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

