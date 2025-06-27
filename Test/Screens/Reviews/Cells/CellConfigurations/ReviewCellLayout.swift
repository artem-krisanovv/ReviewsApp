import UIKit

final class ReviewCellLayout {
    // MARK: - Public Properties
    
    static let avatarSize = CGSize(width: 36.0, height: 36.0)
    static let avatarCornerRadius = 18.0
    static let photoCornerRadius = 4.0
    static let photoReviewSize: CGFloat = 75
    static let photoSize = CGSize(width: 55.0, height: 66.0)
    
    static let showMoreButtonSize: CGSize = {
        let showMoreText = "Показать полностью..."
            .attributed(font: .showMore, color: .showMore)
        let size = showMoreText.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }()
    
    var reviewTextLabelFrame = CGRect.zero
    var showMoreButtonFrame = CGRect.zero
    var createdLabelFrame = CGRect.zero
    var avatarImageViewFrame = CGRect.zero
    var usernameLabelFrame = CGRect.zero
    var ratingImageViewFrame = CGRect.zero
    var photoReviewsStackViewFrame = CGRect.zero
    
    // MARK: - Private Properties
    
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    private let avatarToUsernameSpacing = 10.0
    private let usernameToRatingSpacing = 6.0
    private let ratingToTextSpacing = 6.0
    private let ratingToPhotosSpacing: CGFloat = 12.0
    private let photosToTextSpacing: CGFloat = 12.0
    private let reviewTextToCreatedSpacing = 6.0
    private let showMoreToCreatedSpacing = 6.0
    private let photoReviewSpacing: CGFloat = 8.0
    
    private var cachedTextCalculation: (rect: CGRect, showMore: Bool)?
    
    // MARK: - Public Methods
    
    func height(config: ReviewCellConfig, maxWidth: CGFloat) -> CGFloat {
        cachedTextCalculation = nil
        
        let width = maxWidth - insets.left - insets.right
        var maxY = layoutHeaderSection(config: config, width: width)
        maxY = layoutPhotoReviews(config: config, width: width, startY: maxY)
        maxY = layoutReviewText(config: config, width: width, startY: maxY)
        maxY = layoutShowMoreButton(config: config, width: width, startY: maxY)
        maxY = layoutCreatedLabel(config: config, width: width, startY: maxY)
        
        return maxY + insets.bottom
    }
}

// MARK: - Layout Sections

private extension ReviewCellLayout {
    func layoutHeaderSection(config: ReviewCellConfig, width: CGFloat) -> CGFloat {
        layoutAvatar()
        layoutUsername(config: config, width: width)
        layoutRating(config: config)
        
        return ratingImageViewFrame.maxY + ratingToTextSpacing
    }
    
    func layoutAvatar() {
        avatarImageViewFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: Self.avatarSize
        )
    }
    
    func layoutUsername(config: ReviewCellConfig, width: CGFloat) {
        let usernameWidth = width - avatarImageViewFrame.maxX - avatarToUsernameSpacing
        usernameLabelFrame = CGRect(
            origin: CGPoint(
                x: avatarImageViewFrame.maxX + avatarToUsernameSpacing,
                y: insets.top
            ),
            size: config.username.boundingRect(width: usernameWidth).size
        )
    }
    
    func layoutRating(config: ReviewCellConfig) {
        ratingImageViewFrame = CGRect(
            origin: CGPoint(
                x: avatarImageViewFrame.maxX + avatarToUsernameSpacing,
                y: usernameLabelFrame.maxY + usernameToRatingSpacing
            ),
            size: config.ratingImage.size
        )
    }
    
    func layoutPhotoReviews(config: ReviewCellConfig, width: CGFloat, startY: CGFloat) -> CGFloat {
        guard !config.photoReviews.isEmpty else { return startY }
        
        let availableWidth = width
        let photoSize = Self.photoReviewSize
        let totalSpacing = photoReviewSpacing * CGFloat(config.photoReviews.count - 1)
        let totalWidth = min(availableWidth, CGFloat(config.photoReviews.count) * photoSize + totalSpacing)
        
        photoReviewsStackViewFrame = CGRect(
            x: insets.left,
            y: startY + ratingToPhotosSpacing,
            width: totalWidth,
            height: photoSize
        )
        
        return photoReviewsStackViewFrame.maxY + photosToTextSpacing
    }
    
    func layoutReviewText(config: ReviewCellConfig, width: CGFloat, startY: CGFloat) -> CGFloat {
        guard !config.reviewText.isEmpty() else { return startY }
        
        let (textRect, _) = getTextCalculation(config: config, width: width)
        reviewTextLabelFrame = CGRect(
            origin: CGPoint(x: insets.left, y: startY),
            size: textRect.size
        )
        
        return reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
    }
    
    func layoutShowMoreButton(config: ReviewCellConfig, width: CGFloat, startY: CGFloat) -> CGFloat {
        let (_, showShowMoreButton) = getTextCalculation(config: config, width: width)
        
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: insets.left, y: startY),
                size: Self.showMoreButtonSize
            )
            return showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
            return startY
        }
    }
    
    func layoutCreatedLabel(config: ReviewCellConfig, width: CGFloat, startY: CGFloat) -> CGFloat {
        createdLabelFrame = CGRect(
            origin: CGPoint(x: insets.left, y: startY),
            size: config.created.boundingRect(width: width).size
        )
        return createdLabelFrame.maxY
    }
}

// MARK: - Text Calculation

private extension ReviewCellLayout {
    func getTextCalculation(config: ReviewCellConfig, width: CGFloat) -> (rect: CGRect, showMore: Bool) {
        if let cached = cachedTextCalculation {
            return cached
        }
        let result = calculateReviewTextRect(config: config, width: width)
        cachedTextCalculation = result
        return result
    }
    
    func calculateReviewTextRect(config: ReviewCellConfig, width: CGFloat) -> (rect: CGRect, showMore: Bool) {
        guard !config.reviewText.isEmpty() else {
            return (CGRect.zero, false)
        }
        
        if config.maxLines == 0 {
            return (config.reviewText.boundingRect(width: width), false)
        }
        
        let lineHeight = config.reviewText.font()?.lineHeight ?? .zero
        let maxHeight = lineHeight * CGFloat(config.maxLines)
        let fullTextRect = config.reviewText.boundingRect(width: width)
        let showShowMoreButton = fullTextRect.height > maxHeight
        let textRect = config.reviewText.boundingRect(width: width, height: maxHeight)
        
        return (textRect, showShowMoreButton)
    }
}

