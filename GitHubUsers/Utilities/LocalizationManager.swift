//
//  LocalizationManager.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import SwiftUI
import Combine

/// Менеджер для управления локализацией
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            setLanguage(currentLanguage)
        }
    }
    
    private init() {
        // Загружаем сохраненный язык или используем системный
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = savedLanguage
        } else {
            currentLanguage = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
            if currentLanguage != "ru" && currentLanguage != "en" {
                currentLanguage = "en"
            }
        }
        setLanguage(currentLanguage)
    }
    
    private func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return
        }
        // Сохраняем bundle для использования в String extension
        objc_setAssociatedObject(Bundle.main, &AssociatedKeys.localizationBundle, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    var availableLanguages: [String] {
        ["en", "ru"]
    }
    
    var languageDisplayName: String {
        switch currentLanguage {
        case "ru":
            return "Русский"
        case "en":
            return "English"
        default:
            return "English"
        }
    }
}

private struct AssociatedKeys {
    static var localizationBundle = "localizationBundle"
}

/// Расширение String для локализации
extension String {
    var localized: String {
        guard let bundle = objc_getAssociatedObject(Bundle.main, &AssociatedKeys.localizationBundle) as? Bundle else {
            return NSLocalizedString(self, comment: "")
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}

