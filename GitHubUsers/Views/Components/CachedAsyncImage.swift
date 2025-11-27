//
//  CachedAsyncImage.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import SwiftUI

/// Компонент для загрузки и кэширования изображений
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            return
        }
        
        isLoading = true
        let loadedImage = await ImageCacheService.shared.loadImage(from: url)
        
        withAnimation {
            self.image = loadedImage
            self.isLoading = false
        }
    }
}

// MARK: - Convenience Initializer
extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: String?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.content = content
        self.placeholder = { ProgressView() }
    }
}

