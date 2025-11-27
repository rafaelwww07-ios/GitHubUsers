//
//  FavoritesService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine
import WidgetKit

/// Протокол для работы с избранными пользователями
protocol FavoritesServiceProtocol {
    var favoritesPublisher: AnyPublisher<[User], Never> { get }
    func addToFavorites(_ user: User)
    func removeFromFavorites(_ user: User)
    func isFavorite(_ user: User) -> Bool
    func getFavorites() -> [User]
}

/// Сервис для управления избранными пользователями
class FavoritesService: FavoritesServiceProtocol {
    private let favoritesSubject = CurrentValueSubject<[User], Never>([])
    private let userDefaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.com.githubusers.shared")
    
    var favoritesPublisher: AnyPublisher<[User], Never> {
        favoritesSubject.eraseToAnyPublisher()
    }
    
    init() {
        loadFavorites()
    }
    
    /// Загрузка избранных из UserDefaults
    private func loadFavorites() {
        // Пытаемся загрузить из App Group (приоритет), если нет - из стандартного UserDefaults
        var data: Data?
        if let sharedData = sharedDefaults?.data(forKey: UserDefaultsKeys.favoriteUsers) {
            data = sharedData
        } else if let standardData = userDefaults.data(forKey: UserDefaultsKeys.favoriteUsers) {
            data = standardData
        }
        
        guard let data = data,
              let favorites = try? JSONDecoder().decode([User].self, from: data) else {
            favoritesSubject.send([])
            return
        }
        favoritesSubject.send(favorites)
    }
    
    /// Сохранение избранных в UserDefaults
    private func saveFavorites(_ favorites: [User]) {
        if let data = try? JSONEncoder().encode(favorites) {
            // Сохраняем в стандартный UserDefaults
            userDefaults.set(data, forKey: UserDefaultsKeys.favoriteUsers)
            
            sharedDefaults?.set(data, forKey: UserDefaultsKeys.favoriteUsers)
            favoritesSubject.send(favorites)
            WidgetCenter.shared.reloadTimelines(ofKind: "GitHubUsersWidget")
        }
    }
    
    /// Добавление пользователя в избранное
    func addToFavorites(_ user: User) {
        var favorites = favoritesSubject.value
        if !favorites.contains(where: { $0.id == user.id }) {
            favorites.append(user)
            saveFavorites(favorites)
        }
    }
    
    /// Удаление пользователя из избранного
    func removeFromFavorites(_ user: User) {
        var favorites = favoritesSubject.value
        favorites.removeAll { $0.id == user.id }
        saveFavorites(favorites)
    }
    
    /// Проверка, является ли пользователь избранным
    func isFavorite(_ user: User) -> Bool {
        favoritesSubject.value.contains { $0.id == user.id }
    }
    
    /// Получение списка избранных
    func getFavorites() -> [User] {
        favoritesSubject.value
    }
}

