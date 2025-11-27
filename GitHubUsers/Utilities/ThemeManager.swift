//
//  ThemeManager.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI
import Combine

/// Тип темы приложения
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
    
    var displayName: String {
        switch self {
        case .system:
            return "settings.theme.system".localized
        case .light:
            return "settings.theme.light".localized
        case .dark:
            return "settings.theme.dark".localized
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

/// Менеджер для управления темой приложения
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
    }
}

