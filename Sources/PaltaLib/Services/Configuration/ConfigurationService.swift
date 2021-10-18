import Foundation

final class ConfigurationService {
    
    private let networkService: NetworkServiceInterface
    
    init(networkService: NetworkServiceInterface) {
        self.networkService = networkService
    }
    
    public func requestConfigs(completion: @escaping (Result<Codable, Error> -> Void)) {
        guard let url = NetworkRouter.remoteConfigs.asUrl() else {
            return
        }
        networkService.makeRequest(url: ,
                                   body: nil,
                                   headers: nil,
                                   method: .GET,
                                   completion: completion)
    }
}
