import Foundation
import OSLog

final class NetworkClient: NetworkClientProtocol {

    static let shared = NetworkClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SpaceFlightNews",
                                category: "NetworkClient")

    init(session: URLSession = .shared) {
        self.session = session

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            for option: ISO8601DateFormatter.Options in [
                [.withInternetDateTime, .withFractionalSeconds],
                [.withInternetDateTime]
            ] {
                formatter.formatOptions = option
                if let date = formatter.date(from: raw) { return date }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(raw)"
            )
        }
        self.decoder = dec
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        logger.debug("→ GET \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(from: url)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }

            logger.debug("← \(http.statusCode) \(url.lastPathComponent)")

            guard (200...299).contains(http.statusCode) else {
                logger.warning("HTTP \(http.statusCode) for \(url.absoluteString)")
                throw NetworkError.serverError(statusCode: http.statusCode)
            }

            return try decoder.decode(T.self, from: data)

        } catch let e as NetworkError {
            throw e
        } catch let e as DecodingError {
            logger.error("Decoding error: \(e.localizedDescription)")
            throw NetworkError.decodingError(e)
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw NetworkError.unknown(error)
        }
    }
}
