import Foundation

extension PaltaAnalytics2 {
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

extension PaltaAnalytics2.Target: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}
