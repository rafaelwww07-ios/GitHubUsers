//
//  FavoriteRepositoriesService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine

/// Протокол для работы с избранными репозиториями
protocol FavoriteRepositoriesServiceProtocol {
    var favorites: AnyPublisher<[Repository], Never> { get }
    func addToFavorites(_ repository: Repository)
    func removeFromFavorites(_ repository: Repository)
    func isFavorite(_ repository: Repository) -> Bool
    func getAllFavorites() -> [Repository]
}

/// Сервис для управления избранными репозиториями
class FavoriteRepositoriesService: FavoriteRepositoriesServiceProtocol {
    static let shared = FavoriteRepositoriesService()
    
    private let userDefaults: UserDefaults
    private let favoritesSubject: CurrentValueSubject<[Repository], Never>
    private let favoritesKey = "favoriteRepositories"
    
    var favorites: AnyPublisher<[Repository], Never> {
        favoritesSubject.eraseToAnyPublisher()
    }
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // Загружаем избранные репозитории напрямую в инициализаторе
        let loadedFavorites: [Repository]
        if let data = userDefaults.data(forKey: favoritesKey),
           let repositories = try? JSONDecoder().decode([Repository].self, from: data) {
            loadedFavorites = repositories
        } else {
            loadedFavorites = []
        }
        
        self.favoritesSubject = CurrentValueSubject(loadedFavorites)
    }
    
    /// Загрузка избранных репозиториев из UserDefaults
    private func loadFavorites() -> [Repository] {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let repositories = try? JSONDecoder().decode([Repository].self, from: data) else {
            return []
        }
        return repositories
    }
    
    /// Сохранение избранных репозиториев в UserDefaults
    private func saveFavorites(_ repositories: [Repository]) {
        if let data = try? JSONEncoder().encode(repositories) {
            userDefaults.set(data, forKey: favoritesKey)
            favoritesSubject.send(repositories)
        }
    }
    
    /// Добавление репозитория в избранное
    func addToFavorites(_ repository: Repository) {
        var currentFavorites = loadFavorites()
        
        // Проверяем, что репозитория еще нет в избранном
        if !currentFavorites.contains(where: { $0.id == repository.id }) {
            currentFavorites.append(repository)
            saveFavorites(currentFavorites)
        }
    }
    
    /// Удаление репозитория из избранного
    func removeFromFavorites(_ repository: Repository) {
        var currentFavorites = loadFavorites()
        currentFavorites.removeAll { $0.id == repository.id }
        saveFavorites(currentFavorites)
    }
    
    /// Проверка, является ли репозиторий избранным
    func isFavorite(_ repository: Repository) -> Bool {
        let currentFavorites = loadFavorites()
        return currentFavorites.contains(where: { $0.id == repository.id })
    }
    
    /// Получение всех избранных репозиториев
    func getAllFavorites() -> [Repository] {
        return loadFavorites()
    }
}

