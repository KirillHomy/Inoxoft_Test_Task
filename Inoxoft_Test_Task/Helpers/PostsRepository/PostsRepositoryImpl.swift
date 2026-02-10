//


import Foundation

final class PostsRepositoryImpl: PostsRepositoryProtocol {

    // MARK: - Dependencies
    private let apiClient: APIClientProtocol
    private let cache: PostsCacheRealmProtocol

    // MARK: - Constants
    private let firstPageCacheTTL: TimeInterval = 10 * 60 // 10 minutes

    init(api: APIClientProtocol, cache: PostsCacheRealmProtocol) {
        self.apiClient = api
        self.cache = cache
    }

    // MARK: - TOP (offline-first)

    func fetchTop(
        subreddit: String,
        limit: Int,
        after paginationToken: String?
    ) async throws -> (posts: [Post], after: String?, isFromCache: Bool) {

        let cacheKey = CacheKey.topPosts(subreddit: subreddit).value

        // 1) OFFLINE-FIRST for first page
        if isFirstPage(paginationToken),
           let cached = cache.loadFeed(
                key: cacheKey,
                maxAge: firstPageCacheTTL
           ) {
            print("CACHE HIT ✅")
            return (
                posts: cached.posts,
                after: cached.after,
                isFromCache: true
            )
        }

        // 2) Network
        let (posts, nextToken) = try await fetchTopFromNetwork(
            subreddit: subreddit,
            limit: limit,
            paginationToken: paginationToken
        )

        // 3) Cache save
        saveToCache(
            posts: posts,
            cacheKey: cacheKey,
            nextToken: nextToken,
            isFirstPage: isFirstPage(paginationToken)
        )

        return (
            posts: posts,
            after: nextToken,
            isFromCache: false
        )
    }

    // MARK: - SEARCH (network only)

    func search(
        subreddit: String,
        query: String,
        limit: Int,
        after paginationToken: String?
    ) async throws -> (posts: [Post], after: String?) {

        let url = RedditAPIURLBuilder.searchPosts(
            subreddit: subreddit,
            query: query,
            limit: limit,
            after: paginationToken
        )

        let dto: RedditListingDTO = try await apiClient.get(url)

        let posts = dto.data.children.map { $0.data.toDomain() }
        let nextToken = dto.data.after

        return (posts: posts, after: nextToken)
    }
}

// MARK: - Private helpers
private extension PostsRepositoryImpl {

    enum CacheKey {
        case topPosts(subreddit: String)

        var value: String {
            switch self {
            case .topPosts(let subreddit):
                return "top_\(subreddit)"
            }
        }
    }

    func isFirstPage(_ token: String?) -> Bool {
        token == nil
    }

    func fetchTopFromNetwork(
        subreddit: String,
        limit: Int,
        paginationToken: String?
    ) async throws -> (posts: [Post], nextToken: String?) {

        let url = RedditAPIURLBuilder.topPosts(
            subreddit: subreddit,
            limit: limit,
            after: paginationToken
        )

        let dto: RedditListingDTO = try await apiClient.get(url)

        let posts = dto.data.children.map { $0.data.toDomain() }
        let nextToken = dto.data.after

        print("SERVER after:", nextToken ?? "nil")

        return (posts, nextToken)
    }

    func saveToCache(
        posts: [Post],
        cacheKey: String,
        nextToken: String?,
        isFirstPage: Bool
    ) {
        if isFirstPage {
            cache.saveFeedPage(
                key: cacheKey,
                posts: posts,
                after: nextToken
            )
        } else {
            cache.appendFeedPage(
                key: cacheKey,
                posts: posts,
                after: nextToken
            )
        }
    }
}
