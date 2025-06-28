import UIKit

struct ReviewCellConfig {
    // MARK: - Public Properties
    
    static let reuseId = ReviewCell.reuseIdentifier
    let id = UUID()
    
    // MARK: - Internal Properties
    
    let reviewText: NSAttributedString
    let username: NSAttributedString
    let ratingImage: UIImage
    let created: NSAttributedString
    var avatarImage: UIImage?
    var maxLines = 3
    var photoReviews: [PhotoReview]
    let onTapShowMore: (UUID) -> Void
    internal let layout = ReviewCellLayout()
    
    // MARK: - Private Properties
    
    private static let heightCache = NSCache<NSString, NSNumber>()
    
    // MARK: - Initialization
    
    init(
        reviewText: NSAttributedString,
        avatarImage: UIImage?,
        username: NSAttributedString,
        ratingImage: UIImage,
        created: NSAttributedString,
        photoReviews: [PhotoReview],
        onTapShowMore: @escaping (UUID) -> Void
    ) {
        self.reviewText = reviewText
        self.avatarImage = avatarImage
        self.username = username
        self.ratingImage = ratingImage
        self.created = created
        self.photoReviews = photoReviews
        self.onTapShowMore = onTapShowMore
    }
}

// MARK: - PhotoReview

extension ReviewCellConfig {
    struct PhotoReview {
        let id: String
        var image: UIImage?
    }
}

// MARK: - Height Calculation

extension ReviewCellConfig {
    func height(with size: CGSize) -> CGFloat {
        let cacheKey = "\(id):\(size.width)" as NSString
        
        if let cachedHeight = Self.heightCache.object(forKey: cacheKey) {
            return CGFloat(cachedHeight.doubleValue)
        }
        
        let height = layout.height(config: self, maxWidth: size.width)
        Self.heightCache.setObject(NSNumber(value: Double(height)), forKey: cacheKey)
        
        return height
    }
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        
        clearHeightCache(for: cell)
        updateCellContent(cell)
        updateAvatar(cell)
        updatePhotoReviews(cell)
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }
    
    private func clearHeightCache(for cell: ReviewCell) {
        let cacheKey = "\(id):\(cell.bounds.width)" as NSString
        Self.heightCache.removeObject(forKey: cacheKey)
    }
    
    private func updateCellContent(_ cell: ReviewCell) {
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.usernameLabel.attributedText = username
        cell.ratingImageView.image = ratingImage
        cell.config = self
    }
    
    private func updateAvatar(_ cell: ReviewCell) {
        cell.avatarContainer.imageView.image = avatarImage
        if avatarImage == nil {
            cell.avatarContainer.loadingIndicator.startAnimating()
            cell.avatarContainer.imageView.backgroundColor = .systemGray6
        } else {
            cell.avatarContainer.loadingIndicator.stopAnimating()
            cell.avatarContainer.imageView.backgroundColor = .clear
        }
    }
    
    private func updatePhotoReviews(_ cell: ReviewCell) {
        cell.photoReviewsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for photoReview in photoReviews {
            let container = createPhotoReviewContainer(for: photoReview)
            cell.photoReviewsStackView.addArrangedSubview(container)
        }
    }
    
    private func createPhotoReviewContainer(for photoReview: PhotoReview) -> PhotoReviewContainer {
        let container = PhotoReviewContainer()
        container.layer.cornerRadius = ReviewCellLayout.photoCornerRadius
        container.clipsToBounds = true
        container.photoId = photoReview.id
        
        setupPhotoContainerConstraints(container)
        updatePhotoContainerContent(container, with: photoReview)
        
        return container
    }
    
    private func setupPhotoContainerConstraints(_ container: PhotoReviewContainer) {
        let widthConstraint = NSLayoutConstraint(
            item: container,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: ReviewCellLayout.photoReviewSize
        )
        
        let heightConstraint = NSLayoutConstraint(
            item: container,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: ReviewCellLayout.photoReviewSize
        )
        container.addConstraints([widthConstraint, heightConstraint])
    }
    
    private func updatePhotoContainerContent(_ container: PhotoReviewContainer, with photoReview: PhotoReview) {
        container.imageView.image = photoReview.image
        if photoReview.image == nil {
            container.loadingIndicator.startAnimating()
            container.imageView.backgroundColor = .systemGray6
        } else {
            container.loadingIndicator.stopAnimating()
            container.imageView.backgroundColor = .clear
        }
    }
}

