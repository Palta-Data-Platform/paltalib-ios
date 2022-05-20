import Foundation

public typealias NetworkErrorWithoutResponse = NetworkErrorWithResponse<EmptyResponse>

public enum NetworkErrorWithResponse<ErrorResponse>: Error {
    case badRequest
    case invalidStatusCode(Int, ErrorResponse?)
    case other(Error)
    case noData
    case urlError(URLError)
    case decodingError(DecodingError?)
}

public enum NetworkError: Error {
    case badRequest
    case invalidStatusCode(Int)
    case other(Error)
    case noData
    case urlError(URLError)
    case decodingError(DecodingError?)

    public init<T>(_ otherError: NetworkErrorWithResponse<T>) {
        switch otherError {
        case .badRequest:
            self = .badRequest
        case .invalidStatusCode(let code, _):
            self = .invalidStatusCode(code)
        case .other(let error):
            self = .other(error)
        case .noData:
            self = .noData
        case .decodingError(let error):
            self = .decodingError(error)
        case .urlError(let error):
            self = .urlError(error)
        }
    }
}

public protocol HTTPClient {
    func perform<SuccessResponse: Decodable, ErrorResponse: Decodable>(
        _ request: HTTPRequest,
        with completion: @escaping (Result<SuccessResponse, NetworkErrorWithResponse<ErrorResponse>>) -> Void
    )
}

public final class HTTPClientImpl: HTTPClient {
    private let urlSession: URLSession

    public init(
        urlSession: URLSession = .init(configuration: URLSessionConfiguration.default)
    ) {
        self.urlSession = urlSession
    }

    public func perform<SuccessResponse: Decodable, ErrorResponse: Decodable>(
        _ request: HTTPRequest,
        with completion: @escaping (Result<SuccessResponse, NetworkErrorWithResponse<ErrorResponse>>) -> Void
    ) {
        guard let urlRequest = request.urlRequest(headerFields: [:]) else {
            completion(.failure(.badRequest))
            return
        }

        let completion: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
            let code = (response as? HTTPURLResponse)?.statusCode
            if let statusCode = code, (statusCode < 200 || statusCode > 299) {
                let errorResponse = data.flatMap { try? JSONDecoder().decode(ErrorResponse.self, from: $0) }
                completion(.failure(.invalidStatusCode(statusCode, errorResponse)))
                return
            }
            
            if let error = error as? URLError {
                completion(.failure(.urlError(error)))
                return
            } else if let error = error {
                completion(.failure(.other(error)))
                return
            }

            completion(
                HTTPClientImpl.processResponse(data, of: request)
            )
        }

        let task = urlSession.dataTask(
            with: urlRequest,
            completionHandler: completion
        )

        task.resume()
    }

    private static func processResponse<SuccessResponse: Decodable, ErrorResponse: Decodable>(
        _ data: Data?,
        of request: HTTPRequest
    ) -> Result<SuccessResponse, NetworkErrorWithResponse<ErrorResponse>> {
        guard let data = data else {
            return .failure(.noData)
        }

        do {
            let responseObject = try JSONDecoder.default.decode(SuccessResponse.self, from: data)
            return .success(responseObject)
        } catch {
            return .failure(.decodingError(error as? DecodingError))
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
