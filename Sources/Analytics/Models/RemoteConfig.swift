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
    
    enum SendMechanism: String, Codable {
        case amplitude
        case paltaBrain = "paltabrain"
    }
    
    static let defaultAmplitude = ConfigTarget(
        name: .amplitude,
        sendMechanism: .amplitude,
        settings: ConfigSettings(
            eventUploadThreshold: 30,
            eventUploadMaxBatchSize: 100,
            eventMaxCount: 1000,
            eventUploadPeriodSeconds: 30,
            minTimeBetweenSessionsMillis: 300000,
            trackingSessionEvents: true,
            realtimeEventTypes: [],
            excludedEventTypes: []
        ),
        url: nil
    )
    
    static let defaultPaltaBrain = ConfigTarget(
        name: .paltabrain,
        sendMechanism: .paltaBrain,
        settings: ConfigSettings(
            eventUploadThreshold: 30,
            eventUploadMaxBatchSize: 100,
            eventMaxCount: 1000,
            eventUploadPeriodSeconds: 30,
            minTimeBetweenSessionsMillis: 300000,
            trackingSessionEvents: true,
            realtimeEventTypes: [],
            excludedEventTypes: []
        ),
        url: URL(string: "https://api.paltabrain.com/events-v2")
    )

    let name: Name
    let sendMechanism: SendMechanism
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

extension ConfigTarget {
    enum CodingKeys: String, CodingKey {
        case name
        case sendMechanism = "send_mechanism"
        case settings
        case url
    }
}
