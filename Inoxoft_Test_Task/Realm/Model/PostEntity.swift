//


import Foundation
import RealmSwift

final class PostEntity: Object {

    @Persisted(primaryKey: true)
    var id: String = ""  

    @Persisted var title: String = ""
    @Persisted var author: String = ""
    @Persisted var subreddit: String = ""

    @Persisted var score: Int = 0
    @Persisted var comments: Int = 0
    @Persisted var createdUTC: Date = .distantPast

    @Persisted var thumbnailURLString: String?
    @Persisted var imageURLString: String?
    @Persisted var permalinkString: String?

    @Persisted var updatedAt: Date = Date()
}

