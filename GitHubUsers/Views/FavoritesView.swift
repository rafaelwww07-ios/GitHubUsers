//
//  FavoritesView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Экран избранных пользователей
struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesList
                }
            }
            .navigationTitle("favorites.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("nav.done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Favorites List
    private var favoritesList: some View {
        List {
            ForEach(viewModel.favorites) { user in
                NavigationLink(destination: UserDetailView(username: user.login)) {
                    UserRowView(
                        user: user,
                        isFavorite: true
                    )
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.removeFavorite(viewModel.favorites[index])
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("favorites.empty".localized)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("favorites.add.hint".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView()
}

