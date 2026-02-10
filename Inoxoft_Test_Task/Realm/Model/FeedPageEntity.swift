//


import Foundation
import RealmSwift

final class FeedPageEntity: Object {
    @Persisted(primaryKey: true) var key: String
    @Persisted var after: String?
    @Persisted var lastUpdatedAt: Date = .distantPast
}
