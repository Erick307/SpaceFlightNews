import Foundation

struct Article: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String?
    let newsSite: String
    let summary: String
    let publishedAt: Date
    let updatedAt: Date
    let featured: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, url, summary, featured
        case imageUrl    = "image_url"
        case newsSite    = "news_site"
        case publishedAt = "published_at"
        case updatedAt   = "updated_at"
    }
}
