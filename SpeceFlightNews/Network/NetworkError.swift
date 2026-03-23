import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case decodingError(Error)
    case serverError(statusCode: Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .decodingError(let error):
            return "Failed to process the server response: \(error.localizedDescription)"
        case .serverError(let code):
            return "The server returned an error (HTTP \(code))."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
