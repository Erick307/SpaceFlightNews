import Foundation

protocol NetworkClientProtocol {
    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
}
