//
//  GitHubUsersWidgetLiveActivity.swift
//  GitHubUsersWidget
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GitHubUsersWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GitHubUsersWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GitHubUsersWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GitHubUsersWidgetAttributes {
    fileprivate static var preview: GitHubUsersWidgetAttributes {
        GitHubUsersWidgetAttributes(name: "World")
    }
}

extension GitHubUsersWidgetAttributes.ContentState {
    fileprivate static var smiley: GitHubUsersWidgetAttributes.ContentState {
        GitHubUsersWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GitHubUsersWidgetAttributes.ContentState {
         GitHubUsersWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GitHubUsersWidgetAttributes.preview) {
   GitHubUsersWidgetLiveActivity()
} contentStates: {
    GitHubUsersWidgetAttributes.ContentState.smiley
    GitHubUsersWidgetAttributes.ContentState.starEyes
}
