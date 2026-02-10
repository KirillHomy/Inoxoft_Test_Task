//


import Foundation

extension PostEntity {
    func toDomain() -> Post {
        Post(
            id: id,
            title: title,
            author: author,
            subreddit: subreddit,
            score: score,
            comments: comments,
            createdUTC: createdUTC,
            thumbnailURL: thumbnailURLString.flatMap(URL.init(string:)),
            imageURL: imageURLString.flatMap(URL.init(string:)),
            permalink: permalinkString.flatMap(URL.init(string:))
        )
    }
}

extension Post {
    func apply(to entity: PostEntity) {
        entity.title = title
        entity.author = author
        entity.subreddit = subreddit
        entity.score = score
        entity.comments = comments
        entity.createdUTC = createdUTC
        entity.thumbnailURLString = thumbnailURL?.absoluteString
        entity.imageURLString = imageURL?.absoluteString
        entity.permalinkString = permalink?.absoluteString
        entity.updatedAt = Date()
    }
}
