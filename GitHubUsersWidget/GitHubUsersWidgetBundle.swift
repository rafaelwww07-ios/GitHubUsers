//
//  GitHubUsersWidgetBundle.swift
//  GitHubUsersWidget
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import WidgetKit
import SwiftUI

@main
struct GitHubUsersWidgetBundle: WidgetBundle {
    var body: some Widget {
        GitHubUsersWidget()
        // Раскомментируйте, если нужны дополнительные виджеты:
        // GitHubUsersWidgetControl()
        // GitHubUsersWidgetLiveActivity()
    }
}
