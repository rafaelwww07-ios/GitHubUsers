//
//  MockSearchHistoryService.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine
@testable import GitHubUsers

/// Мок для SearchHistoryService для тестирования
class MockSearchHistoryService: SearchHistoryServiceProtocol {
    private let historySubject = CurrentValueSubject<[String], Never>([])
    
    var historyPublisher: AnyPublisher<[String], Never> {
        historySubject.eraseToAnyPublisher()
    }
    
    private var history: [String] = []
    
    func addToHistory(_ query: String) {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return }
        
        history.removeAll { $0.lowercased() == cleanQuery.lowercased() }
        history.insert(cleanQuery, at: 0)
        
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
        
        historySubject.send(history)
    }
    
    func clearHistory() {
        history = []
        historySubject.send(history)
    }
    
    func getHistory() -> [String] {
        history
    }
    
    func removeFromHistory(_ query: String) {
        history.removeAll { $0.lowercased() == query.lowercased() }
        historySubject.send(history)
    }
}

