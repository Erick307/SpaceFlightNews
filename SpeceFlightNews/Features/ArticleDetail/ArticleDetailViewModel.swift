import Foundation
import OSLog
internal import Combine

@MainActor
final class ArticleDetailViewModel: ObservableObject {

    @Published private(set) var state: ArticleDetailState

    private let repository: ArticleRepositoryProtocol
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "SpaceFlightNews",
        category: "ArticleDetailViewModel"
    )

    init(
        article: Article,
        repository: ArticleRepositoryProtocol = ArticleRepository()
    ) {
        self.state = .initial(article: article)
        self.repository = repository
    }

    func dispatch(intent: ArticleDetailIntent) {
        switch intent {
        case .refresh: Task { await refresh() }
        case .openInBrowser: logger.info("User opened article \(self.state.article.id) in browser")
        case .share: logger.info("User shared article \(self.state.article.id)")
        }
    }

    private func refresh() async {
        guard !state.isRefreshing else { return }

        state = ArticleDetailState(
            article: state.article,
            isRefreshing: true,
            refreshErrorMessage: nil
        )

        do {
            let fresh = try await repository.fetchArticle(id: state.article.id)
            state = ArticleDetailState(article: fresh, isRefreshing: false, refreshErrorMessage: nil)
            logger.info("Refreshed article \(fresh.id)")
        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            logger.error("Refresh failed: \(msg)")
            // Keep the cached article visible; show a transient error message
            state = ArticleDetailState(
                article: state.article,
                isRefreshing: false,
                refreshErrorMessage: msg
            )
        }
    }
}
