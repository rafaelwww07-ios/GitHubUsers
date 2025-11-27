//
//  SettingsView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Экран настроек приложения
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    private let cacheService: CacheServiceProtocol = CacheService()
    @State private var showingClearCacheAlert = false
    @State private var cacheCleared = false
    
    @State private var selectedLanguage: String = LocalizationManager.shared.currentLanguage
    @State private var selectedTheme: AppTheme = ThemeManager.shared.currentTheme
    
    var body: some View {
        NavigationView {
            Form {
                // О приложении
                Section {
                    HStack {
                        Text("app.version".localized)
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("app.build".localized)
                        Spacer()
                        Text(appBuild)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("settings.about".localized)
                }
                
                // Кэш
                Section {
                    Button(action: {
                        showingClearCacheAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("settings.clear.cache".localized)
                                .foregroundColor(.red)
                        }
                    }
                    
                    if cacheCleared {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("settings.cache.cleared".localized)
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("settings.storage".localized)
                } footer: {
                    Text("settings.cache.description".localized)
                }
                
                // Язык
                Section {
                    Picker("settings.language".localized, selection: $selectedLanguage) {
                        ForEach(LocalizationManager.shared.availableLanguages, id: \.self) { language in
                            Text(language == "en" ? "English" : "Русский")
                                .tag(language)
                        }
                    }
                    .onChange(of: selectedLanguage) { _ in
                        updateLanguage()
                    }
                } header: {
                    Text("settings.language".localized)
                }
                
                // Тема
                Section {
                    Picker("settings.theme".localized, selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName)
                                .tag(theme)
                        }
                    }
                    .onChange(of: selectedTheme) { _ in
                        updateTheme()
                    }
                } header: {
                    Text("settings.theme".localized)
                }
                
                // Ссылки
                Section {
                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Image(systemName: "link")
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("settings.links".localized)
                }
            }
            .navigationTitle("settings.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("nav.done".localized) {
                        dismiss()
                    }
                }
            }
            .alert("alert.clear.cache.title".localized, isPresented: $showingClearCacheAlert) {
                Button("alert.clear.cache.cancel".localized, role: .cancel) { }
                Button("alert.clear.cache.confirm".localized, role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("alert.clear.cache.message".localized)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Actions
    private func clearCache() {
        cacheService.clearCache()
        ImageCacheService.shared.clearCache()
        cacheCleared = true
        HapticFeedbackManager.shared.success()
        
        // Скрываем сообщение через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            cacheCleared = false
        }
    }
    
    private func updateLanguage() {
        localizationManager.currentLanguage = selectedLanguage
    }
    
    private func updateTheme() {
        themeManager.currentTheme = selectedTheme
    }
}

#Preview {
    SettingsView()
}

