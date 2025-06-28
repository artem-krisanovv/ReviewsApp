import UIKit

final class ReviewsView: UIView {
    // MARK: - Public Properties
    
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    // MARK: - Private Properties
    
    private let toolbarLabel = UILabel()
    private let toolbar = UIToolbar()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateReviewsCount(_ count: Int) {
        let word = pluralizedWord(for: count)
        toolbarLabel.text = "\(count) \(word)"
    }
    
    func showInitialLoading() {
        loadingIndicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.tableView.alpha = 0
        }
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        UIView.animate(withDuration: 0.25) {
            self.tableView.alpha = 1
        }
        refreshControl.endRefreshing()
    }
}

// MARK: - Private Methods
private extension ReviewsView {
    
    func setupView() {
        backgroundColor = .white
        setupSubviews()
        setupConstraints()
        setupRefreshControl()
    }
    
    func setupSubviews() {
        [tableView, toolbar, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        setupToolbar()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setupToolbar() {
        configureToolbarAppearance()
        setupToolbarLabel()
        setupToolbarItems()
    }
    
    func configureToolbarAppearance() {
        toolbar.barTintColor = .white
        toolbar.isTranslucent = false
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    func setupToolbarLabel() {
        toolbarLabel.textAlignment = .center
        toolbarLabel.font = .systemFont(ofSize: 17, weight: .regular)
        toolbarLabel.textColor = .black
        toolbarLabel.text = "0 отзывов"
    }
    
    func setupToolbarItems() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let labelItem = UIBarButtonItem(customView: toolbarLabel)
        toolbar.items = [flexibleSpace, labelItem, flexibleSpace]
    }
    
    func setupRefreshControl() {
        tableView.refreshControl = refreshControl
    }
    
    func pluralizedWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "отзывов"
        }
        
        switch lastDigit {
        case 1:
            return "отзыв"
        case 2, 3, 4:
            return "отзыва"
        default:
            return "отзывов"
        }
    }
}
