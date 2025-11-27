//
//  UserStatsChartView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI
import Charts

/// Представление статистики пользователя в виде графика
struct UserStatsChartView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                BarMark(
                    x: .value("Type", "Repos"),
                    y: .value("Count", user.publicRepos)
                )
                .foregroundStyle(Color.blue)
                .annotation(position: .top) {
                    Text("\(user.publicRepos)")
                        .font(.caption)
                }
                
                BarMark(
                    x: .value("Type", "Followers"),
                    y: .value("Count", user.followers)
                )
                .foregroundStyle(Color.green)
                .annotation(position: .top) {
                    Text("\(user.followers)")
                        .font(.caption)
                }
                
                BarMark(
                    x: .value("Type", "Following"),
                    y: .value("Count", user.following)
                )
                .foregroundStyle(Color.orange)
                .annotation(position: .top) {
                    Text("\(user.following)")
                        .font(.caption)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    UserStatsChartView(
        user: User(
            id: 1,
            login: "octocat",
            avatarURL: "",
            name: "The Octocat",
            company: "GitHub",
            location: "San Francisco",
            bio: nil,
            publicRepos: 8,
            followers: 1000,
            following: 9,
            htmlURL: "https://github.com/octocat",
            blog: nil,
            createdAt: "2011-01-25T18:44:36Z"
        )
    )
}

