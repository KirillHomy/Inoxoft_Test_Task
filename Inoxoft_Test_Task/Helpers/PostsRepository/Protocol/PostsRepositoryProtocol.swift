//


import Foundation

protocol PostsRepositoryProtocol {
    func fetchTop(
        subreddit: String,
        limit: Int,
        after: String?
    ) async throws -> (posts: [Post], after: String?, isFromCache: Bool)
    func search(
        subreddit: String,
        query: String,
        limit: Int,
        after: String?
    ) async throws -> (posts: [Post], after: String?)

}

