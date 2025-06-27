import UIKit

enum ImageServiceError: Error {
    case invalidData
    case networkError(Error)
}

protocol ImageServiceProtocol {
    func loadImage(from url: URL?) async throws -> UIImage
}

/// Actor that handles image loading and caching
actor ImageService: ImageServiceProtocol {
    // MARK: - Private Properties
    
    private let cache: CachingProtocol
    
    // MARK: - Initialization
    
    init(cache: CachingProtocol) {
        self.cache = cache
    }
    
    // MARK: - ImageServiceProtocol
    
    func loadImage(from url: URL?) async throws -> UIImage {
        guard let url else { return UIImage() }
        
        if let cachedImage = cache.getObject(forKey: url as NSURL) {
            return cachedImage
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let image = UIImage(data: data) else {
                throw ImageServiceError.invalidData
            }
            
            cache.setObject(image, forKey: url as NSURL, cost: data.count)

            return image
        } catch {
            throw ImageServiceError.networkError(error)
        }
    }
}
