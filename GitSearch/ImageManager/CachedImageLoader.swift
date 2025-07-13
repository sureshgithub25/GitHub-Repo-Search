//
//  CachedImageLoader.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import Foundation
import Combine
import UIKit

final class CachedImageLoader {
    static let shared = CachedImageLoader()
    private let cache: NSCache<NSString, UIImage>
    
    init(cache: NSCache<NSString, UIImage> = NSCache()) {
        self.cache = cache
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage, Error> {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return Just(cachedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw APIError.imageProcessingFailed
                }
                self.cache.setObject(image, forKey: url.absoluteString as NSString)
                return image
            }
            .eraseToAnyPublisher()
    }
}


