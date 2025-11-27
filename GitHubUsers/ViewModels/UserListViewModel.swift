//
//  UserListViewModel.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@MainActor
class UserListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var users: [User] = []
    @Published var searchText: String = ""
    @Published var loadingState: LoadingState = .idle
    @Published var isRefreshing: Bool = false
    @Published var searchHistory: [String] = []
    @Published var showHistory: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    
    // MARK: - Private Properties
    private let repository: UserRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let searchHistoryService: SearchHistoryServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var currentPage: Int = 1
    private var currentQuery: String = ""
    
    // MARK: - Initialization
    init(
        repository: UserRepositoryProtocol = UserRepository(),
        favoritesService: FavoritesServiceProtocol = FavoritesService(),
        searchHistoryService: SearchHistoryServiceProtocol = SearchHistoryService()
    ) {
        self.repository = repository
        self.favoritesService = favoritesService
        self.searchHistoryService = searchHistoryService
        
        setupSearchBinding()
        setupHistoryObserver()
    }
    
    // MARK: - Setup
    private func setupSearchBinding() {
        // Debounce поиска для оптимизации запросов
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchUsers(query: query)
            }
            .store(in: &cancellables)
        
        // Показываем историю когда поле поиска пустое или в фокусе
        $searchText
            .map { $0.isEmpty }
            .assign(to: &$showHistory)
    }
    
    private func setupHistoryObserver() {
        searchHistoryService.historyPublisher
            .assign(to: &$searchHistory)
    }
    
    func searchUsers(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            users = []
            loadingState = .idle
            currentPage = 1
            hasMorePages = true
            return
        }
        
        currentPage = 1
        currentQuery = query
        hasMorePages = true
        loadingState = .loading
        
        searchTask = Task {
            do {
                let foundUsers = try await repository.searchUsers(query: query, page: 1)
                
                if !Task.isCancelled {
                    self.users = foundUsers
                    self.loadingState = .loaded
                    self.hasMorePages = foundUsers.count >= APIConstants.perPage
                    if !foundUsers.isEmpty {
                        self.searchHistoryService.addToHistory(query)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self.loadingState = .error(error.localizedDescription)
                    self.users = []
                }
            }
        }
    }
    
    /// Загрузка следующей страницы
    func loadNextPage() {
        guard !isLoadingMore, hasMorePages, !currentQuery.isEmpty else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        Task {
            do {
                let newUsers = try await repository.searchUsers(query: currentQuery, page: currentPage)
                
                if !newUsers.isEmpty {
                    self.users.append(contentsOf: newUsers)
                    // Если получили меньше per_page, значит это последняя страница
                    self.hasMorePages = newUsers.count >= APIConstants.perPage
                } else {
                    self.hasMorePages = false
                }
            } catch {
                // При ошибке возвращаемся на предыдущую страницу
                currentPage -= 1
            }
            
            isLoadingMore = false
        }
    }
    
    /// Обновление списка (pull-to-refresh)
    func refresh() async {
        isRefreshing = true
        let query = searchText
        
        // Сбрасываем пагинацию
        currentPage = 1
        currentQuery = query
        hasMorePages = true
        
        do {
            let foundUsers = try await repository.searchUsers(query: query, page: 1)
            self.users = foundUsers
            self.loadingState = .loaded
            self.hasMorePages = foundUsers.count >= APIConstants.perPage
        } catch {
            self.loadingState = .error(error.localizedDescription)
        }
        
        isRefreshing = false
    }
    
    func isFavorite(_ user: User) -> Bool {
        favoritesService.isFavorite(user)
    }
    
    func selectHistoryItem(_ query: String) {
        searchText = query
        showHistory = false
    }
    
    func clearHistory() {
        searchHistoryService.clearHistory()
    }
    
    func removeHistoryItem(_ query: String) {
        searchHistoryService.removeFromHistory(query)
    }
}

