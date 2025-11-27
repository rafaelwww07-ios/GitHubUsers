//
//  FavoriteRepositoriesViewModel.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine

/// ViewModel для избранных репозиториев
@MainActor
class FavoriteRepositoriesViewModel: ObservableObject {
    @Published var favorites: [Repository] = []
    
    private let favoritesService: FavoriteRepositoriesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesService: FavoriteRepositoriesServiceProtocol = FavoriteRepositoriesService.shared) {
        self.favoritesService = favoritesService
        
        // Подписываемся на изменения избранных репозиториев
        favoritesService.favorites
            .receive(on: DispatchQueue.main)
            .assign(to: &$favorites)
    }
    
    /// Удаление репозитория из избранного
    func removeFavorite(_ repository: Repository) {
        favoritesService.removeFromFavorites(repository)
    }
    
    /// Проверка, является ли репозиторий избранным
    func isFavorite(_ repository: Repository) -> Bool {
        favoritesService.isFavorite(repository)
    }
}

