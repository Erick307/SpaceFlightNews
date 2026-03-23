import Testing
@testable import SpeceFlightNews

@Suite("ArticleList ViewModel")
@MainActor
final class ArticleListViewModelTests {

    var sut: ArticleListViewModel
    var mockRepo: MockArticleRepository

    init() {
        mockRepo = MockArticleRepository()
        sut = ArticleListViewModel(repository: mockRepo, searchDebounceMs: 0)
    }

    @Test("Initial state is idle and empty")
    func initialState() {
        #expect(sut.state == .initial)
        #expect(sut.state.articles.isEmpty)
        #expect(!sut.state.isLoading)
        #expect(sut.state.errorMessage == nil)
        #expect(!sut.state.hasMore)
    }

    @Test("loadArticles – success populates articles")
    func loadArticles_success() async {
        let articles = [Article.mock, Article.mock2]
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 2, next: nil, previous: nil, results: articles)
        )

        await dispatch(.loadArticles)

        #expect(sut.state.articles == articles)
        #expect(!sut.state.isLoading)
        #expect(!sut.state.hasMore)
        #expect(sut.state.errorMessage == nil)
    }

    @Test("loadArticles – failure sets error message")
    func loadArticles_failure() async {
        mockRepo.fetchArticlesResult = .failure(NetworkError.serverError(statusCode: 503))

        await dispatch(.loadArticles)

        #expect(sut.state.articles.isEmpty)
        #expect(!sut.state.isLoading)
        #expect(sut.state.errorMessage != nil)
    }

    @Test("loadArticles – sets hasMore when next page exists")
    func loadArticles_setsHasMore() async {
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 40, next: "https://api.example.com/?offset=20", previous: nil, results: [.mock])
        )

        await dispatch(.loadArticles)

        #expect(sut.state.hasMore)
    }

    @Test("loadArticles – does not duplicate calls when already loading")
    func loadArticles_noDuplicateCalls() async {
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 1, next: nil, previous: nil, results: [.mock])
        )

        await dispatch(.loadArticles)

        #expect(mockRepo.fetchArticlesCallCount == 1)
    }

    @Test("search – updates query and triggers API with correct term")
    func search_updatesQueryAndCallsAPI() async {
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 0, next: nil, previous: nil, results: [])
        )

        await dispatch(.search(query: "Mars"))

        #expect(sut.state.searchQuery == "Mars")
        #expect(mockRepo.lastSearch == "Mars")
    }

    @Test("search – resets previous results before loading")
    func search_resetsPreviousResults() async {
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 1, next: nil, previous: nil, results: [.mock])
        )
        await dispatch(.loadArticles)
        #expect(!sut.state.articles.isEmpty)

        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 0, next: nil, previous: nil, results: [])
        )
        await dispatch(.search(query: "xyz-no-results"))

        #expect(sut.state.articles.isEmpty)
    }

    @Test("clearSearch – resets query and reloads without search term")
    func clearSearch_resetsQueryAndReloads() async {
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 1, next: nil, previous: nil, results: [.mock])
        )

        await dispatch(.search(query: "Moon"))
        await dispatch(.clearSearch)

        #expect(sut.state.searchQuery == "")
        // clearSearch passes nil to the repository (empty query → nil)
        #expect(mockRepo.lastSearch == nil)
    }

    @Test("loadMore – appends next page to existing articles")
    func loadMore_appendsArticles() async {
        // Page 1
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 2, next: "next_url", previous: nil, results: [.mock])
        )
        await dispatch(.loadArticles)
        #expect(sut.state.articles.count == 1)

        // Page 2
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 2, next: nil, previous: "prev_url", results: [.mock2])
        )
        await dispatch(.loadMore)

        #expect(sut.state.articles.count == 2)
        #expect(!sut.state.hasMore)
    }

    @Test("loadMore – is a no-op when hasMore is false")
    func loadMore_noOp_whenNoMorePages() async {
        mockRepo.fetchArticlesResult = .success(
            ArticlesResponse(count: 1, next: nil, previous: nil, results: [.mock])
        )
        await dispatch(.loadArticles)

        let callCountBefore = mockRepo.fetchArticlesCallCount
        await dispatch(.loadMore)

        #expect(mockRepo.fetchArticlesCallCount == callCountBefore)
    }

    // MARK: - Helper
    private func dispatch(_ intent: ArticleListIntent) async {
        sut.dispatch(intent: intent)
        try? await Task.sleep(for: .milliseconds(50))
    }
}
