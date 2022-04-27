import Foundation

struct RemoteConfig: Codable, Equatable {
    let targets: [ConfigTarget]
}

struct ConfigTarget: Codable, Equatable {
    enum Name: String, Codable {
        case amplitude
        case paltabrain
        case `default`
    }
    
    static let defaultTarget = ConfigTarget(
        name: .default,
        settings: ConfigSettings(
            eventUploadThreshold: 12,
            eventUploadMaxBatchSize: 12,
            eventMaxCount: 12,
            eventUploadPeriodSeconds: 12,
            minTimeBetweenSessionsMillis: 12,
            trackingSessionEvents: true,
            realtimeEventTypes: [],
            excludedEventTypes: []
        ),
        url: URL(string: "https://api.paltabrain.com/events")
    )

    let name: Name
    let settings: ConfigSettings
    let url: URL?
}

struct ConfigSettings: Codable, Equatable {
    let eventUploadThreshold: Int
    let eventUploadMaxBatchSize: Int
    let eventMaxCount: Int
    let eventUploadPeriodSeconds: Int
    let minTimeBetweenSessionsMillis: Int
    let trackingSessionEvents: Bool
    let realtimeEventTypes: Set<String>
    let excludedEventTypes: Set<String>
}
