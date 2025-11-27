//
//  RepositorySearchView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Экран глобального поиска репозиториев
struct RepositorySearchView: View {
    @StateObject private var viewModel = RepositorySearchViewModel()
    @State private var showingSortOptions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Поиск
            SearchBar(text: $viewModel.searchText)
                .padding(.horizontal)
                .padding(.top, 8)
            
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
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.loadingState {
        case .idle:
            emptyStateView
            
        case .loading:
            SkeletonLoadingView()
            
        case .loaded:
            if viewModel.repositories.isEmpty {
                emptyResultsView
            } else {
                repositoriesList
            }
            
        case .error(let message):
            ErrorView(message: message) {
                viewModel.performSearch(query: viewModel.searchText)
            }
        }
    }
    
    // MARK: - Repositories List
    private var repositoriesList: some View {
        List {
            ForEach(viewModel.repositories) { repository in
                NavigationLink(destination: RepositoryDetailView(
                    owner: repository.fullName.components(separatedBy: "/").first ?? "",
                    repo: repository.name
                )) {
                    RepositoryRowView(repository: repository)
                }
                .onAppear {
                    if repository.id == viewModel.repositories.last?.id {
                        viewModel.loadNextPage()
                    }
                }
            }
            
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            }
            
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
    
    // MARK: - Empty States
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("search.start".localized)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("search.enter.username".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("repo.no.repositories".localized)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("search.try.different".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationView {
        RepositorySearchView()
    }
}

