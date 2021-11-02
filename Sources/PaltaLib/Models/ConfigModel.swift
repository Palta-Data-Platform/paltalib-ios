import Foundation

struct Config: Codable {
    let targets: [ConfigTarget]
}

struct ConfigTarget: Codable {
    
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
}

struct ConfigSettings: Codable {
    let eventUploadThreshold: Int
    let eventUploadMaxBatchSize: Int
    let eventMaxCount: Int
    let eventUploadPeriodSeconds: Int
    let minTimeBetweenSessionsMillis: Int
    let trackingSessionEvents: Bool
}
