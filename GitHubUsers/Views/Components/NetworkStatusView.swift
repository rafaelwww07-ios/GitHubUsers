//
//  NetworkStatusView.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Компонент для отображения статуса сети
struct NetworkStatusView: View {
    @StateObject private var reachability = NetworkReachabilityService.shared
    @State private var showBanner = false
    
    var body: some View {
        Group {
            if !reachability.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("No internet connection")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .foregroundColor(.orange)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: reachability.isConnected)
    }
}

