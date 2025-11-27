//
//  RepositorySort.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

/// Способы сортировки репозиториев
enum RepositorySort: String, CaseIterable {
    case created
    case updated
    case pushed
    case fullName = "full_name"
    case stars
    
    var displayName: String {
        switch self {
        case .created:
            return "sort.created".localized
        case .updated:
            return "sort.updated".localized
        case .pushed:
            return "sort.pushed".localized
        case .fullName:
            return "sort.name".localized
        case .stars:
            return "sort.stars".localized
        }
    }
}

/// Порядок сортировки
enum RepositoryOrder: String, CaseIterable {
    case asc
    case desc
    
    var displayName: String {
        switch self {
        case .asc:
            return "sort.ascending".localized
        case .desc:
            return "sort.descending".localized
        }
    }
}

