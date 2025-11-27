//
//  RepositorySearchViewModel.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine

/// ViewModel для поиска репозиториев
@MainActor
class RepositorySearchViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var searchText: String = ""
    @Published var loadingState: LoadingState = .idle
    @Published var selectedSort: RepositorySort = .stars
    @Published var selectedOrder: RepositoryOrder = .desc
    @Published var currentPage: Int = 1
    @Published var hasMorePages: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var totalCount: Int = 0
    
    private let apiService: GitHubAPIServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: GitHubAPIServiceProtocol = GitHubAPIService()) {
        self.apiService = apiService
        
        // Debounce поиска
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    /// Выполнение поиска
    func performSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            repositories = []
            loadingState = .idle
            currentPage = 1
            hasMorePages = false
            return
        }
        
        currentPage = 1
        repositories = []
        loadingState = .loading
        
        searchTask = Task {
            await searchRepositories(query: query, page: 1)
        }
    }
    
    /// Поиск репозиториев
    private func searchRepositories(query: String, page: Int) async {
        do {
            let result = try await apiService.searchRepositories(
                query: query,
                sort: selectedSort,
                order: selectedOrder,
                page: page
            )
            
            if page == 1 {
                repositories = result.repositories
            } else {
                repositories.append(contentsOf: result.repositories)
            }
            
            totalCount = result.totalCount
            hasMorePages = result.hasMore
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }
    
    /// Загрузка следующей страницы
    func loadNextPage() {
        guard !searchText.isEmpty,
              hasMorePages,
              !isLoadingMore,
              loadingState == .loaded else {
            return
        }
        
        isLoadingMore = true
        currentPage += 1
        
        Task {
            await searchRepositories(query: searchText, page: currentPage)
            isLoadingMore = false
        }
    }
    
    /// Изменение сортировки
    func changeSort(_ sort: RepositorySort) {
        selectedSort = sort
        if !searchText.isEmpty {
            performSearch(query: searchText)
        }
    }
    
    /// Изменение порядка сортировки
    func changeOrder(_ order: RepositoryOrder) {
        selectedOrder = order
        if !searchText.isEmpty {
            performSearch(query: searchText)
        }
    }
    
    /// Обновление данных
    func refresh() async {
        guard !searchText.isEmpty else { return }
        currentPage = 1
        repositories = []
        await searchRepositories(query: searchText, page: 1)
    }
}

