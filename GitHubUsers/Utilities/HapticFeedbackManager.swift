//
//  HapticFeedbackManager.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import UIKit

/// Менеджер для тактильной обратной связи
class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    private init() {}
    
    /// Успешное действие
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Ошибка
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Предупреждение
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Выбор элемента
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Легкий удар
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Средний удар
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Сильный удар
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

