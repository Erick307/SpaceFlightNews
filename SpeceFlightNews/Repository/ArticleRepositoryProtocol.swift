protocol ArticleRepositoryProtocol {
    func fetchArticles(search: String?, limit: Int, offset: Int) async throws -> ArticlesResponse
    func fetchArticle(id: Int) async throws -> Article
}
