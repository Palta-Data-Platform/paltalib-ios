import Foundation

public final class HTTPClient {
    private let baseURL: URL
    private let urlSession: URLSession

    public init(baseURL: URL,
         urlSession: URLSession = .init(configuration: URLSessionConfiguration.default)) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    public func perform<T: Decodable>(_ request: HTTPRequest,
                                      with completion: @escaping (Result<T, Error>) -> Void) {
        guard let urlRequest = request.urlRequest(url: baseURL) else {
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

            let result: Result<T, Error> = HTTPClient.processResponse(data, of: request)
            completion(result)
        }

        let task: URLSessionDataTask

        switch request.method {
        case .get:
            task = urlSession.dataTask(
                with: urlRequest,
                completionHandler: completion
            )
        case .put, .post, .patch:
            task = urlSession.uploadTask(
                with: urlRequest,
                from: request.body,
                completionHandler: completion
            )
        }

        task.resume()
    }

    private static func processResponse<T: Decodable>(_ data: Data?, of request: HTTPRequest) -> Result<T, Error> {
        guard let data = data else {
            return .failure(NSError.badResponseError)
        }

        guard let responseObject = try? JSONDecoder().decode(T.self, from: data) else {
            let error = NSError.parseError(String(data: data, encoding: .utf8) ?? "")
            return .failure(error)
        }

        return .success(responseObject)
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
