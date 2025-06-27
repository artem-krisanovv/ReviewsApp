enum NetworkServiceError: Error {
    case invalidParams
    case invalidURL
    case invalidResponse(String?)
    case unknown
}
