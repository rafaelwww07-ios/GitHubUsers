//
//  GitHubUsersWidget.swift
//  GitHubUsersWidget
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct GitHubUserEntry: TimelineEntry {
    let date: Date
    let users: [SimpleUser]
}

struct SimpleUser: Codable {
    let login: String
    let avatarURL: String
    let followers: Int
}

// MARK: - Timeline Provider
struct GitHubUsersTimelineProvider: TimelineProvider {
    typealias Entry = GitHubUserEntry
    
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), users: [
            SimpleUser(login: "octocat", avatarURL: "https://github.com/images/error/octocat_happy.gif", followers: 1000),
            SimpleUser(login: "github", avatarURL: "https://github.com/images/error/octocat_happy.gif", followers: 500)
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(date: Date(), users: loadFavorites())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let entry = Entry(date: currentDate, users: loadFavorites())
        
        // Обновляем каждые 15 минут
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadFavorites() -> [SimpleUser] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.githubusers.shared"),
              let data = sharedDefaults.data(forKey: "favoriteUsers"),
              let fullUsers = try? JSONDecoder().decode([FullUser].self, from: data) else {
            return []
        }
        
        let simpleUsers = fullUsers.map { user in
            SimpleUser(
                login: user.login,
                avatarURL: user.avatarURL,
                followers: user.followers
            )
        }
        
        return Array(simpleUsers.prefix(3))
    }
}

// MARK: - Full User Model (для декодирования из UserDefaults)
private struct FullUser: Codable {
    let login: String
    let avatarURL: String
    let followers: Int
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case followers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        login = try container.decode(String.self, forKey: .login)
        avatarURL = try container.decode(String.self, forKey: .avatarURL)
        followers = try container.decode(Int.self, forKey: .followers)
    }
}

// MARK: - Widget View
struct GitHubUsersWidgetView: View {
    var entry: GitHubUsersTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        default:
            smallWidgetView
        }
    }
    
    // MARK: - Small Widget
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorites")
                .font(.headline)
                .foregroundColor(.primary)
            
            if entry.users.isEmpty {
                VStack {
                    Image(systemName: "heart.slash")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("No favorites")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ForEach(Array(entry.users.prefix(2)), id: \.login) { user in
                    HStack(spacing: 8) {
                        AsyncImage(url: URL(string: user.avatarURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.login)
                                .font(.caption)
                                .bold()
                                .lineLimit(1)
                            Text("\(user.followers)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    // MARK: - Medium Widget
    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorite Users")
                .font(.headline)
                .foregroundColor(.primary)
            
            if entry.users.isEmpty {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "heart.slash")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No favorites yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                ForEach(entry.users, id: \.login) { user in
                    HStack(spacing: 10) {
                        AsyncImage(url: URL(string: user.avatarURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.login)
                                .font(.subheadline)
                                .bold()
                                .lineLimit(1)
                            Text("\(user.followers) followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration
struct GitHubUsersWidget: Widget {
    let kind: String = "GitHubUsersWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GitHubUsersTimelineProvider()) { entry in
            GitHubUsersWidgetView(entry: entry)
        }
        .configurationDisplayName("GitHub Users")
        .description("Shows your favorite GitHub users")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    GitHubUsersWidget()
} timeline: {
    GitHubUserEntry(date: .now, users: [
        SimpleUser(login: "octocat", avatarURL: "https://github.com/images/error/octocat_happy.gif", followers: 1000),
        SimpleUser(login: "github", avatarURL: "https://github.com/images/error/octocat_happy.gif", followers: 500)
    ])
}
