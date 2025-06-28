import UIKit

final class ReviewsViewController: UIViewController {
    // MARK: - Private Properties
    
    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    private var isInitialLoad = true
    
    // MARK: - Initialization
    
    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupRefreshControl()
        viewModel.reloadReviews()
    }
}

// MARK: - Private Methods

private extension ReviewsViewController {
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        setupTableView(reviewsView.tableView)
        return reviewsView
    }
    
    func setupTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = viewModel
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseIdentifier)
    }
    
    func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleStateChange(state)
            }
        }
    }
    
    func setupRefreshControl() {
        reviewsView.refreshControl.addTarget(
            self,
            action: #selector(handleRefresh),
            for: .valueChanged
        )
    }
    
    func handleStateChange(_ state: ReviewsViewModel.State) {
        switch state.loadingState {
        case .initial:
            if isInitialLoad {
                reviewsView.showInitialLoading()
            }
        case .loading:
            break
        case .loaded:
            isInitialLoad = false
            reviewsView.hideLoading()
            updateContent(with: state)
        case .error(let message):
            isInitialLoad = false
            reviewsView.hideLoading()
            showError(message)
        }
    }
    
    func updateContent(with state: ReviewsViewModel.State) {
        UIView.performWithoutAnimation {
            reviewsView.tableView.reloadData()
            reviewsView.updateReviewsCount(state.items.count)
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func handleRefresh() {
        viewModel.reloadReviews()
    }
}

// MARK: - UITableViewDelegate

extension ReviewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.collapseAllExpandedCells()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var point = CGPoint.zero
        viewModel.scrollViewWillEndDragging(scrollView, withVelocity: .zero, targetContentOffset: &point)
    }
}

// MARK: - ReviewsViewModelDelegate

extension ReviewsViewController: ReviewsViewModelDelegate {
    func reviewsViewModel(_ viewModel: ReviewsViewModel, didUpdateItemAt index: Int) {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.reviewsView.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
}
