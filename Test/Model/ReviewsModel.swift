struct ReviewsModel {
    let count: Int
    let items: [ReviewModel]

    static let empty = ReviewsModel(count: 0, items: [])
}

extension ReviewsDto {
    var model: ReviewsModel {
        ReviewsModel(count: count, items: items.map { $0.model })
    }
}
