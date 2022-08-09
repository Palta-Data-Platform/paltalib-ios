import Foundation

struct RemoteConfig: Codable, Equatable {
    let eventUploadThreshold: Int
    let eventUploadMaxBatchSize: Int
    let eventMaxCount: Int
    let eventUploadPeriod: Int
    let minTimeBetweenSessions: Int
}

extension RemoteConfig {
    static let `default` = RemoteConfig(
        eventUploadThreshold: 30,
        eventUploadMaxBatchSize: 100,
        eventMaxCount: 1000,
        eventUploadPeriod: 30,
        minTimeBetweenSessions: 300
    )
}
