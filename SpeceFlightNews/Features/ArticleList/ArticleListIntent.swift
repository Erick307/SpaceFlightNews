enum ArticleListIntent {
    case loadArticles
    case search(query: String)
    case clearSearch
    case loadMore
}
