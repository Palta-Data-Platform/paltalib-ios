import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
}

public protocol HTTPRequest {
    func urlRequest(headerFields: [String: String]) -> URLRequest?
}

public protocol AutobuildingHTTPRequest: HTTPRequest {
    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String? { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Data? { get }
    var cachePolicy: URLRequest.CachePolicy? { get }
    var timeout: TimeInterval? { get }
}

public protocol CodableAutobuildingHTTPRequest: AutobuildingHTTPRequest {
    var bodyObject: AnyEncodable? { get }
}

public extension AutobuildingHTTPRequest {
    var headers: [String : String]? {
        nil
    }

    var queryParameters: [String : String]? {
        nil
    }

    var body: Data? {
        nil
    }

    var cachePolicy: URLRequest.CachePolicy? {
        nil
    }

    var timeout: TimeInterval? {
        nil
    }
    
    func urlRequest(headerFields: [String: String]) -> URLRequest? {
        guard var components = URLComponents(string: baseURL.absoluteString) else {
            return nil
        }

        if let path = path {
            components.path = path
        }

        let queryItems = queryParameters?.map { URLQueryItem(name: $0.0, value: $0.1) }
        components.queryItems = queryItems

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let body = body {
            request.httpBody = body
        }

        if let timeout = timeout {
            request.timeoutInterval = timeout
        }

        if let cachePolicy = cachePolicy {
            request.cachePolicy = cachePolicy
        }

        headerFields.forEach { request.setValue($0.1, forHTTPHeaderField: $0.0) }
        headers?.forEach { request.setValue($0.1, forHTTPHeaderField: $0.0) }

        return request
    }
}

public extension AutobuildingHTTPRequest where Self: CodableAutobuildingHTTPRequest {
    var body: Data? {
        bodyObject.flatMap { try? JSONEncoder().encode($0) }
    }
}
