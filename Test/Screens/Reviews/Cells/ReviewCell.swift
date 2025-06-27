import UIKit

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    
    static let reuseIdentifier = "ReviewCell"
    
    // MARK: - Public Properties
    
    let reviewTextLabel = UILabel()
    let createdLabel = UILabel()
    let showMoreButton = UIButton(type: .system)
    internal let avatarContainer = AvatarContainer()
    let usernameLabel = UILabel()
    let ratingImageView = UIImageView()
    let photoReviewsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    // MARK: - Private Properties
    
    internal var config: ReviewCellConfig?
    let photoReviewContainer = PhotoReviewContainer()
    let layout = ReviewCellLayout()
    
    // MARK: - Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        applyLayout(layout)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearContent()
    }
}

// MARK: - Private Methods

private extension ReviewCell {
    func setupCell() {
        setupSubviews()
        setupAvatarContainer()
        setupReviewTextLabel()
        setupShowMoreButton()
        setupRatingImageView()
    }
    
    func setupSubviews() {
        [avatarContainer, usernameLabel, ratingImageView, photoReviewsStackView,
         reviewTextLabel, createdLabel, showMoreButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    func setupAvatarContainer() {
        avatarContainer.clipsToBounds = true
        avatarContainer.layer.shouldRasterize = true
        avatarContainer.layer.rasterizationScale = UIScreen.main.scale
        avatarContainer.frame.size = Layout.avatarSize
    }
    
    func setupReviewTextLabel() {
        reviewTextLabel.numberOfLines = 3
        reviewTextLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setupShowMoreButton() {
        showMoreButton.contentVerticalAlignment = .center
        showMoreButton.contentHorizontalAlignment = .left
        showMoreButton.titleLabel?.lineBreakMode = .byTruncatingTail
        showMoreButton.setAttributedTitle(
            "Показать полностью...".attributed(font: .showMore, color: .showMore),
            for: .normal
        )
        showMoreButton.addAction(UIAction { [weak self] _ in
            guard let self = self, let config = self.config else { return }
            config.onTapShowMore(config.id)
        }, for: .touchUpInside)
    }
    
    func setupRatingImageView() {
        ratingImageView.contentMode = .left
        ratingImageView.layer.shouldRasterize = true
        ratingImageView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func applyLayout(_ layout: ReviewCellLayout) {
        avatarContainer.frame = layout.avatarImageViewFrame
        avatarContainer.layer.cornerRadius = Layout.avatarCornerRadius
        usernameLabel.frame = layout.usernameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        photoReviewsStackView.frame = layout.photoReviewsStackViewFrame
        
        showMoreButton.isHidden = layout.showMoreButtonFrame == .zero
    }
    
    func clearContent() {
        reviewTextLabel.attributedText = nil
        createdLabel.attributedText = nil
        usernameLabel.attributedText = nil
        ratingImageView.image = nil
        showMoreButton.isHidden = true
        
        photoReviewsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        config = nil
    }
}

// MARK: - Layout Constants

private enum Layout {
    static let avatarSize = CGSize(width: 36.0, height: 36.0)
    static let avatarCornerRadius = 18.0
    static let photoCornerRadius = 4.0
    static let photoReviewSize: CGFloat = 75
}


