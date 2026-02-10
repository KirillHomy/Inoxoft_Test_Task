//


import Foundation

protocol FetchPostsUseCaseProtocol {
    func top(
        subreddit: String,
        after paginationToken: String?
    ) async throws -> (posts: [Post], after: String?, isFromCache: Bool)
    
    func search(subreddit: String, query: String, after: String?) async throws -> (posts: [Post], after: String?)
}

