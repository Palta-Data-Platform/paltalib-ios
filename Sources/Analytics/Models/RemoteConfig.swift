import Foundation

struct RemoteConfig: Codable, Equatable {
    static let `default` = RemoteConfig(
        targets: [.defaultAmplitude, .defaultPaltaBrain]
    )

    let targets: [ConfigTarget]
}

struct ConfigTarget: Codable, Equatable {
    enum Name: String, Codable {
        case amplitude
        case paltabrain
    }
    
    static let defaultAmplitude = ConfigTarget(
        name: .amplitude,
        settings: ConfigSettings(
            eventUploadThreshold: 30,
            eventUploadMaxBatchSize: 100,
            eventMaxCount: 1000,
            eventUploadPeriodSeconds: 30,
            minTimeBetweenSessionsMillis: 300000,
            trackingSessionEvents: true,
            realtimeEventTypes: [],
            excludedEventTypes: [],
            sendMechanism: .amplitude
        ),
        url: nil
    )
    
    static let defaultPaltaBrain = ConfigTarget(
        name: .paltabrain,
        settings: ConfigSettings(
            eventUploadThreshold: 30,
            eventUploadMaxBatchSize: 100,
            eventMaxCount: 1000,
            eventUploadPeriodSeconds: 30,
            minTimeBetweenSessionsMillis: 300000,
            trackingSessionEvents: true,
            realtimeEventTypes: [],
            excludedEventTypes: [],
            sendMechanism: .paltaBrain
        ),
        url: URL(string: "https://api.paltabrain.com/events-v2")
    )

    let name: Name
    let settings: ConfigSettings
    let url: URL?
}

struct ConfigSettings: Codable, Equatable {
    enum SendMechanism: String, Codable {
        case amplitude
        case paltaBrain = "paltabrain"
    }
    
    let eventUploadThreshold: Int
    let eventUploadMaxBatchSize: Int
    let eventMaxCount: Int
    let eventUploadPeriodSeconds: Int
    let minTimeBetweenSessionsMillis: Int
    let trackingSessionEvents: Bool
    let realtimeEventTypes: Set<String>
    let excludedEventTypes: Set<String>
    let sendMechanism: SendMechanism?
}

extension ConfigSettings {
    enum CodingKeys: String, CodingKey {
        case sendMechanism = "send_mechanism"
        case eventUploadThreshold
        case eventUploadMaxBatchSize
        case eventMaxCount
        case eventUploadPeriodSeconds
        case minTimeBetweenSessionsMillis
        case trackingSessionEvents
        case realtimeEventTypes
        case excludedEventTypes
    }
}
