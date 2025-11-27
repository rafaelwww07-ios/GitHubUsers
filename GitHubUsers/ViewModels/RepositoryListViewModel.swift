//
//  RepositoryListViewModel.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine

/// ViewModel для списка репозиториев пользователя
@MainActor
class RepositoryListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var repositories: [Repository] = []
    @Published var filteredRepositories: [Repository] = []
    @Published var loadingState: LoadingState = .loading
    @Published var selectedSort: RepositorySort = .updated
    @Published var selectedOrder: RepositoryOrder = .desc
    @Published var selectedLanguage: String? = nil
    @Published var searchText: String = ""
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    
    // MARK: - Computed Properties
    var availableLanguages: [String] {
        Array(Set(repositories.compactMap { $0.language })).sorted()
    }
    
    // MARK: - Private Properties
    private let username: String
    private let repository: RepositoryRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 1
    
    // MARK: - Initialization
    init(
        username: String,
        repository: RepositoryRepositoryProtocol = RepositoryRepository()
    ) {
        self.username = username
        self.repository = repository
        
        setupBindings()
        loadRepositories()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Обновление фильтрованного списка при изменении данных
        Publishers.CombineLatest4(
            $repositories,
            $searchText,
            $selectedLanguage,
            $selectedSort
        )
        .combineLatest($selectedOrder)
        .sink { [weak self] combined, order in
            let (repos, search, language, sort) = combined
            self?.applyFilters(repos: repos, search: search, language: language, sort: sort, order: order)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    /// Загрузка репозиториев (сбрасывает пагинацию)
    func loadRepositories() {
        currentPage = 1
        hasMorePages = true
        loadingState = .loading
        
        Task {
            do {
                let repos = try await repository.getRepositories(
                    username: username,
                    sort: selectedSort,
                    order: selectedOrder,
                    page: 1
                )
                self.repositories = repos
                self.loadingState = .loaded
                self.hasMorePages = repos.count >= APIConstants.perPage
            } catch {
                self.loadingState = .error(error.localizedDescription)
            }
        }
    }
    
    /// Загрузка следующей страницы
    func loadNextPage() {
        guard !isLoadingMore, hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        Task {
            do {
                let newRepos = try await repository.getRepositories(
                    username: username,
                    sort: selectedSort,
                    order: selectedOrder,
                    page: currentPage
                )
                
                if !newRepos.isEmpty {
                    self.repositories.append(contentsOf: newRepos)
                    self.hasMorePages = newRepos.count >= APIConstants.perPage
                } else {
                    self.hasMorePages = false
                }
            } catch {
                currentPage -= 1
            }
            
            isLoadingMore = false
        }
    }
    
    /// Обновление списка (pull-to-refresh)
    func refresh() async {
        currentPage = 1
        hasMorePages = true
        
        do {
            let repos = try await repository.getRepositories(
                username: username,
                sort: selectedSort,
                order: selectedOrder,
                page: 1
            )
            self.repositories = repos
            self.loadingState = .loaded
            self.hasMorePages = repos.count >= APIConstants.perPage
        } catch {
            self.loadingState = .error(error.localizedDescription)
        }
    }
    
    /// Изменение сортировки (сбрасывает пагинацию)
    func changeSort(_ sort: RepositorySort) {
        selectedSort = sort
        currentPage = 1
        hasMorePages = true
        loadRepositories()
    }
    
    /// Изменение порядка сортировки (сбрасывает пагинацию)
    func changeOrder(_ order: RepositoryOrder) {
        selectedOrder = order
        currentPage = 1
        hasMorePages = true
        loadRepositories()
    }
    
    /// Фильтрация по языку
    func filterByLanguage(_ language: String?) {
        selectedLanguage = language
    }
    
    /// Очистка фильтра языка
    func clearLanguageFilter() {
        selectedLanguage = nil
    }
    
    // MARK: - Private Methods
    /// Применение фильтров и сортировки
    private func applyFilters(repos: [Repository], search: String, language: String?, sort: RepositorySort, order: RepositoryOrder) {
        var filtered = repos
        
        // Фильтр по поисковому запросу
        if !search.isEmpty {
            filtered = filtered.filter { repo in
                repo.name.localizedCaseInsensitiveContains(search) ||
                (repo.description?.localizedCaseInsensitiveContains(search) ?? false)
            }
        }
        
        // Фильтр по языку
        if let language = language {
            filtered = filtered.filter { $0.language == language }
        }
        
        // Сортировка (локальная, так как API уже отсортировал)
        filtered = sortRepositories(filtered, by: sort, order: order)
        
        filteredRepositories = filtered
    }
    
    /// Локальная сортировка репозиториев
    private func sortRepositories(_ repos: [Repository], by sort: RepositorySort, order: RepositoryOrder) -> [Repository] {
        var sorted = repos
        
        switch sort {
        case .stars:
            sorted.sort { $0.stars > $1.stars }
        case .fullName:
            sorted.sort { $0.fullName < $1.fullName }
        case .updated:
            // Сортируем по дате обновления (если нужно)
            sorted.sort { $0.updatedAt > $1.updatedAt }
        case .created, .pushed:
            // Для этих типов сортировки полагаемся на API
            break
        }
        
        if order == .asc {
            sorted.reverse()
        }
        
        return sorted
    }
}

