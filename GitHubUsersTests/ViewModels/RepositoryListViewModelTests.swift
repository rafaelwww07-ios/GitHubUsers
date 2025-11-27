//
//  RepositoryListViewModelTests.swift
//  GitHubUsersTests
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import XCTest
import Combine
@testable import GitHubUsers

@MainActor
final class RepositoryListViewModelTests: XCTestCase {
    var viewModel: RepositoryListViewModel!
    var mockRepository: MockRepositoryRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockRepository = MockRepositoryRepository()
        
        viewModel = RepositoryListViewModel(
            username: "testuser",
            repository: mockRepository
        )
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Load Repositories Tests
    
    func testLoadRepositories_Success() async {
        // Given
        let expectedRepos = [
            createTestRepository(id: 1, name: "repo1", language: "Swift"),
            createTestRepository(id: 2, name: "repo2", language: "Swift")
        ]
        mockRepository.getRepositoriesResult = .success(expectedRepos)
        
        // When
        viewModel.loadRepositories()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.repositories.count, 2)
        XCTAssertEqual(viewModel.loadingState, .loaded)
        XCTAssertEqual(mockRepository.getRepositoriesCallCount, 1)
    }
    
    func testLoadRepositories_Error() async {
        // Given
        mockRepository.getRepositoriesResult = .failure(AppError.networkError("Network error"))
        
        // When
        viewModel.loadRepositories()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        if case .error(let message) = viewModel.loadingState {
            XCTAssertTrue(message.contains("Network error"))
        } else {
            XCTFail("Expected error state")
        }
    }
    
    // MARK: - Filtering Tests
    
    func testFilterByLanguage() {
        // Given
        let repos = [
            createTestRepository(id: 1, name: "repo1", language: "Swift"),
            createTestRepository(id: 2, name: "repo2", language: "Kotlin"),
            createTestRepository(id: 3, name: "repo3", language: "Swift")
        ]
        viewModel.repositories = repos
        
        // When
        viewModel.filterByLanguage("Swift")
        
        // Wait for Combine to process
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Then
        XCTAssertEqual(viewModel.filteredRepositories.count, 2)
        XCTAssertTrue(viewModel.filteredRepositories.allSatisfy { $0.language == "Swift" })
    }
    
    func testSearchText_FiltersRepositories() {
        // Given
        let repos = [
            createTestRepository(id: 1, name: "awesome-repo", description: "Awesome project"),
            createTestRepository(id: 2, name: "test-repo", description: "Test project")
        ]
        viewModel.repositories = repos
        
        // When
        viewModel.searchText = "awesome"
        
        // Wait for Combine to process
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Then
        XCTAssertEqual(viewModel.filteredRepositories.count, 1)
        XCTAssertEqual(viewModel.filteredRepositories.first?.name, "awesome-repo")
    }
    
    // MARK: - Sorting Tests
    
    func testChangeSort() async {
        // Given
        mockRepository.getRepositoriesResult = .success([])
        
        // When
        viewModel.changeSort(.stars)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.selectedSort, .stars)
        XCTAssertEqual(mockRepository.getRepositoriesCallCount, 1)
    }
    
    // MARK: - Pagination Tests
    
    func testLoadNextPage() async {
        // Given
        let firstPage = (1...30).map { id in
            createTestRepository(id: id, name: "repo\(id)", language: "Swift")
        }
        let secondPage = (31...60).map { id in
            createTestRepository(id: id, name: "repo\(id)", language: "Swift")
        }
        
        mockRepository.getRepositoriesResult = .success(firstPage)
        viewModel.loadRepositories()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        mockRepository.getRepositoriesResult = .success(secondPage)
        viewModel.loadNextPage()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.repositories.count, 60)
        XCTAssertTrue(viewModel.hasMorePages)
    }
    
    // MARK: - Helper Methods
    
    private func createTestRepository(id: Int, name: String, language: String? = nil) -> Repository {
        Repository(
            id: id,
            name: name,
            fullName: "testuser/\(name)",
            description: "Test repository",
            language: language,
            stars: 10,
            forks: 5,
            htmlURL: "https://github.com/testuser/\(name)",
            updatedAt: "2024-01-01T00:00:00Z"
        )
    }
}

// MARK: - Mock RepositoryRepository
class MockRepositoryRepository: RepositoryRepositoryProtocol {
    var getRepositoriesResult: Result<[Repository], Error> = .success([])
    var getRepositoriesCallCount = 0
    
    func getRepositories(username: String, sort: RepositorySort?, order: RepositoryOrder?, page: Int) async throws -> [Repository] {
        getRepositoriesCallCount += 1
        switch getRepositoriesResult {
        case .success(let repos):
            return repos
        case .failure(let error):
            throw error
        }
    }
}

