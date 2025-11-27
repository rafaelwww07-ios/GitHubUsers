# GitHub Users - iOS Portfolio App

A comprehensive iOS application demonstrating Senior iOS Developer skills, built with modern SwiftUI, Clean Architecture, and best practices.

## 📱 Overview

GitHub Users is a feature-rich iOS application for searching and exploring GitHub users and repositories. The app showcases professional iOS development practices including Clean Architecture, MVVM pattern, async/await, Combine, localization, widgets, and comprehensive testing.

## ✨ Features

### Core Functionality
- **User Search** - Search GitHub users by username with debouncing and pagination
- **User Profiles** - Detailed user information with statistics and bio
- **Repositories** - View user repositories with sorting, filtering, and search
- **Repository Details** - Comprehensive repository information with metadata
- **Global Repository Search** - Search across all GitHub repositories
- **Favorites** - Save favorite users and repositories locally
- **Search History** - Quick access to recent searches

### Technical Features
- **Offline Support** - Two-level caching (memory + disk) for offline access
- **Internationalization** - Full support for English and Russian
- **Theming** - Light, dark, and system theme support
- **Widgets** - Home screen widgets showing favorite users
- **Deep Linking** - Custom URL schemes and Universal Links support
- **Accessibility** - VoiceOver and Dynamic Type support
- **Haptic Feedback** - Tactile feedback for user actions
- **Image Caching** - Optimized image loading and caching
- **Network Monitoring** - Real-time network status indicator
- **Charts** - Visual statistics using SwiftUI Charts
- **Performance Monitoring** - Built-in performance tracking

## 🏗️ Architecture

The app follows **Clean Architecture** principles with **MVVM** pattern for the presentation layer.

### Project Structure

```
GitHubUsers/
├── Models/              # Domain models
├── Services/            # Business logic and services
├── Repositories/        # Data layer abstraction
├── ViewModels/          # Presentation logic (MVVM)
├── Views/               # SwiftUI views
├── Utilities/           # Helper classes and managers
└── Constants/          # App constants
```

### Architecture Layers

1. **Domain Layer** - Models and business entities
2. **Data Layer** - Services, repositories, and data sources
3. **Presentation Layer** - ViewModels and Views

## 🛠️ Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **Async/Await** - Asynchronous operations
- **Combine** - Reactive programming
- **MVVM** - Presentation pattern
- **Clean Architecture** - Layered architecture
- **WidgetKit** - Home screen widgets
- **SwiftUI Charts** - Data visualization

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## 🚀 Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd GitHubUsers
```

2. Open the project in Xcode:
```bash
open GitHubUsers.xcodeproj
```

Or simply double-click `GitHubUsers.xcodeproj` in Finder.

3. Configure App Groups (for widgets):
   - Select the project → Targets → GitHubUsers
   - Signing & Capabilities → Add "App Groups"
   - Create/select: `group.com.githubusers.shared`
   - Repeat for GitHubUsersWidgetExtension target

4. Build and run (⌘R)

## 🧪 Testing

The project includes comprehensive unit tests:

```bash
# Run tests
⌘U in Xcode
```

Test coverage:
- ViewModels (UserList, UserDetail, RepositoryList)
- Services (Favorites, SearchHistory)
- Repositories (UserRepository)

## 📸 Screenshots

> Add screenshots to `Screenshots/` directory

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This project is created for portfolio demonstration purposes.

## 👤 Author

Rafael Mukhametov - Senior iOS Developer

---

Built with ❤️ using SwiftUI and modern iOS development practices.
