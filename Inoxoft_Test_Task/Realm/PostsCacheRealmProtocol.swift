//


import Foundation

protocol PostsCacheRealmProtocol {
    func loadFeed(key: String, maxAge: TimeInterval) -> (posts: [Post], after: String?)?
    func saveFeedPage(key: String, posts: [Post], after: String?)
    func appendFeedPage(key: String, posts: [Post], after: String?)
    func clearFeed(key: String)
}
