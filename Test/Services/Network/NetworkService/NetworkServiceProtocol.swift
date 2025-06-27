protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: String,
        host: String,
        httpMethod: HTTPMethod,
        params: [String: Any]
    ) async throws -> T
}

extension NetworkServiceProtocol {
    func request<T: Decodable>(_ endPoint: String) async throws -> T {
        try await request(
            endPoint,
            host: Network.host,
            httpMethod: .get,
            params: [:]
        )
    }
}
