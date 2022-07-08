import Foundation

struct RemoteConfig: Codable, Equatable {
    let eventUploadThreshold: Int
    let eventUploadMaxBatchSize: Int
    let eventMaxCount: Int
    let eventUploadPeriod: Int
    let minTimeBetweenSessions: Int
    let url: URL
}

extension RemoteConfig {
    static let `default` = RemoteConfig(
        eventUploadThreshold: 30,
        eventUploadMaxBatchSize: 100,
        eventMaxCount: 1000,
        eventUploadPeriod: 30,
        minTimeBetweenSessions: 300,
        url: URL(string: "https://api.paltabrain.com/batch-proto")!
    )
}
