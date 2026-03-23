import Foundation

struct ArticlesResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Article]
}
