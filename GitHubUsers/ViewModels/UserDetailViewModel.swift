//
//  UserDetailViewModel.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine
import UIKit

/// ViewModel для детального экрана пользователя
@MainActor
class UserDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var loadingState: LoadingState = .loading
    @Published var isFavorite: Bool = false
    
    // MARK: - Private Properties
    private let username: String
    private let repository: UserRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        username: String,
        repository: UserRepositoryProtocol = UserRepository(),
        favoritesService: FavoritesServiceProtocol = FavoritesService()
    ) {
        self.username = username
        self.repository = repository
        self.favoritesService = favoritesService
        
        setupFavoritesObserver()
        loadUser()
    }
    
    // MARK: - Setup
    private func setupFavoritesObserver() {
        favoritesService.favoritesPublisher
            .map { [weak self] favorites in
                guard let self = self, let user = self.user else { return false }
                return favorites.contains { $0.id == user.id }
            }
            .assign(to: &$isFavorite)
    }
    
    // MARK: - Public Methods
    /// Загрузка данных пользователя
    func loadUser() {
        loadingState = .loading
        
        Task {
            do {
                let loadedUser = try await repository.getUser(username: username)
                self.user = loadedUser
                self.isFavorite = favoritesService.isFavorite(loadedUser)
                self.loadingState = .loaded
            } catch {
                self.loadingState = .error(error.localizedDescription)
            }
        }
    }
    
    /// Переключение избранного
    func toggleFavorite() {
        guard let user = user else { return }
        
        if isFavorite {
            favoritesService.removeFromFavorites(user)
        } else {
            favoritesService.addToFavorites(user)
        }
    }
    
    /// Открытие профиля в Safari
    func openProfile() {
        guard let user = user,
              let url = URL(string: user.htmlURL) else { return }
        UIApplication.shared.open(url)
    }
}

