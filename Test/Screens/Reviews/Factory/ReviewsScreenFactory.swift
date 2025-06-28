import UIKit

protocol ReviewsScreenFactoryProtocol {
    func makeReviewsController() -> ReviewsViewController
}

final class ReviewsScreenFactory: ReviewsScreenFactoryProtocol {
    // MARK: - Private Properties
    
    private let networkService: NetworkServiceProtocol
    private let imageService: ImageServiceProtocol
    
    // MARK: - Initialization
    
    init(
        networkService: NetworkServiceProtocol,
        imageService: ImageServiceProtocol
    ) {
        self.networkService = networkService
        self.imageService = imageService
    }
    
    // MARK: - ReviewsScreenFactoryProtocol
    
    func makeReviewsController() -> ReviewsViewController {
        let reviewsNetworkService = ReviewsNetworkService(networkService: networkService)
        
        let viewModel = ReviewsViewModel(
            imageService: imageService,
            networkService: reviewsNetworkService
        )
        
        let controller = ReviewsViewController(viewModel: viewModel)
        return controller
    }
}
