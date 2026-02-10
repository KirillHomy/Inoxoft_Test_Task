//


import Foundation

final class FetchPostsUseCaseImpl: FetchPostsUseCaseProtocol {

    private let repo: PostsRepositoryProtocol
    private let defaultLimit = 20

    init(repo: PostsRepositoryProtocol) {
        self.repo = repo
    }

    func top(
        subreddit: String,
        after paginationToken: String?
    ) async throws -> (posts: [Post], after: String?, isFromCache: Bool) {

        let sr = subreddit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sr.isEmpty else { throw DomainError.invalidSubreddit }

        return try await repo.fetchTop(
            subreddit: sr,
            limit: defaultLimit,
            after: paginationToken
        )
    }

    func search(
        subreddit: String,
        query: String,
        after paginationToken: String?
    ) async throws -> (posts: [Post], after: String?) {

        let sr = subreddit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sr.isEmpty else { throw DomainError.invalidSubreddit }

        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { throw DomainError.invalidQuery }

        // search обычно кэшировать не обязательно (по заданию чаще всего и не просят)
        return try await repo.search(
            subreddit: sr,
            query: q,
            limit: defaultLimit,
            after: paginationToken
        )
    }
}

