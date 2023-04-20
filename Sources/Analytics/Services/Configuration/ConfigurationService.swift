import Foundation
import PaltaCore

final class ConfigurationService {
    private lazy var cachedConfig: RemoteConfig? = userDefaults.object(for: "paltaBrainRemoteConfig") {
        didSet {
            userDefaults.set(cachedConfig, for: "paltaBrainRemoteConfig")
        }
    }

    private let userDefaults: UserDefaults
    private let httpClient: HTTPClient
    
    init(userDefaults: UserDefaults, httpClient: HTTPClient) {
        self.userDefaults = userDefaults
        self.httpClient = httpClient
    }
    
    func requestConfigs(apiKey: String, host: URL?, completion: @escaping (Result<RemoteConfig, Error>) -> Void) {
        httpClient.perform(AnalyticsHTTPRequest.remoteConfig(host, apiKey)) { [weak self] (result: Result<RemoteConfig, NetworkErrorWithoutResponse>) in
            switch (result, self?.cachedConfig) {
            case (.success(let remoteConfig), _):
                self?.cachedConfig = remoteConfig
                completion(.success(remoteConfig))

            case (.failure(let error), let cachedConfig?):
                print("Error fetching remote config: \(error)")
                completion(.success(cachedConfig))

            case (.failure(let error), nil):
                print("Error fetching remote config: \(error)")
                completion(.failure(error))
            }
        }
    }
}
