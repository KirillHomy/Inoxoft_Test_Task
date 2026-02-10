//


import Foundation
import RealmSwift

final class FeedEntryEntity: Object {
    @Persisted(primaryKey: true) var pk: String
    @Persisted var key: String = ""
    @Persisted var postId: String = ""
    @Persisted var order: Int = 0
    @Persisted var insertedAt: Date = Date()
}
