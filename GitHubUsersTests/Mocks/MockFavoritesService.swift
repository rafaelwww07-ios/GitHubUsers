//
//  MockFavoritesService.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine
@testable import GitHubUsers

/// Мок для FavoritesService для тестирования
class MockFavoritesService: FavoritesServiceProtocol {
    private let favoritesSubject = CurrentValueSubject<[User], Never>([])
    
    var favoritesPublisher: AnyPublisher<[User], Never> {
        favoritesSubject.eraseToAnyPublisher()
    }
    
    private var favorites: [User] = []
    
    func addToFavorites(_ user: User) {
        if !favorites.contains(where: { $0.id == user.id }) {
            favorites.append(user)
            favoritesSubject.send(favorites)
        }
    }
    
    func removeFromFavorites(_ user: User) {
        favorites.removeAll { $0.id == user.id }
        favoritesSubject.send(favorites)
    }
    
    func isFavorite(_ user: User) -> Bool {
        favorites.contains { $0.id == user.id }
    }
    
    func getFavorites() -> [User] {
        favorites
    }
}

