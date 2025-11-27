//
//  ImageCacheService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import UIKit
import SwiftUI

/// Протокол для кэширования изображений
protocol ImageCacheServiceProtocol {
    func loadImage(from url: String) async -> UIImage?
    func clearCache()
}

/// Сервис для кэширования изображений
class ImageCacheService: ImageCacheServiceProtocol {
    static let shared = ImageCacheService()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Настройка кэша в памяти
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        
        // Создание директории для кэша на диске
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cacheDir.appendingPathComponent("ImageCache", isDirectory: true)
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// Загрузка изображения с кэшированием
    func loadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        let cacheKey = urlString as NSString
        
        // Проверяем кэш в памяти
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Проверяем кэш на диске
        if let diskImage = loadFromDisk(key: cacheKey) {
            memoryCache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }
        
        // Загружаем из сети
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            // Сохраняем в кэш
            memoryCache.setObject(image, forKey: cacheKey)
            saveToDisk(image: image, key: cacheKey)
            
            return image
        } catch {
            return nil
        }
    }
    
    /// Загрузка изображения с диска
    private func loadFromDisk(key: NSString) -> UIImage? {
        let fileName = key.md5
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    /// Сохранение изображения на диск
    private func saveToDisk(image: UIImage, key: NSString) {
        let fileName = key.md5
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        try? data.write(to: fileURL)
    }
    
    /// Очистка кэша
    func clearCache() {
        memoryCache.removeAllObjects()
        
        // Удаляем файлы с диска
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - String Hash Extension
extension NSString {
    var md5: String {
        // Простой хэш для имени файла кэша
        guard let utf8String = self.utf8String else {
            return String(format: "%08x", abs(self.hash))
        }
        let string = String(cString: utf8String)
        let data = Data(string.utf8)
        var hash = 0
        for byte in data {
            hash = ((hash << 5) &- hash) &+ Int(byte)
            hash = hash & hash
        }
        return String(format: "%08x", abs(hash))
    }
}

