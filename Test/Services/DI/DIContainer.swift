import UIKit

final class DIContainer {
    static let shared = DIContainer()
    private init() {}
    
    // MARK: - Services
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()
    
    lazy var imageCache: CachingProtocol = {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let maxCacheSize = min(
            50 * 1024 * 1024,
            Int(Double(physicalMemory) * 0.25)
        )
        return ImageCache(countLimit: 50, totalCostLimit: maxCacheSize)
    }()
    
    lazy var imageService: ImageServiceProtocol = {
        ImageService(cache: imageCache)
    }()
    
    // MARK: - Factories
    
    func makeReviewsScreenFactory() -> ReviewsScreenFactoryProtocol {
        ReviewsScreenFactory(
            networkService: networkService,
            imageService: imageService
        )
    }
    
    func makeNavigationService(navigationController: UINavigationController) -> NavigationProtocol {
        NavigationService(
            navigationController: navigationController,
            factory: makeReviewsScreenFactory()
        )
    }
}

