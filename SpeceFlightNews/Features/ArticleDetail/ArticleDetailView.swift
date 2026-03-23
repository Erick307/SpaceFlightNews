import SwiftUI

@MainActor
struct ArticleDetailView: View {

    @StateObject private var viewModel: ArticleDetailViewModel
    @Environment(\.openURL) private var openURL

    init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                contentBlock
            }
        }
        .navigationTitle(state.article.newsSite)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .refreshable {
            viewModel.dispatch(intent: .refresh)
        }
        .overlay(alignment: .top) {
            if let errorMsg = state.refreshErrorMessage {
                refreshErrorBanner(message: errorMsg)
            }
        }
        .animation(.easeInOut, value: state.refreshErrorMessage)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let urlString = state.article.imageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 260)
                        .clipped()
                case .failure:
                    Color(.systemGray5)
                        .frame(height: 200)
                        .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.secondary))
                case .empty:
                    Color(.systemGray6)
                        .frame(height: 200)
                        .overlay(ProgressView())
                @unknown default:
                    EmptyView()
                }
            }
        }
    }

    private var contentBlock: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(state.article.title)
                .font(.title2)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Label(state.article.newsSite, systemImage: "newspaper.fill")
                    .foregroundColor(.accentColor)
                Spacer()
                Text(state.article.publishedAt.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)

            if state.article.featured {
                Label("Featured", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Divider()

            Text(state.article.summary)
                .font(.body)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            if let url = URL(string: state.article.url) {
                Button {
                    viewModel.dispatch(intent: .openInBrowser)
                    openURL(url)
                } label: {
                    Label("Read Full Article", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 8)
            }
        }
        .padding(16)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if let url = URL(string: state.article.url) {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                }
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.dispatch(intent: .share)
                })
            }
        }
    }

    private func refreshErrorBanner(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.red.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var state: ArticleDetailState { viewModel.state }
}

#Preview {
    NavigationStack {
        ArticleDetailView(viewModel: ArticleDetailViewModel(article: .mock))
    }
}
