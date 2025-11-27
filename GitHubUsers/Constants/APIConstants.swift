//
//  APIConstants.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

enum APIConstants {
    static let baseURL = "https://api.github.com"
    static let usersEndpoint = "/users"
    static let searchEndpoint = "/search/users"
    static let searchReposEndpoint = "/search/repositories"
    static let reposEndpoint = "/repos"
    static let timeoutInterval: TimeInterval = 30
    static let perPage = 30
    
    static func userURL(username: String) -> String {
        "\(baseURL)\(usersEndpoint)/\(username)"
    }
    
    static func searchURL(query: String, page: Int = 1) -> String {
        var components = URLComponents(string: "\(baseURL)\(searchEndpoint)")!
        let searchQuery = "\(query) type:user"
        
        components.queryItems = [
            URLQueryItem(name: "q", value: searchQuery),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components.url else {
            let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
            return "\(baseURL)\(searchEndpoint)?q=\(encodedQuery)&per_page=\(perPage)&page=\(page)"
        }
        
        return url.absoluteString
    }
    
    static func repositoriesURL(username: String, sort: RepositorySort? = nil, order: RepositoryOrder? = nil, page: Int = 1) -> String {
        var components = URLComponents(string: "\(baseURL)\(usersEndpoint)/\(username)/repos")!
        
        var queryItems: [URLQueryItem] = []
        
        if let sort = sort {
            queryItems.append(URLQueryItem(name: "sort", value: sort.rawValue))
        }
        
        if let order = order {
            queryItems.append(URLQueryItem(name: "direction", value: order.rawValue))
        }
        
        queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
        queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            var urlString = "\(baseURL)\(usersEndpoint)/\(username)/repos?per_page=\(perPage)&page=\(page)"
            if let sort = sort {
                urlString += "&sort=\(sort.rawValue)"
            }
            if let order = order {
                urlString += "&direction=\(order.rawValue)"
            }
            return urlString
        }
        
        return url.absoluteString
    }
    
    static func repositoryURL(owner: String, repo: String) -> String {
        "\(baseURL)\(reposEndpoint)/\(owner)/\(repo)"
    }
    
    static func searchRepositoriesURL(query: String, sort: RepositorySort? = nil, order: RepositoryOrder? = nil, page: Int = 1) -> String {
        var components = URLComponents(string: "\(baseURL)\(searchReposEndpoint)")!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        if let sort = sort {
            queryItems.append(URLQueryItem(name: "sort", value: sort.rawValue))
        }
        
        if let order = order {
            queryItems.append(URLQueryItem(name: "order", value: order.rawValue))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            var urlString = "\(baseURL)\(searchReposEndpoint)?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&per_page=\(perPage)&page=\(page)"
            if let sort = sort {
                urlString += "&sort=\(sort.rawValue)"
            }
            if let order = order {
                urlString += "&order=\(order.rawValue)"
            }
            return urlString
        }
        
        return url.absoluteString
    }
}

/// Ключи для UserDefaults
enum UserDefaultsKeys {
    static let favoriteUsers = "favoriteUsers"
    static let cacheTimestamp = "cacheTimestamp"
}

