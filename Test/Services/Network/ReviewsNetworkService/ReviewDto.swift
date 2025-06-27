struct ReviewsDto: Codable, Hashable {
    let count: Int
    let items: [ReviewDto]
}

struct ReviewDto: Codable, Hashable {
    let id: Int
    let text: String
    let rating: Int
    let created: String
    let user: UserDto
    let photo_review: PhotoReviewDto?
}

struct PhotoReviewDto: Codable, Hashable {
    let id: Int
    let photo_review: [String]
}

struct UserDto: Codable, Hashable {
    let id: Int
    let first_name: String
    let last_name: String
    let avatar_url: String
}
