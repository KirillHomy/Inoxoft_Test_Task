//


import Foundation

struct Post: Hashable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let score: Int
    let comments: Int
    let createdUTC: Date
    let thumbnailURL: URL?
    let imageURL: URL?
    let permalink: URL?
}

extension Post {
    var bestImageURL: URL? {
        if let url = imageURL {
            return url
        }

        if let thumb = thumbnailURL,
           thumb.scheme == "http" || thumb.scheme == "https" {
            return thumb
        }

        return nil
    }
}

