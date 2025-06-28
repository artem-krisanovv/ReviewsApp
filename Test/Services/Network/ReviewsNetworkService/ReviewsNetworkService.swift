import UIKit

protocol ReviewsNetworkServiceProtocol {
    func fetchReviews() async throws -> ReviewsDto
}

final class ReviewsNetworkService: ReviewsNetworkServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchReviews() async throws -> ReviewsDto {
        let response: ReviewsDto = try await networkService.request(Network.endPoint)
        return response
    }
}

