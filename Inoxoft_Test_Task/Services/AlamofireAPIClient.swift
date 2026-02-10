//


import Foundation
import Alamofire

final class AlamofireAPIClient: APIClientProtocol {

    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        try await session
            .request(
                url,
                method: .get,
                headers: [
                    "Accept": "application/json"
                ]
            )
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
            .value
    }
}
