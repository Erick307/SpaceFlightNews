import Foundation
@testable import SpeceFlightNews

final actor MockArticleRepository: ArticleRepositoryProtocol {

    var fetchArticlesResult: Result<ArticlesResponse, Error> = .success(
        ArticlesResponse(count: 0, next: nil, previous: nil, results: [])
    )
    var fetchArticleResult: Result<Article, Error> = .success(.mock)

    private(set) var fetchArticlesCallCount = 0
    private(set) var lastSearch: String?
    private(set) var lastLimit: Int?
    private(set) var lastOffset: Int?

    private(set) var fetchArticleCallCount = 0
    private(set) var lastFetchedArticleId: Int?

    func fetchArticles(search: String?, limit: Int, offset: Int) async throws -> ArticlesResponse {
        fetchArticlesCallCount += 1
        lastSearch = search
        lastLimit  = limit
        lastOffset = offset
        return try fetchArticlesResult.get()
    }

    func fetchArticle(id: Int) async throws -> Article {
        fetchArticleCallCount += 1
        lastFetchedArticleId = id
        return try fetchArticleResult.get()
    }
}
