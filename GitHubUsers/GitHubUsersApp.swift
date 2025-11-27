//
//  GitHubUsersApp.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

@main
struct GitHubUsersApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var deepLinkManager = DeepLinkManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
                .environmentObject(deepLinkManager)
                .onOpenURL { url in
                    _ = deepLinkManager.handleURL(url)
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var navigationPath = NavigationPath()
    @State private var showingFavorites = false
    @State private var showingUserDetail: String?
    @State private var showingRepository: (owner: String, repo: String)?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            UserListView()
                .navigationDestination(for: String.self) { username in
                    UserDetailView(username: username)
                }
                .sheet(isPresented: $showingFavorites) {
                    FavoritesView()
                }
                .sheet(item: Binding(
                    get: { showingUserDetail.map { UserNavigationItem(username: $0) } },
                    set: { showingUserDetail = $0?.username }
                )) { item in
                    NavigationView {
                        UserDetailView(username: item.username)
                    }
                }
                .sheet(item: Binding(
                    get: { showingRepository.map { RepositoryNavigationItem(owner: $0.owner, repo: $0.repo) } },
                    set: { showingRepository = $0.map { ($0.owner, $0.repo) } }
                )) { item in
                    NavigationView {
                        RepositoryDetailView(owner: item.owner, repo: item.repo)
                    }
                }
                .onChange(of: deepLinkManager.activeLink) { link in
                    handleDeepLink(link)
                }
        }
    }
    
    private func handleDeepLink(_ link: DeepLinkType?) {
        guard let link = link else { return }
        
        switch link {
        case .user(let username):
            showingUserDetail = username
            HapticFeedbackManager.shared.selection()
        case .repository(let owner, let repo):
            showingRepository = (owner, repo)
            HapticFeedbackManager.shared.selection()
        case .favorites:
            showingFavorites = true
            HapticFeedbackManager.shared.selection()
        case .search(let query):
            break
        }
        
        deepLinkManager.clearActiveLink()
    }
}

struct UserNavigationItem: Identifiable {
    let id = UUID()
    let username: String
}

struct RepositoryNavigationItem: Identifiable {
    let id = UUID()
    let owner: String
    let repo: String
}

