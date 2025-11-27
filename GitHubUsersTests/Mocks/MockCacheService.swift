//
//  MockCacheService.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
@testable import GitHubUsers

/// Мок для CacheService для тестирования
class MockCacheService: CacheServiceProtocol {
    private var cache: [String: Data] = [:]
    
    func cache<T: Codable>(_ object: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(object) {
            cache[key] = data
        }
    }
    
    func getCached<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = cache[key] else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

