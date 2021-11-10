import Foundation

extension PaltaLib {

    public struct Target {

        let name: String
        let apiKey: String
        let trackingSessionEvents: Bool
        let serverURL: URL?

        public init(name: String,
                    apiKey: String,
                    trackingSessionEvents: Bool,
                    serverURL: URL? = nil) {
            self.name = name
            self.apiKey = apiKey
            self.trackingSessionEvents = trackingSessionEvents
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
