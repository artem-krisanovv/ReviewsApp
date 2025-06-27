struct ReviewModel {
    let id: Int
    let created: String
    let rating: Int
    let text: String
    let photo_review: PhotoReviewModel?
    let user: UserModel

    static let empty = ReviewModel(
        id: 0,
        created: "",
        rating: 0,
        text: "",
        photo_review: nil,
        user: UserModel.empty
    )
}

extension ReviewDto {
    var model: ReviewModel {
        ReviewModel(
            id: id,
            created: created,
            rating: rating,
            text: text,
            photo_review: photo_review?.model,
            user: user.model
        )
    }
}

extension ReviewModel {
    var photoReview: PhotoReviewModel? { photo_review }
}
