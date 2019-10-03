import Foundation
import APIKit

protocol GitHubRequest: Request {}

extension GitHubRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
}

final class DecodableDataParser: DataParser {
    let contentType: String? = nil

    func parse(data: Data) throws -> Any {
        return data
    }
}

extension GitHubRequest where Response: Decodable {
    var dataParser: DataParser {
        return DecodableDataParser()
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct Repository: Decodable, Hashable {
    let id: Int64
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "full_name"
    }
}

struct SearchResponse<Item: Decodable>: Decodable {
    let items: [Item]
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}

final class GitHubAPI {
    struct SearchRepositoriesRequest: GitHubRequest {
        let query: String

        typealias Response = SearchResponse<Repository>

        let method: HTTPMethod = .get
        let path: String = "/search/repositories"

        var parameters: Any? {
            return [
                "q": query,
            ]
        }
    }
}
