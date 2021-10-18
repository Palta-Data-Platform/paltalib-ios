import Foundation

protocol NetworkServiceInterface {
    func makeRequest<T: Codable>(url: URL,
                                 body: [String: Any]?,
                                 headers: [String: Any]?,
                                 method: HttpMehtod,
                                 completion: @escaping ((Result<T, Error>) -> Void))
}

final class NetworkService {
    public func makeRequest<T: Codable>(url: URL,
                                        body: [String: Any]?,
                                        headers: [String: Any]?,
                                        method: HttpMehtod,
                                        completion: @escaping ((Result<T, Error>) -> Void)) {
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        request.httpMethod = method.rawValue
        if let body = body {
            request.httpBody = getData(from: body)
        }
        URLSession().dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func getData(from dict: [String: Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
    }
}

enum HttpMehtod: String {
    case GET = "GET"
}
