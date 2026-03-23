import Foundation

struct ArticleDetailState: Equatable {
    let article: Article
    let isRefreshing: Bool
    let refreshErrorMessage: String?

    static func initial(article: Article) -> ArticleDetailState {
        ArticleDetailState(article: article, isRefreshing: false, refreshErrorMessage: nil)
    }
}
