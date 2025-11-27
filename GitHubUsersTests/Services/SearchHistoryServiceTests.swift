//
//  SearchHistoryServiceTests.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import XCTest
import Combine
@testable import GitHubUsers

final class SearchHistoryServiceTests: XCTestCase {
    var service: SearchHistoryService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        service = SearchHistoryService()
    }
    
    override func tearDown() {
        service.clearHistory()
        cancellables = nil
        service = nil
        super.tearDown()
    }
    
    // MARK: - Add to History Tests
    
    func testAddToHistory() {
        // Given
        let query = "testquery"
        
        // When
        service.addToHistory(query)
        
        // Then
        let history = service.getHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first, query)
    }
    
    func testAddToHistory_TrimsWhitespace() {
        // Given
        let query = "  testquery  "
        
        // When
        service.addToHistory(query)
        
        // Then
        let history = service.getHistory()
        XCTAssertEqual(history.first, "testquery")
    }
    
    func testAddToHistory_IgnoresEmpty() {
        // Given
        let query = "   "
        
        // When
        service.addToHistory(query)
        
        // Then
        XCTAssertEqual(service.getHistory().count, 0)
    }
    
    func testAddToHistory_RemovesDuplicates() {
        // Given
        service.addToHistory("query1")
        service.addToHistory("query2")
        
        // When
        service.addToHistory("query1") // Duplicate
        
        // Then
        let history = service.getHistory()
        XCTAssertEqual(history.count, 2)
        XCTAssertEqual(history.first, "query1") // Should be moved to front
    }
    
    func testAddToHistory_LimitsToMaxCount() {
        // Given
        // Add 21 queries (max is 20)
        for i in 1...21 {
            service.addToHistory("query\(i)")
        }
        
        // Then
        let history = service.getHistory()
        XCTAssertEqual(history.count, 20)
        XCTAssertEqual(history.first, "query21") // Most recent
        XCTAssertEqual(history.last, "query2") // Oldest
    }
    
    // MARK: - Remove from History Tests
    
    func testRemoveFromHistory() {
        // Given
        service.addToHistory("query1")
        service.addToHistory("query2")
        
        // When
        service.removeFromHistory("query1")
        
        // Then
        let history = service.getHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first, "query2")
    }
    
    // MARK: - Clear History Tests
    
    func testClearHistory() {
        // Given
        service.addToHistory("query1")
        service.addToHistory("query2")
        
        // When
        service.clearHistory()
        
        // Then
        XCTAssertEqual(service.getHistory().count, 0)
    }
    
    // MARK: - Publisher Tests
    
    func testHistoryPublisher_EmitsOnAdd() {
        // Given
        let expectation = expectation(description: "Publisher emits")
        var receivedHistory: [String] = []
        
        service.historyPublisher
            .sink { history in
                receivedHistory = history
                if history.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        service.addToHistory("testquery")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedHistory.count, 1)
        XCTAssertEqual(receivedHistory.first, "testquery")
    }
}

