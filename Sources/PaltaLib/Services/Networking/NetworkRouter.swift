import Foundation

enum NetworkRouter: String {
    private static let baseUrl = "https://api.paltabrain.com/v1"
    
    case remoteConfigs = "/config?client=clientkey"
    
    public func asUrl() -> URL? {
        URL(string: NetworkRouter.baseUrl + self.rawValue)
    }
}
