//
//  RepositoryRepository.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

/// Протокол репозитория для работы с репозиториями GitHub
protocol RepositoryRepositoryProtocol {
    func getRepositories(username: String, sort: RepositorySort?, order: RepositoryOrder?, page: Int) async throws -> [Repository]
}

/// Репозиторий для работы с репозиториями (объединяет API и кэш)
class RepositoryRepository: RepositoryRepositoryProtocol {
    private let apiService: GitHubAPIServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    init(
        apiService: GitHubAPIServiceProtocol = GitHubAPIService(),
        cacheService: CacheServiceProtocol = CacheService()
    ) {
        self.apiService = apiService
        self.cacheService = cacheService
    }
    
    /// Получение репозиториев пользователя с кэшированием (только для первой страницы)
    /// - Parameters:
    ///   - username: Имя пользователя
    ///   - sort: Способ сортировки
    ///   - order: Порядок сортировки
    ///   - page: Номер страницы (начинается с 1)
    func getRepositories(username: String, sort: RepositorySort?, order: RepositoryOrder?, page: Int = 1) async throws -> [Repository] {
        // Кэшируем только первую страницу
        if page == 1 {
            let sortKey = sort?.rawValue ?? "updated"
            let orderKey = order?.rawValue ?? "desc"
            let cacheKey = "repos_\(username)_\(sortKey)_\(orderKey)_page1"
            
            // Пытаемся получить из кэша
            if let cached: [Repository] = cacheService.getCached([Repository].self, forKey: cacheKey) {
                // Обновляем данные в фоне
                Task {
                    await updateCache(username: username, sort: sort, order: order, page: 1, cacheKey: cacheKey)
                }
                return cached
            }
        }
        
        // Загружаем из API
        let repositories = try await apiService.getRepositories(username: username, sort: sort, order: order, page: page)
        
        // Кэшируем только первую страницу
        if page == 1 {
            let sortKey = sort?.rawValue ?? "updated"
            let orderKey = order?.rawValue ?? "desc"
            let cacheKey = "repos_\(username)_\(sortKey)_\(orderKey)_page1"
            cacheService.cache(repositories, forKey: cacheKey)
        }
        
        return repositories
    }
    
    /// Обновление кэша репозиториев в фоне
    private func updateCache(username: String, sort: RepositorySort?, order: RepositoryOrder?, page: Int, cacheKey: String) async {
        do {
            let repositories = try await apiService.getRepositories(username: username, sort: sort, order: order, page: page)
            cacheService.cache(repositories, forKey: cacheKey)
        } catch {
            // Игнорируем ошибки при обновлении кэша
        }
    }
}

