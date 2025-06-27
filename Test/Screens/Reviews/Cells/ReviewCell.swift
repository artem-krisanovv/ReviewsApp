import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {



}

// MARK: - TableCellConfig

extension ReviewCellConfig {

    

}

// MARK: - Private

private extension ReviewCellConfig {


}

// MARK: - Cell

final class ReviewCell: UITableViewCell {



}

// MARK: - Private

private extension ReviewCell {


}

// MARK: - Layout

private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero

    // MARK: - Отступы

    
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    private let avatarToUsernameSpacing = 10.0
 
    private let usernameToRatingSpacing = 6.0
 
    private let ratingToTextSpacing = 6.0
  
    private let ratingToPhotosSpacing = 10.0
  
    private let photosSpacing = 8.0
    
    private let photosToTextSpacing = 10.0

    private let reviewTextToCreatedSpacing = 6.0
   
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height() {
       

}

// MARK: - Typealias

