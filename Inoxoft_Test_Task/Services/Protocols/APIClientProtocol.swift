//


import Foundation

protocol APIClientProtocol {
    func get<T: Decodable>(_ url: URL) async throws -> T
}