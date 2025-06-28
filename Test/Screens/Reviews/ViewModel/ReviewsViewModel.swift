import UIKit

protocol ReviewsViewModelDelegate: AnyObject {
    func reviewsViewModel(_ viewModel: ReviewsViewModel, didUpdateItemAt index: Int)
}

final class ReviewsViewModel: NSObject {
    // MARK: - Public Properties
    
    var onStateChange: ((State) -> Void)?
    weak var delegate: ReviewsViewModelDelegate?
    
    // MARK: - Private Properties
    
    private var state: State
    private let ratingRenderer: RatingRenderer
    private let imageService: ImageServiceProtocol
    private let networkService: ReviewsNetworkServiceProtocol
    
    private var loadingTask: Task<Void, Never>?
    private var photoLoadingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.reviews.photoLoading"
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    private var isLoading = false
    private var hasLoadedInitialData = false
    
    private var loadedReviewIds: Set<Int> = []
    private var loadedPhotos: [String: UIImage] = [:]
    private var loadingPhotos: Set<String> = []
    
    // MARK: - Initialization
    
    init(
        state: State = State(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        imageService: ImageServiceProtocol,
        networkService: ReviewsNetworkServiceProtocol
    ) {
        self.state = state
        self.ratingRenderer = ratingRenderer
        self.imageService = imageService
        self.networkService = networkService
        super.init()
    }
    deinit {
        cancelAllTasks()
    }
}

// MARK: - Public Methods

extension ReviewsViewModel {
    typealias State = ReviewsViewModelState
    
    func getReviews() {
        guard state.shouldLoad, !isLoading else { return }
        
        isLoading = true
        state.loadingState = hasLoadedInitialData ? .loading : .initial
        onStateChange?(state)
        
        if !hasLoadedInitialData {
            cancelAllTasks()
            state.items.removeAll()
            loadedReviewIds.removeAll()
        }
        
        loadingTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let reviewsDto = try await self.networkService.fetchReviews()
                let reviews = reviewsDto.model
                
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.handleNewReviews(reviews)
                    self.state.loadingState = .loaded
                    self.onStateChange?(self.state)
                }
            } catch {
                if !Task.isCancelled {
                    print("Failed to fetch reviews: \(error)")
                    await MainActor.run {
                        self.state.loadingState = .error(error.localizedDescription)
                        self.onStateChange?(self.state)
                    }
                }
            }
            self.isLoading = false
        }
    }
    
    func reloadReviews() {
        hasLoadedInitialData = false
        state.shouldLoad = true
        getReviews()
    }
    
    func collapseAllExpandedCells() {
        for (index, item) in state.items.enumerated() {
            guard var reviewItem = item as? ReviewItem,
                  reviewItem.maxLines == 0 else { continue }
            
            reviewItem.maxLines = 3
            state.items[index] = reviewItem
            delegate?.reviewsViewModel(self, didUpdateItemAt: index)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }
}

// MARK: - Private Methods

private extension ReviewsViewModel {
    func cancelAllTasks() {
        loadingTask?.cancel()
        photoLoadingQueue.cancelAllOperations()
        loadingPhotos.removeAll()
    }
    
    func handleNewReviews(_ reviews: ReviewsModel) {
        let newReviews = reviews.items.filter { review in
            !self.loadedReviewIds.contains(review.id)
        }
        
        newReviews.forEach { review in
            self.loadedReviewIds.insert(review.id)
        }
        
        let newItems = newReviews.map { self.makeReviewItem($0) }
        self.state.items += newItems
        
        for (review, item) in zip(newReviews, newItems) {
            if let photoURLs = review.photo_review?.photo_review {
                for photoURL in photoURLs {
                    self.loadPhoto(url: photoURL, for: item.id)
                }
            }
        }
        
        self.hasLoadedInitialData = true
        self.state.shouldLoad = !newReviews.isEmpty
        
        self.onStateChange?(self.state)
    }
    
    func loadPhoto(url: String, for reviewId: UUID) {
        guard !loadingPhotos.contains(url) else { return }
        guard loadedPhotos[url] == nil else { return }
        
        loadingPhotos.insert(url)
        
        guard let imageURL = URL(string: url) else {
            loadingPhotos.remove(url)
            return
        }
        
        let operation = BlockOperation { [weak self] in
            guard let self = self else { return }
            
            Task {
                do {
                    let image = try await self.imageService.loadImage(from: imageURL)
                    
                    await MainActor.run {
                        self.handleLoadedPhoto(url: url, image: image)
                    }
                } catch {
                    await MainActor.run {
                        self.loadingPhotos.remove(url)
                        print("Failed to load photo: \(error)")
                    }
                }
            }
        }
        photoLoadingQueue.addOperation(operation)
    }
    
    func handleLoadedPhoto(url: String, image: UIImage) {
        loadedPhotos[url] = image
        loadingPhotos.remove(url)
        
        for (itemIndex, reviewItem) in state.items.enumerated() {
            guard var updatedItem = reviewItem as? ReviewItem else { continue }
            
            if let photoIndex = updatedItem.photoReviews.firstIndex(where: { $0.id == url }) {
                updatedItem.photoReviews[photoIndex].image = image
                state.items[itemIndex] = updatedItem
                delegate?.reviewsViewModel(self, didUpdateItemAt: itemIndex)
            }
        }
    }
    
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        
        item.maxLines = 0
        state.items[index] = item
        delegate?.reviewsViewModel(self, didUpdateItemAt: index)
    }
    
    func collapseReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem,
            item.maxLines == 0
        else { return }
        
        item.maxLines = 3
        state.items[index] = item
        delegate?.reviewsViewModel(self, didUpdateItemAt: index)
    }
}

// MARK: - Items

private extension ReviewsViewModel {
    typealias ReviewItem = ReviewCellConfig
    
    func makeReviewItem(_ review: ReviewModel) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let username = "\(review.user.firstName) \(review.user.lastName)".attributed(font: .username)
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        
        let photoURLs = review.photo_review?.photo_review ?? []
        
        let photoReviews = photoURLs.map { photoURL in
            ReviewCellConfig.PhotoReview(
                id: photoURL,
                image: loadedPhotos[photoURL]
            )
        }
        
        let item = ReviewItem(
            reviewText: reviewText,
            avatarImage: nil,
            username: username,
            ratingImage: ratingImage,
            created: created,
            photoReviews: photoReviews,
            onTapShowMore: { [weak self] id in
                self?.showMoreReview(with: id)
            }
        )
        
        loadAvatarForItem(item, avatarURL: review.user.avatarURL)
        
        return item
    }
    
    func loadAvatarForItem(_ item: ReviewItem, avatarURL: String) {
        guard let avatarURL = URL(string: avatarURL) else { return }
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                let avatarImage = try await self.imageService.loadImage(from: avatarURL)
                
                await MainActor.run {
                    if let index = self.state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == item.id }) {
                        var updatedItem = item
                        updatedItem.avatarImage = avatarImage
                        self.state.items[index] = updatedItem
                        self.delegate?.reviewsViewModel(self, didUpdateItemAt: index)
                    }
                }
            } catch {
                print("Failed to load avatar: \(error)")
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseIdentifier, for: indexPath)
        config.update(cell: cell)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if velocity.y > 0 {
            if let tableView = scrollView as? UITableView {
                let visibleItems = tableView.indexPathsForVisibleRows ?? []
                
                guard !visibleItems.isEmpty else { return }
                
                let lastVisibleRow = visibleItems.last?.row ?? 0
                
                if lastVisibleRow > state.items.count - (state.items.count/2) {
                    getReviews()
                }
            }
        }
    }
}
