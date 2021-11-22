import Foundation

final class ConfigurationService {
    
    private let networkService: NetworkServiceInterface
    
    init(networkService: NetworkServiceInterface) {
        self.networkService = networkService
    }
    
    public func requestConfigs(apiKey: String, completion: @escaping (Result<Config, Error>) -> Void) {
        guard let url = NetworkRouter.remoteConfigs.asUrl() else {
            return
        }
        networkService.makeRequest(url: url,
                                   body: nil,
                                   headers: ["X-API-Key": apiKey],
                                   method: .GET,
                                   completion: completion)
    }
}
