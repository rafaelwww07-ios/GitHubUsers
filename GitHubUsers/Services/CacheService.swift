//
//  CacheService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

/// Протокол для кэширования данных
protocol CacheServiceProtocol {
    func cache<T: Codable>(_ object: T, forKey key: String)
    func getCached<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func clearCache()
}

/// Сервис для кэширования данных в памяти и на диске
class CacheService: CacheServiceProtocol {
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        // Настройка кэша в памяти
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        
        // Создание директории для кэша на диске
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("GitHubUsersCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// Сохранение объекта в кэш (память и диск)
    func cache<T: Codable>(_ object: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(object) else { return }
        
        // Кэш в памяти
        cache.setObject(data as NSData, forKey: key as NSString)
        
        // Кэш на диске
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? data.write(to: fileURL)
    }
    
    /// Получение объекта из кэша
    func getCached<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        // Сначала проверяем память
        if let cachedData = cache.object(forKey: key as NSString) as Data? {
            return try? JSONDecoder().decode(type, from: cachedData)
        }
        
        // Затем проверяем диск
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        if let decoded = try? JSONDecoder().decode(type, from: data) {
            // Восстанавливаем в память
            cache.setObject(data as NSData, forKey: key as NSString)
            return decoded
        }
        
        return nil
    }
    
    /// Очистка кэша
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

