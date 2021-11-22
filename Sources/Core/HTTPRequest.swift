import Foundation

public struct HTTPRequest: Hashable {
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
    }

    var method: Method
    var path: String
    var parameters: [String: String]?
    var body: Data?

    public init(method: Method, path: String, parameters: [String: String]? = nil, body: Data? = nil) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.body = body
    }
}

extension HTTPRequest {
    func urlRequest(url: URL,
                    headerFields: [String: String] = [:]) -> URLRequest? {
        guard var components = URLComponents(string: url.absoluteString) else {
            return nil
        }

        components.path = path
        let queryItems = parameters?.map { URLQueryItem(name: $0.0, value: $0.1) }
        components.queryItems = queryItems

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "accept")
        headerFields.forEach { request.setValue($0.1, forHTTPHeaderField: $0.0) }
        body.flatMap { request.httpBody = $0 }

        return request
    }
}
