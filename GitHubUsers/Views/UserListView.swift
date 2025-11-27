//
//  UserListView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Главный экран со списком пользователей
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    @State private var showingFavorites = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // Статус сети
                    NetworkStatusView()
                    
                    // Поиск
                    SearchBar(text: $viewModel.searchText)
                        .padding(.horizontal)
                    
                    // История поиска (показывается когда поле пустое)
                    if viewModel.showHistory && !viewModel.searchHistory.isEmpty {
                        SearchHistoryView(
                            history: viewModel.searchHistory,
                            onSelect: { query in
                                viewModel.selectHistoryItem(query)
                            },
                            onRemove: { query in
                                viewModel.removeHistoryItem(query)
                            },
                            onClear: {
                                viewModel.clearHistory()
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    // Контент
                    contentView
                }
            }
            .navigationTitle("nav.users".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    
                    Button(action: { showingFavorites = true }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
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
            if viewModel.users.isEmpty {
                emptyResultsView
            } else {
                usersList
            }
            
        case .error(let message):
            ErrorView(message: message) {
                viewModel.searchUsers(query: viewModel.searchText)
            }
        }
    }
    
    // MARK: - Users List
    private var usersList: some View {
        List {
            ForEach(viewModel.users) { user in
                NavigationLink(destination: UserDetailView(username: user.login)) {
                    UserRowView(
                        user: user,
                        isFavorite: viewModel.isFavorite(user)
                    )
                }
                .accessibilityLabel("User \(user.login)")
                .accessibilityHint("Double tap to view user profile")
                .onAppear {
                    // Загружаем следующую страницу когда показывается последний элемент
                    if user.id == viewModel.users.last?.id {
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
            if !viewModel.hasMorePages && !viewModel.users.isEmpty {
                HStack {
                    Spacer()
                    Text("state.no.more.users".localized)
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
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("search.no.results".localized)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("search.try.different".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("search.placeholder".localized, text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    UserListView()
}

