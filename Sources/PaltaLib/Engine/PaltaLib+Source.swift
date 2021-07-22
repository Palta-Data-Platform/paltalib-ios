import Foundation

extension PaltaLib {

    public struct Target {

        let name: String
        let apiKey: String
        let serverURL: URL?

        public init(name: String,
                    apiKey: String,
                    serverURL: URL? = nil) {
            self.name = name
            self.apiKey = apiKey
            self.serverURL = serverURL
        }
    }
}

// MARK: - Equatable

extension PaltaLib.Target: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}
