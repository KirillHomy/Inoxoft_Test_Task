//


import Foundation

final class PostsViewModel {

    struct State: Equatable {
        var items: [Post] = []
        var isLoading: Bool = false
        var errorText: String?
        var canLoadMore: Bool = true
    }

    private let fetchUseCase: FetchPostsUseCaseProtocol

    private(set) var state = State() {
        didSet { onStateChange?(state) }
    }
    var onStateChange: ((State) -> Void)?

    private var paginationToken: String?
    private let subreddit = "ios"
    private var inFlight = false
    private var currentQuery: String?

    init(fetchUseCase: FetchPostsUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
    }

    func loadInitial() {
        paginationToken = nil
        state.errorText = nil
        state.canLoadMore = true
        state.isLoading = true

        Task { await loadNextPage() }
    }
    
    func loadNextPage() async {

        // ❗ защита от повторной первой страницы
        if paginationToken == nil && !state.items.isEmpty && currentQuery == nil {
            return
        }

        guard !inFlight, state.canLoadMore else { return }

        inFlight = true
        state.isLoading = true

        let requestToken = paginationToken
        let isFirstPage = (requestToken == nil)

        defer {
            inFlight = false
            state.isLoading = false
        }

        do {
            let posts: [Post]
            let nextAfter: String?

            if let query = currentQuery {
                // 🔍 SEARCH
                let result = try await fetchUseCase.search(
                    subreddit: subreddit,
                    query: query,
                    after: requestToken
                )
                posts = result.posts
                nextAfter = result.after
            } else {
                // 🔥 TOP
                let result = try await fetchUseCase.top(
                    subreddit: subreddit,
                    after: requestToken
                )
                posts = result.posts
                nextAfter = result.after

                // canLoadMore только для top и только из сети
                if !result.isFromCache {
                    state.canLoadMore = posts.count >= 20
                }
            }

            if isFirstPage {
                state.items = posts
            } else {
                state.items += posts
            }

            paginationToken = nextAfter

            // для search — строго по after
            if currentQuery != nil {
                state.canLoadMore = nextAfter != nil
            }

        } catch {
            state.errorText = error.localizedDescription
        }
    }

    func refresh() {
        currentQuery = nil          // ⛔️ refresh всегда сбрасывает поиск
        paginationToken = nil
        state.canLoadMore = true
        state.errorText = nil

        Task { await loadNextPage() }
    }

}

// MARK: - Search
extension PostsViewModel {
    
    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= 2 else {
            resetSearch()
            return
        }

        currentQuery = trimmed
        paginationToken = nil
        state.items = []
        state.canLoadMore = true
        state.errorText = nil

        Task { await loadNextPage() }
    }

    func resetSearch() {
        currentQuery = nil
        paginationToken = nil

        state.items = []
        state.canLoadMore = true
        state.errorText = nil

        Task { await loadNextPage() }
    }


}
