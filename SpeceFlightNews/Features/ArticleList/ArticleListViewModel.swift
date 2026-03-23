import Foundation
import OSLog
internal import Combine

@MainActor
final class ArticleListViewModel: ObservableObject {

    @Published private(set) var state: ArticleListState

    private let repository: ArticleRepositoryProtocol
    private let searchDebounceMs: Int

    private var currentOffset = 0
    private let pageSize = 20

    private var searchTask: Task<Void, Never>?

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "SpaceFlightNews",
        category: "ArticleListViewModel"
    )

    init(
        state: ArticleListState = .initial,
        repository: ArticleRepositoryProtocol = ArticleRepository(),
        searchDebounceMs: Int = 500
    ) {
        self.state = state
        self.repository = repository
        self.searchDebounceMs = searchDebounceMs
    }

    func dispatch(intent: ArticleListIntent) {
        Task {
            switch intent {
            case .loadArticles: await loadArticles()
            case .search(let query): await handleSearch(query: query)
            case .clearSearch: await clearSearch()
            case .loadMore: await loadMoreArticles()
            }
        }
    }
    
    private func loadMoreArticles() async {
        guard !state.isLoadingMore, !state.isLoading, state.hasMore else { return }
        state = ArticleListState(
            articles: state.articles,
            searchQuery: state.searchQuery,
            isLoading: false,
            isLoadingMore: true,
            errorMessage: nil,
            hasMore: state.hasMore
        )
        
        do {
            let response = try await repository.fetchArticles(
                search: state.searchQuery.isEmpty ? nil : state.searchQuery,
                limit: pageSize,
                offset: currentOffset
            )

            let merged = state.articles + response.results
            currentOffset += response.results.count

            state = ArticleListState(
                articles: merged,
                searchQuery: state.searchQuery,
                isLoading: false,
                isLoadingMore: false,
                errorMessage: nil,
                hasMore: response.next != nil
            )
            logger.info("Loaded \(response.results.count) articles. Total: \(merged.count)")

        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            logger.error("Load failed: \(msg)")
            state = ArticleListState(
                articles: state.articles,
                searchQuery: state.searchQuery,
                isLoading: false,
                isLoadingMore: false,
                errorMessage: msg,
                hasMore: false
            )
        }
    }

    private func loadArticles() async {
        guard !state.isLoading else { return }
        
        state = ArticleListState(
            articles: [],
            searchQuery: state.searchQuery,
            isLoading: true,
            isLoadingMore: false,
            errorMessage: nil,
            hasMore: false
        )
        currentOffset = 0

        do {
            let response = try await repository.fetchArticles(
                search: state.searchQuery.isEmpty ? nil : state.searchQuery,
                limit: pageSize,
                offset: currentOffset
            )

            currentOffset = response.results.count

            state = ArticleListState(
                articles: response.results,
                searchQuery: state.searchQuery,
                isLoading: false,
                isLoadingMore: false,
                errorMessage: nil,
                hasMore: response.next != nil
            )
            logger.info("Loaded \(response.results.count) articles. Total: \(response.results.count)")

        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            logger.error("Load failed: \(msg)")
            state = ArticleListState(
                articles: [],
                searchQuery: state.searchQuery,
                isLoading: false,
                isLoadingMore: false,
                errorMessage: msg,
                hasMore: false
            )
        }
    }

    private func handleSearch(query: String) async {
        state = ArticleListState(
            articles: state.articles,
            searchQuery: query,
            isLoading: state.isLoading,
            isLoadingMore: false,
            errorMessage: nil,
            hasMore: state.hasMore
        )

        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            if searchDebounceMs > 0 {
                try? await Task.sleep(for: .milliseconds(searchDebounceMs))
            }
            guard !Task.isCancelled else { return }
            await loadArticles()
        }
    }

    private func clearSearch() async {
        searchTask?.cancel()
        currentOffset = 0
        state = ArticleListState(
            articles: [],
            searchQuery: "",
            isLoading: false,
            isLoadingMore: false,
            errorMessage: nil,
            hasMore: false
        )
        await loadArticles()
    }
}
