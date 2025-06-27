struct PhotoReviewModel {
    let id: Int
    let photo_review: [String]
}

extension PhotoReviewDto {
    var model: PhotoReviewModel {
        PhotoReviewModel(
            id: id,
            photo_review: photo_review
        )
    }
}
