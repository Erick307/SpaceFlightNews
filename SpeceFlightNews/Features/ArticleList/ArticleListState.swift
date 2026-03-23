import Foundation

struct ArticleListState: Equatable {
    let articles: [Article]
    let searchQuery: String
    let isLoading: Bool
    let isLoadingMore: Bool
    let errorMessage: String?
    let hasMore: Bool

    static let initial = ArticleListState(
        articles: [],
        searchQuery: "",
        isLoading: false,
        isLoadingMore: false,
        errorMessage: nil,
        hasMore: false
    )

    var isEmpty: Bool { articles.isEmpty && !isLoading }
    var showEmptySearch: Bool { isEmpty && !searchQuery.isEmpty && errorMessage == nil }
    var showEmptyDefault: Bool { isEmpty && searchQuery.isEmpty && errorMessage == nil }
}
