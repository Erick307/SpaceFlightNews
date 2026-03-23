import Foundation
import OSLog

/// https://api.spaceflightnewsapi.net/v4/docs/
final class ArticleRepository: ArticleRepositoryProtocol {

    private let networkClient: NetworkClientProtocol
    private let baseURL = "https://api.spaceflightnewsapi.net/v4"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SpaceFlightNews",
                                category: "ArticleRepository")

    init(networkClient: NetworkClientProtocol = NetworkClient.shared) {
        self.networkClient = networkClient
    }

    func fetchArticles(search: String? = nil, limit: Int = 20, offset: Int = 0) async throws -> ArticlesResponse {
        var components = URLComponents(string: "\(baseURL)/articles/")!
        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit",  value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        if let q = search, !q.isEmpty {
            items.append(URLQueryItem(name: "search", value: q))
        }
        components.queryItems = items

        guard let url = components.url else { throw NetworkError.invalidURL }

        logger.info("fetchArticles – search: \(search ?? "-"), limit: \(limit), offset: \(offset)")
        return try await networkClient.fetch(ArticlesResponse.self, from: url)
    }

    func fetchArticle(id: Int) async throws -> Article {
        guard let url = URL(string: "\(baseURL)/articles/\(id)/") else {
            throw NetworkError.invalidURL
        }
        logger.info("fetchArticle – id: \(id)")
        return try await networkClient.fetch(Article.self, from: url)
    }
}
