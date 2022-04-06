import Foundation
import PaltaLibCore

final class ConfigurationService {
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func requestConfigs(apiKey: String, completion: @escaping (Result<RemoteConfig, Error>) -> Void) {
        httpClient.perform(AnalyticsHTTPRequest.remoteConfig(apiKey), with: completion)
    }
}
