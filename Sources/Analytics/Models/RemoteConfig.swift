import Foundation

struct RemoteConfig: Codable {
    let targets: [ConfigTarget]
}

public struct ConfigTarget: Codable {
    
    static let defaultTarget = ConfigTarget(name: "Default",
                                            settings: ConfigSettings(eventUploadThreshold: 12,
                                                                     eventUploadMaxBatchSize: 12,
                                                                     eventMaxCount: 12,
                                                                     eventUploadPeriodSeconds: 12,
                                                                     minTimeBetweenSessionsMillis: 12,
                                                                     trackingSessionEvents: true),
                                                                     url: "https://api.paltabrain.com/events")
    let name: String
    let settings: ConfigSettings
    let url: String?
    
    public init(name: String,
                settings: ConfigSettings,
                url: String?) {
        self.name = name
        self.settings = settings
        self.url = url
    }
}

public struct ConfigSettings: Codable {
    let eventUploadThreshold: Int
    let eventUploadMaxBatchSize: Int
    let eventMaxCount: Int
    let eventUploadPeriodSeconds: Int
    let minTimeBetweenSessionsMillis: Int
    let trackingSessionEvents: Bool
    
    public init(eventUploadThreshold: Int,
                eventUploadMaxBatchSize: Int,
                eventMaxCount: Int,
                eventUploadPeriodSeconds: Int,
                minTimeBetweenSessionsMillis: Int,
                trackingSessionEvents: Bool) {
        self.eventUploadThreshold = eventUploadThreshold
        self.eventUploadMaxBatchSize = eventUploadMaxBatchSize
        self.eventMaxCount = eventMaxCount
        self.eventUploadPeriodSeconds = eventUploadPeriodSeconds
        self.minTimeBetweenSessionsMillis = minTimeBetweenSessionsMillis
        self.trackingSessionEvents = trackingSessionEvents
    }
}
