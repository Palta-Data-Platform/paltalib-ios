import Foundation

public protocol HTTPClient {
    func perform<T: Decodable>(
        _ request: HTTPRequest,
        with completion: @escaping (Result<T, Error>) -> Void
    )
}

public final class HTTPClientImpl: HTTPClient {
    private let urlSession: URLSession

    public init(
        urlSession: URLSession = .init(configuration: URLSessionConfiguration.default)
    ) {
        self.urlSession = urlSession
    }

    public func perform<T: Decodable>(
        _ request: HTTPRequest,
        with completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let urlRequest = request.urlRequest(headerFields: [:]) else {
            completion(.failure(NSError.badRequest))
            return
        }

        let completion: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
            let code = (response as? HTTPURLResponse)?.statusCode
            if let statusCode = code, (statusCode < 200 || statusCode > 299) {
                let error = NSError(domain: URLError.errorDomain, code: statusCode, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }

            let result: Result<T, Error> = HTTPClientImpl.processResponse(data, of: request)
            completion(result)
        }

        let task = urlSession.dataTask(
            with: urlRequest,
            completionHandler: completion
        )

        task.resume()
    }

    private static func processResponse<T: Decodable>(_ data: Data?, of request: HTTPRequest) -> Result<T, Error> {
        guard let data = data else {
            return .failure(NSError.badResponseError)
        }

        do {
            let responseObject = try JSONDecoder().decode(T.self, from: data)
            return .success(responseObject)
        } catch {
            return .failure(error)
        }
    }
}

extension NSError {
    public static let badRequest = URLError(code: NSURLErrorBadURL)
    public static let badResponseError = URLError(code: NSURLErrorBadServerResponse)

    static func parseError(_ data: String) -> NSError {
        return URLError(code: NSURLErrorCannotParseResponse, userInfo:["data": data])
    }

    static func URLError(code: Int, userInfo: [String: Any]? = nil) -> NSError {
        return NSError(domain: NSURLErrorDomain, code: code, userInfo: userInfo)
    }
}
