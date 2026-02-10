//


import Foundation

struct RedditListingDTO: Decodable {
    let data: ListingDataDTO
}

struct ListingDataDTO: Decodable {
    let after: String?
    let children: [ChildDTO]
}

struct ChildDTO: Decodable {
    let data: PostDTO
}

struct PreviewSourceDTO: Decodable {
    let url: String
}

struct PostDTO: Decodable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let score: Int
    let num_comments: Int
    let created_utc: TimeInterval
    let thumbnail: String?
    let url_overridden_by_dest: String?
    let permalink: String?
    let post_hint: String?
    let preview: PreviewDTO?
}

struct PreviewDTO: Decodable {
    let images: [PreviewImageDTO]
}

struct PreviewImageDTO: Decodable {
    let source: PreviewSourceDTO
}

extension PostDTO {

    func toDomain() -> Post {

        let permalinkURL = permalink.flatMap {
            URL(string: "https://www.reddit.com\($0)")
        }

        // 1️⃣ ЛУЧШИЙ источник — preview (работает для gallery)
        let previewURL: URL? = {
            guard let raw = preview?.images.first?.source.url else { return nil }
            let decoded = raw.decodedHTMLString
            return URL(string: decoded)
        }()

        // 2️⃣ Прямая картинка (i.redd.it / preview.redd.it)
        let directImageURL: URL? = {
            guard let u = url_overridden_by_dest, u.hasPrefix("http") else { return nil }

            // ❌ HTML gallery — не картинка
            if u.contains("reddit.com/gallery/") { return nil }

            // ❌ Видео
            if u.contains("v.redd.it") { return nil }

            // ✅ Реальные изображения
            if u.contains("i.redd.it") || u.contains("preview.redd.it") {
                return URL(string: u)
            }

            return nil
        }()

        // 3️⃣ Thumbnail fallback
        let safeThumbURL: URL? = {
            guard let t = thumbnail, t.hasPrefix("http") else { return nil }
            return URL(string: t)
        }()

        return Post(
            id: id,
            title: title,
            author: author,
            subreddit: subreddit,
            score: score,
            comments: num_comments,
            createdUTC: Date(timeIntervalSince1970: created_utc),
            thumbnailURL: safeThumbURL,
            imageURL: previewURL ?? directImageURL,
            permalink: permalinkURL
        )
    }
}

extension String {
    var decodedHTMLString: String {
        replacingOccurrences(of: "&amp;", with: "&")
    }
}
