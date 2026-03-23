import Testing
import Foundation
@testable import SpeceFlightNews

@Suite("ArticleDetail ViewModel")
@MainActor
final class ArticleDetailViewModelTests {

    var sut: ArticleDetailViewModel
    var mockRepo: MockArticleRepository

    init() {
        mockRepo = MockArticleRepository()
        sut = ArticleDetailViewModel(article: .mock, repository: mockRepo)
    }

    @Test("Initial state contains the passed article")
    func initialState() {
        #expect(sut.state.article == .mock)
        #expect(!sut.state.isRefreshing)
        #expect(sut.state.refreshErrorMessage == nil)
    }

    @Test("refresh – success updates the article")
    func refresh_success_updatesArticle() async {
        let freshArticle = Article(
            id: Article.mock.id,
            title: "Updated Title From API",
            url: Article.mock.url,
            imageUrl: Article.mock.imageUrl,
            newsSite: Article.mock.newsSite,
            summary: "Freshly fetched summary.",
            publishedAt: Article.mock.publishedAt,
            updatedAt: Date(),
            featured: Article.mock.featured
        )
        mockRepo.fetchArticleResult = .success(freshArticle)

        await dispatch(.refresh)

        #expect(sut.state.article.title == "Updated Title From API")
        #expect(!sut.state.isRefreshing)
        #expect(sut.state.refreshErrorMessage == nil)
        #expect(mockRepo.lastFetchedArticleId == Article.mock.id)
    }

    @Test("refresh – failure keeps cached article and sets error")
    func refresh_failure_keepsCachedArticle() async {
        mockRepo.fetchArticleResult = .failure(NetworkError.serverError(statusCode: 500))

        await dispatch(.refresh)

        #expect(sut.state.article == .mock, "Cached article must survive a failed refresh")
        #expect(!sut.state.isRefreshing)
        #expect(sut.state.refreshErrorMessage != nil)
    }

    @Test("openInBrowser – does not change state")
    func openInBrowser_noStateChange() async {
        let before = sut.state
        await dispatch(.openInBrowser)
        #expect(sut.state == before)
    }

    @Test("share – does not change state")
    func share_noStateChange() async {
        let before = sut.state
        await dispatch(.share)
        #expect(sut.state == before)
    }

    // MARK: - Helper

    private func dispatch(_ intent: ArticleDetailIntent) async {
        sut.dispatch(intent: intent)
        try? await Task.sleep(for: .milliseconds(50))
    }
}
