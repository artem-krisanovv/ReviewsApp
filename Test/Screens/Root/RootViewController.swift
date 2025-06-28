import UIKit

final class RootViewController: UIViewController {
    // MARK: - Private Properties
    
    private let navigationService: NavigationProtocol
    private lazy var rootView = RootView(onTapReviews: { [weak self] in
        self?.navigationService.showReviews()
    })
    
    // MARK: - Initialization
    
    init(navigationService: NavigationProtocol) {
        self.navigationService = navigationService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        view = rootView
    }
}
