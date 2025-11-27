//
//  RepositoryDetailViewModel.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Combine
import UIKit

/// ViewModel для детального экрана репозитория
@MainActor
class RepositoryDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var repository: RepositoryDetail?
    @Published var loadingState: LoadingState = .loading
    
    // MARK: - Private Properties
    private let owner: String
    private let repo: String
    private let apiService: GitHubAPIServiceProtocol
    
    // MARK: - Initialization
    init(
        owner: String,
        repo: String,
        apiService: GitHubAPIServiceProtocol = GitHubAPIService()
    ) {
        self.owner = owner
        self.repo = repo
        self.apiService = apiService
        
        loadRepository()
    }
    
    // MARK: - Public Methods
    /// Загрузка детальной информации о репозитории
    func loadRepository() {
        loadingState = .loading
        
        Task {
            do {
                let loadedRepo = try await apiService.getRepository(owner: owner, repo: repo)
                self.repository = loadedRepo
                self.loadingState = .loaded
            } catch {
                self.loadingState = .error(error.localizedDescription)
            }
        }
    }
    
    /// Открытие репозитория в Safari
    func openInSafari() {
        guard let repository = repository,
              let url = URL(string: repository.htmlURL) else { return }
        UIApplication.shared.open(url)
    }
    
    /// Форматирование даты в красивый читаемый формат
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            // Пробуем без fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateString) else {
                return dateString
            }
            return formatDate(date)
        }
        
        return formatDate(date)
    }
    
    /// Форматирование даты с относительным временем
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Если дата сегодня - показываем время
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            timeFormatter.locale = Locale.current
            return timeFormatter.string(from: date)
        }
        
        // Если дата вчера
        if calendar.isDateInYesterday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            timeFormatter.locale = Locale.current
            return String(format: "Yesterday, %@", timeFormatter.string(from: date))
        }
        
        // Если дата в этом году - показываем день и месяц
        if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            dateFormatter.locale = Locale.current
            return dateFormatter.string(from: date)
        }
        
        // Для старых дат - полный формат
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
    
    /// Форматирование размера репозитория
    func formatSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size * 1024)) // size в KB
    }
}

