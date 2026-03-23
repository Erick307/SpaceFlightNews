import SwiftUI

@MainActor
struct ArticleListView: View {

    @StateObject var viewModel: ArticleListViewModel

    init(viewModel: ArticleListViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch true {
            case state.isLoading && state.articles.isEmpty:
                loadingView
            case state.errorMessage != nil && state.articles.isEmpty:
                ErrorView(message: state.errorMessage!) {
                    viewModel.dispatch(intent: .loadArticles)
                }
            case state.showEmptySearch:
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Results",
                    message: "No articles found for \(state.searchQuery)."
                )
            case state.showEmptyDefault:
                EmptyStateView(
                    icon: "newspaper",
                    title: "No Articles",
                    message: "Pull down to refresh."
                )
            default:
                articleList
            }
        }
        .navigationTitle("Space Flight News")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: searchBinding,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search articles…"
        )
        .task {
            if state == .initial {
                viewModel.dispatch(intent: .loadArticles)
            }
        }
        .refreshable {
            viewModel.dispatch(intent: .loadArticles)
        }
    }

    private var articleList: some View {
        List {
            ForEach(state.articles) { article in
                NavigationLink(value: article) {
                    ArticleRowView(article: article)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .onAppear {
                    if article.id == state.articles.last?.id {
                        viewModel.dispatch(intent: .loadMore)
                    }
                }
            }

            if state.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(
                viewModel: ArticleDetailViewModel(article: article)
            )
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading articles…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var state: ArticleListState { viewModel.state }

    private var searchBinding: Binding<String> {
        Binding(
            get: { state.searchQuery },
            set: { query in
                if query.isEmpty {
                    viewModel.dispatch(intent: .clearSearch)
                } else {
                    viewModel.dispatch(intent: .search(query: query))
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        ArticleListView(
            viewModel: ArticleListViewModel(
                state: ArticleListState(
                    articles: [.mock, .mock2],
                    searchQuery: "",
                    isLoading: false,
                    isLoadingMore: false,
                    errorMessage: nil,
                    hasMore: true
                )
            )
        )
    }
}
