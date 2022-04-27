import Foundation

struct RemoteConfig: Codable, Equatable {
    let targets: [ConfigTarget]
}

public struct ConfigTarget: Codable, Equatable {
    public enum Name: String, Codable {
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
    
    public init(
        name: Name,
        settings: ConfigSettings,
        url: URL?
    ) {
        self.name = name
        self.settings = settings
        self.url = url
    }
}

public struct ConfigSettings: Codable, Equatable {
    let eventUploadThreshold: Int
    let eventUploadMaxBatchSize: Int
    let eventMaxCount: Int
    let eventUploadPeriodSeconds: Int
    let minTimeBetweenSessionsMillis: Int
    let trackingSessionEvents: Bool
    let realtimeEventTypes: Set<String>
    let excludedEventTypes: Set<String>
    
    public init(
        eventUploadThreshold: Int,
        eventUploadMaxBatchSize: Int,
        eventMaxCount: Int,
        eventUploadPeriodSeconds: Int,
        minTimeBetweenSessionsMillis: Int,
        trackingSessionEvents: Bool,
        realtimeEventTypes: Set<String>,
        excludedEventTypes: Set<String>
    ) {
        self.eventUploadThreshold = eventUploadThreshold
        self.eventUploadMaxBatchSize = eventUploadMaxBatchSize
        self.eventMaxCount = eventMaxCount
        self.eventUploadPeriodSeconds = eventUploadPeriodSeconds
        self.minTimeBetweenSessionsMillis = minTimeBetweenSessionsMillis
        self.trackingSessionEvents = trackingSessionEvents
        self.realtimeEventTypes = realtimeEventTypes
        self.excludedEventTypes = excludedEventTypes
    }
}
