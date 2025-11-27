//
//  RepositoryListView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Экран со списком репозиториев пользователя
struct RepositoryListView: View {
    let username: String
    @StateObject private var viewModel: RepositoryListViewModel
    @State private var showingSortOptions = false
    @State private var showingLanguageFilter = false
    
    init(username: String) {
        self.username = username
        _viewModel = StateObject(wrappedValue: RepositoryListViewModel(username: username))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель фильтров
            filtersBar
            
            // Контент
            contentView
        }
        .navigationTitle("nav.repositories".localized)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingSortOptions = true }) {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showingSortOptions) {
            SortOptionsView(
                selectedSort: $viewModel.selectedSort,
                selectedOrder: $viewModel.selectedOrder,
                onApply: {
                    viewModel.changeSort(viewModel.selectedSort)
                    viewModel.changeOrder(viewModel.selectedOrder)
                }
            )
        }
    }
    
    // MARK: - Filters Bar
    private var filtersBar: some View {
        VStack(spacing: 8) {
            // Поиск
            SearchBar(text: $viewModel.searchText)
                .padding(.horizontal)
            
            // Фильтры
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Фильтр по языку
                    if !viewModel.availableLanguages.isEmpty {
                        Menu {
                            Button("filter.all.languages".localized) {
                                viewModel.clearLanguageFilter()
                            }
                            
                            ForEach(viewModel.availableLanguages, id: \.self) { language in
                                Button(language) {
                                    viewModel.filterByLanguage(language)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(viewModel.selectedLanguage ?? "filter.all.languages".localized)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedLanguage != nil ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                            .foregroundColor(viewModel.selectedLanguage != nil ? .accentColor : .primary)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Счетчик репозиториев
                    Text("\(viewModel.filteredRepositories.count) \("repo.repositories".localized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.loadingState {
        case .loading:
            LoadingView()
            
        case .loaded:
            if viewModel.filteredRepositories.isEmpty {
                emptyStateView
            } else {
                repositoriesList
            }
            
        case .error(let message):
            ErrorView(message: message) {
                viewModel.loadRepositories()
            }
            
        case .idle:
            EmptyView()
        }
    }
    
    // MARK: - Repositories List
    private var repositoriesList: some View {
        List {
            ForEach(viewModel.filteredRepositories) { repository in
                NavigationLink(destination: RepositoryDetailView(
                    owner: repository.fullName.components(separatedBy: "/").first ?? username,
                    repo: repository.name
                )) {
                    RepositoryRowView(repository: repository)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // Open in Safari action
                    Button(action: {
                        openRepository(repository)
                    }) {
                        Label("action.open".localized, systemImage: "safari")
                    }
                    .tint(.green)
                }
                .contextMenu {
                    // Share menu item
                    if let url = URL(string: repository.htmlURL) {
                        ShareLink(item: url) {
                            Label("action.share".localized, systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    // Open in Safari menu item
                    Button(action: {
                        openRepository(repository)
                    }) {
                        Label("action.open.safari".localized, systemImage: "safari")
                    }
                }
                .onAppear {
                    // Загружаем следующую страницу когда показывается последний элемент
                    // Но только если это элемент из оригинального списка (не отфильтрованный)
                    if repository.id == viewModel.repositories.last?.id {
                        viewModel.loadNextPage()
                    }
                }
            }
            
            // Индикатор загрузки следующей страницы
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            }
            
            // Сообщение о достижении конца списка
            if !viewModel.hasMorePages && !viewModel.repositories.isEmpty {
                HStack {
                    Spacer()
                    Text("state.no.more.repos".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("repo.no.repositories".localized)
                .font(.headline)
                .foregroundColor(.secondary)
            if !viewModel.searchText.isEmpty || viewModel.selectedLanguage != nil {
                Text("repo.try.filters".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    private func openRepository(_ repository: Repository) {
        guard let url = URL(string: repository.htmlURL) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Sort Options View
struct SortOptionsView: View {
    @Binding var selectedSort: RepositorySort
    @Binding var selectedOrder: RepositoryOrder
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("sort.by".localized) {
                    ForEach(RepositorySort.allCases, id: \.self) { sort in
                        Button(action: {
                            selectedSort = sort
                        }) {
                            HStack {
                                Text(sort.displayName)
                                Spacer()
                                if selectedSort == sort {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
                
                Section("sort.order".localized) {
                    ForEach(RepositoryOrder.allCases, id: \.self) { order in
                        Button(action: {
                            selectedOrder = order
                        }) {
                            HStack {
                                Text(order.displayName)
                                Spacer()
                                if selectedOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("sort.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("nav.done".localized) {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        RepositoryListView(username: "octocat")
    }
}

