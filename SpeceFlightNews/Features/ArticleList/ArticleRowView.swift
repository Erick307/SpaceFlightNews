import SwiftUI

struct ArticleRowView: View {

    let article: Article

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnailView
            metadataView
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(article.title)
    }

    private var thumbnailView: some View {
        AsyncImage(url: URL(string: article.imageUrl ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholderImage
            case .empty:
                ProgressView()
                    .frame(width: 80, height: 80)
            @unknown default:
                placeholderImage
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var placeholderImage: some View {
        Color(.systemGray5)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            )
    }

    private var metadataView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(article.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(3)
                .foregroundColor(.primary)

            Text(article.newsSite)
                .font(.caption)
                .foregroundColor(.accentColor)

            Spacer()

            Text(article.publishedAt.formatted(.relative(presentation: .named)))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ArticleRowView(article: .mock)
        .padding()
}
