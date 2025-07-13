//
//  CachedAsyncImage.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import SwiftUI
import Foundation
import Combine

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    private var cancellable: AnyCancellable?
    private var cache: ImageCache
    
    init(url: URL, cache: ImageCache = TemporaryImageCache.shared) {
        self.url = url
        self.cache = cache
        loadImage()
    }
    
    private func loadImage() {
        if let image = cache[url] {
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self, let image = $0 else { return }
                self.cache[url] = image
                self.image = image
            }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

final class TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    static let shared = TemporaryImageCache()
    private init() {}
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

struct CachedAsyncImage: View {
    @StateObject private var loader: ImageLoader
    private let url: URL
    private let placeholder: Image
    
    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
            }
        }
    }
}
