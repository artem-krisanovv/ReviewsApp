import UIKit

protocol NavigationProtocol {
    func showReviews()
}

final class NavigationService: NavigationProtocol {
    private let navigationController: UINavigationController
    private let factory: ReviewsScreenFactoryProtocol
    
    init(
        navigationController: UINavigationController,
        factory: ReviewsScreenFactoryProtocol
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func showReviews() {
        let controller = factory.makeReviewsController()
        navigationController.pushViewController(controller, animated: true)
    }
}
