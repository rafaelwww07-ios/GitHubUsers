//
//  SearchHistoryService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine

/// Протокол для работы с историей поиска
protocol SearchHistoryServiceProtocol {
    var historyPublisher: AnyPublisher<[String], Never> { get }
    func addToHistory(_ query: String)
    func clearHistory()
    func getHistory() -> [String]
    func removeFromHistory(_ query: String)
}

/// Сервис для управления историей поиска
class SearchHistoryService: SearchHistoryServiceProtocol {
    private let historySubject = CurrentValueSubject<[String], Never>([])
    private let userDefaults = UserDefaults.standard
    private let maxHistoryCount = 20 // Максимальное количество записей в истории
    private let historyKey = "searchHistory"
    
    var historyPublisher: AnyPublisher<[String], Never> {
        historySubject.eraseToAnyPublisher()
    }
    
    init() {
        loadHistory()
    }
    
    /// Загрузка истории из UserDefaults
    private func loadHistory() {
        if let history = userDefaults.stringArray(forKey: historyKey) {
            historySubject.send(history)
        } else {
            historySubject.send([])
        }
    }
    
    /// Сохранение истории в UserDefaults
    private func saveHistory(_ history: [String]) {
        userDefaults.set(history, forKey: historyKey)
        historySubject.send(history)
    }
    
    /// Добавление запроса в историю
    func addToHistory(_ query: String) {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return }
        
        var history = historySubject.value
        
        // Удаляем дубликаты
        history.removeAll { $0.lowercased() == cleanQuery.lowercased() }
        
        // Добавляем в начало
        history.insert(cleanQuery, at: 0)
        
        // Ограничиваем количество записей
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        saveHistory(history)
    }
    
    /// Очистка истории
    func clearHistory() {
        saveHistory([])
    }
    
    /// Получение истории
    func getHistory() -> [String] {
        historySubject.value
    }
    
    /// Удаление конкретного запроса из истории
    func removeFromHistory(_ query: String) {
        var history = historySubject.value
        history.removeAll { $0.lowercased() == query.lowercased() }
        saveHistory(history)
    }
}

