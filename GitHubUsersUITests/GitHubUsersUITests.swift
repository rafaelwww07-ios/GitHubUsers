//
//  GitHubUsersUITests.swift
//  GitHubUsersUITests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import XCTest

final class GitHubUsersUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    /// Тест поиска пользователя
    func testSearchUser() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        
        searchField.tap()
        searchField.typeText("octocat")
        
        // Ждем появления результатов
        let firstUser = app.staticTexts["octocat"].firstMatch
        XCTAssertTrue(firstUser.waitForExistence(timeout: 10))
    }
    
    /// Тест открытия профиля пользователя
    func testOpenUserProfile() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        
        searchField.tap()
        searchField.typeText("octocat")
        
        // Ждем результатов и открываем профиль
        let firstUser = app.staticTexts["octocat"].firstMatch
        XCTAssertTrue(firstUser.waitForExistence(timeout: 10))
        firstUser.tap()
        
        // Проверяем, что открылся детальный экран
        let profileTitle = app.navigationBars["octocat"].firstMatch
        XCTAssertTrue(profileTitle.waitForExistence(timeout: 5))
    }
    
    /// Тест добавления в избранное
    func testAddToFavorites() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        
        searchField.tap()
        searchField.typeText("octocat")
        
        // Открываем профиль
        let firstUser = app.staticTexts["octocat"].firstMatch
        XCTAssertTrue(firstUser.waitForExistence(timeout: 10))
        firstUser.tap()
        
        // Нажимаем кнопку избранного
        let favoriteButton = app.buttons["Add to favorites"].firstMatch
        if favoriteButton.exists {
            favoriteButton.tap()
        }
        
        // Проверяем, что кнопка изменилась
        let removeButton = app.buttons["Remove from favorites"].firstMatch
        XCTAssertTrue(removeButton.waitForExistence(timeout: 2))
    }
    
    /// Тест навигации к избранным
    func testNavigateToFavorites() throws {
        // Нажимаем кнопку избранных в навигации
        let favoritesButton = app.buttons.matching(identifier: "Favorites").firstMatch
        if favoritesButton.exists {
            favoritesButton.tap()
            
            // Проверяем, что открылся экран избранных
            let favoritesTitle = app.navigationBars["favorites.title"].firstMatch
            XCTAssertTrue(favoritesTitle.waitForExistence(timeout: 5))
        }
    }
    
    /// Тест открытия настроек
    func testOpenSettings() throws {
        // Нажимаем кнопку настроек
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        if settingsButton.exists {
            settingsButton.tap()
            
            // Проверяем, что открылся экран настроек
            let settingsTitle = app.navigationBars["settings.title"].firstMatch
            XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
        }
    }
    
    /// Тест pull-to-refresh
    func testPullToRefresh() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        
        searchField.tap()
        searchField.typeText("swift")
        
        // Ждем результатов
        let firstUser = app.staticTexts.firstMatch
        XCTAssertTrue(firstUser.waitForExistence(timeout: 10))
        
        // Выполняем pull-to-refresh
        let firstCell = app.cells.firstMatch
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
    }
}

