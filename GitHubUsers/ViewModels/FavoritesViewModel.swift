//
//  FavoritesViewModel.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine

/// ViewModel для экрана избранных пользователей
@MainActor
class FavoritesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var favorites: [User] = []
    
    // MARK: - Private Properties
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(favoritesService: FavoritesServiceProtocol = FavoritesService()) {
        self.favoritesService = favoritesService
        setupObserver()
        loadFavorites()
    }
    
    // MARK: - Setup
    private func setupObserver() {
        favoritesService.favoritesPublisher
            .assign(to: &$favorites)
    }
    
    // MARK: - Public Methods
    /// Загрузка избранных
    func loadFavorites() {
        favorites = favoritesService.getFavorites()
    }
    
    /// Удаление из избранного
    func removeFavorite(_ user: User) {
        favoritesService.removeFromFavorites(user)
    }
}

