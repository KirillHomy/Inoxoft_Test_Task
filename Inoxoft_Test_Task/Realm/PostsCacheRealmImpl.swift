//


import Foundation
import RealmSwift

final class PostsCacheRealmImpl: PostsCacheRealmProtocol {

    private let config: Realm.Configuration

    init(config: Realm.Configuration = .defaultConfiguration) {
        self.config = config
    }

    private func realm() throws -> Realm {
        try Realm(configuration: config)
    }

    // MARK: - Load

    func loadFeed(key: String, maxAge: TimeInterval) -> (posts: [Post], after: String?)? {
        guard let r = try? realm() else {
            print("Realm open failed")
            return nil
        }

        guard let page = r.object(ofType: FeedPageEntity.self, forPrimaryKey: key) else {
            print("NO FeedPageEntity for key:", key)
            return nil
        }

        let age = Date().timeIntervalSince(page.lastUpdatedAt)
        print("Cache age:", age)

        guard age <= maxAge else {
            print("Cache expired")
            return nil
        }

        let entries = r.objects(FeedEntryEntity.self)
            .where { $0.key == key }
            .sorted(byKeyPath: "order", ascending: true)

        print("Entries count:", entries.count)

        guard !entries.isEmpty else {
            print("Entries empty")
            return nil
        }

        var posts: [Post] = []

        for entry in entries {
            if let entity = r.object(ofType: PostEntity.self, forPrimaryKey: entry.postId) {
                posts.append(entity.toDomain())
            } else {
                print("Missing PostEntity for id:", entry.postId)
            }
        }

        print("Restored posts:", posts.count)

        guard !posts.isEmpty else {
            print("Posts empty after restore")
            return nil
        }

        print("CACHE HIT ✅")
        return (posts: posts, after: page.after)
    }

    // MARK: - Save first page

    func saveFeedPage(key: String, posts: [Post], after: String?) {
        guard let r = try? realm() else { return }

        try? r.write {

            // удаляем старые entries
            let oldEntries = r.objects(FeedEntryEntity.self).where { $0.key == key }
            r.delete(oldEntries)

            // upsert PostEntity
            for post in posts {
                let entity: PostEntity

                if let existing = r.object(ofType: PostEntity.self, forPrimaryKey: post.id) {
                    entity = existing
                } else {
                    let new = PostEntity()
                    new.id = post.id       // ✅ PK задаётся ОДИН раз
                    entity = new
                }

                post.apply(to: entity)     // ❗ apply НЕ трогает id
                r.add(entity, update: .modified)
            }

            // создаём entries
            for (index, post) in posts.enumerated() {
                let entry = FeedEntryEntity()
                entry.pk = "\(key)_\(post.id)"
                entry.key = key
                entry.postId = post.id
                entry.order = index
                r.add(entry, update: .modified)
            }

            // мета страницы
            let page = r.object(ofType: FeedPageEntity.self, forPrimaryKey: key)
                ?? FeedPageEntity()

            if page.realm == nil {
                page.key = key
            }

            page.after = after
            page.lastUpdatedAt = Date()
            r.add(page, update: .modified)
        }
    }

    // MARK: - Append next page

    func appendFeedPage(key: String, posts: [Post], after: String?) {
        guard let r = try? realm() else { return }

        try? r.write {

            let existingCount = r.objects(FeedEntryEntity.self)
                .where { $0.key == key }
                .count

            // upsert PostEntity
            for post in posts {
                let entity: PostEntity

                if let existing = r.object(ofType: PostEntity.self, forPrimaryKey: post.id) {
                    entity = existing
                } else {
                    let new = PostEntity()
                    new.id = post.id       // ✅ PK только при создании
                    entity = new
                }

                post.apply(to: entity)
                r.add(entity, update: .modified)
            }

            // append entries
            for (offset, post) in posts.enumerated() {
                let entry = FeedEntryEntity()
                entry.pk = "\(key)_\(post.id)"
                entry.key = key
                entry.postId = post.id
                entry.order = existingCount + offset
                r.add(entry, update: .modified)
            }

            // update page
            let page = r.object(ofType: FeedPageEntity.self, forPrimaryKey: key)
                ?? FeedPageEntity()

            if page.realm == nil {
                page.key = key
            }

            page.after = after
            page.lastUpdatedAt = Date()
            r.add(page, update: .modified)
        }
    }

    // MARK: - Clear

    func clearFeed(key: String) {
        guard let r = try? realm() else { return }

        try? r.write {
            let entries = r.objects(FeedEntryEntity.self).where { $0.key == key }
            r.delete(entries)

            if let page = r.object(ofType: FeedPageEntity.self, forPrimaryKey: key) {
                r.delete(page)
            }
        }
    }
}
