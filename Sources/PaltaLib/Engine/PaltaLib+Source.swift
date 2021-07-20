import Foundation

extension PaltaLib {

    public struct Source {

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

extension PaltaLib.Source: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}
