//


import Foundation

enum RedditAPIURLBuilder {

    /// Builds URL for fetching top posts of a subreddit (sorted by day)
    static func topPosts(
        subreddit: String,
        limit: Int,
        after paginationToken: String? = nil
    ) -> URL {

        var components = URLComponents(
            string: "https://www.reddit.com/r/\(subreddit)/top.json"
        )!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "t", value: "day")
        ]

        if let token = paginationToken {
            queryItems.append(
                URLQueryItem(name: "after", value: token)
            )
        }

        components.queryItems = queryItems
        return components.url!
    }

    /// Builds URL for searching posts inside a subreddit
    static func searchPosts(
        subreddit: String,
        query searchText: String,
        limit: Int,
        after paginationToken: String? = nil
    ) -> URL {

        var components = URLComponents(
            string: "https://www.reddit.com/r/\(subreddit)/search.json"
        )!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "q", value: searchText),
            URLQueryItem(name: "restrict_sr", value: "1"),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        if let token = paginationToken {
            queryItems.append(
                URLQueryItem(name: "after", value: token)
            )
        }

        components.queryItems = queryItems
        return components.url!
    }
}

