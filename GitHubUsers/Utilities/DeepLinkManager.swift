//
//  DeepLinkManager.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import SwiftUI
import Combine

/// Тип deep link
enum DeepLinkType: Equatable {
    case user(String) // username
    case repository(owner: String, repo: String)
    case favorites
    case search(String) // query
}

/// Менеджер для обработки deep links
class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var activeLink: DeepLinkType?
    
    private init() {}
    
    /// Обработка URL
    func handleURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme else { return false }
        
        // Обработка custom scheme: githubusers://
        if scheme == "githubusers" {
            return handleCustomScheme(url)
        }
        
        // Обработка Universal Links: https://github.com/
        if url.host == "github.com" {
            return handleUniversalLink(url)
        }
        
        return false
    }
    
    /// Обработка custom scheme
    private func handleCustomScheme(_ url: URL) -> Bool {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        guard !pathComponents.isEmpty else { return false }
        
        switch pathComponents[0] {
        case "user":
            if pathComponents.count > 1 {
                activeLink = .user(pathComponents[1])
                return true
            }
        case "repo":
            if pathComponents.count > 2 {
                activeLink = .repository(owner: pathComponents[1], repo: pathComponents[2])
                return true
            }
        case "favorites":
            activeLink = .favorites
            return true
        case "search":
            if pathComponents.count > 1 {
                activeLink = .search(pathComponents[1])
                return true
            }
        default:
            break
        }
        
        return false
    }
    
    /// Обработка Universal Links
    private func handleUniversalLink(_ url: URL) -> Bool {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        guard !pathComponents.isEmpty else { return false }
        
        // https://github.com/{username}
        if pathComponents.count == 1 {
            activeLink = .user(pathComponents[0])
            return true
        }
        
        // https://github.com/{owner}/{repo}
        if pathComponents.count == 2 {
            activeLink = .repository(owner: pathComponents[0], repo: pathComponents[1])
            return true
        }
        
        return false
    }
    
    /// Очистка активной ссылки
    func clearActiveLink() {
        activeLink = nil
    }
}

