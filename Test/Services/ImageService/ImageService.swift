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
    
    private var networkService: NetworkServiceProtocol?
    private let cache: NSCache<NSURL, UIImage>
    
    // MARK: - Initialization
    
    init(cacheLimit: Int = 100, cacheSizeLimit: Int = 1024 * 1024 * 100) {
        self.cache = NSCache<NSURL, UIImage>()
        self.cache.countLimit = cacheLimit
        self.cache.totalCostLimit = cacheSizeLimit
    }
    
    // MARK: - ImageServiceProtocol
    
    func loadImage(from url: URL?) async throws -> UIImage {
        guard let url else { return UIImage() }
        
        _ = url.absoluteString as NSString
        
        if let cachedImage = cache.object(forKey: url as NSURL) {
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
