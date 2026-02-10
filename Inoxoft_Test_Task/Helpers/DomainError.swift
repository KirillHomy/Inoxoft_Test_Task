//


import Foundation

enum DomainError: LocalizedError {
    case invalidSubreddit
    case invalidQuery

    var errorDescription: String? {
        switch self {
        case .invalidSubreddit: return "Subreddit is empty"
        case .invalidQuery: return "Query is empty"
        }
    }
}
