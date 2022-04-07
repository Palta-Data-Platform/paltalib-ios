import Amplitude
import PaltaLibCore

public final class PaltaAnalytics {

    var targets = [Target]()
    var amplitudeInstances = [Amplitude]()
    private let httpClient = HTTPClientImpl()
    private lazy var configurationService = ConfigurationService(httpClient: httpClient)
    private var apiKey: String?

    public init() {}

    public static let instance = PaltaAnalytics()

    public func configure(name: String,
                          amplitudeAPIKey: String? = nil,
                          paltaAPIKey: String? = nil,
                          trackingSessionEvents: Bool = false) {

        configure(
            using: .init(
                name: name,
                amplitudeAPIKey: amplitudeAPIKey,
                paltaAPIKey: paltaAPIKey,
                trackingSessionEvents: trackingSessionEvents
            )
        )
    }
    
    
    public func setApiKey(_ apiKey: String) {
        self.apiKey = apiKey
        requestRemoteConfigs()
    }
    
    private func requestRemoteConfigs() {
        guard let apiKey = apiKey else {
            print("PaltaAnalytics: error: API key is not set")
            return
        }
        configurationService.requestConfigs(apiKey: apiKey) { [self] result in
            switch result {
            case .failure(let error):
                print("PaltaAnalytics: configuration fetch failed: \(error.localizedDescription), used default config.")
                addConfigTarget(.defaultTarget)
            case .success(let config):
                config.targets.forEach { [self] in
                    addConfigTarget($0)
                }
            }
        }
    }

    public func configure(using configurationOptions: ConfigurationOptions) {
        let targets = configurationOptions.allTargets
        targets.forEach(addTarget)
        self.targets = targets
    }
    
    public func addConfigTarget(_ target: ConfigTarget) {
        guard let apiKey = apiKey else {
            print("PaltaAnalytics: error: API key is not set")
            return
        }
        let amplitudeInstance = Amplitude.instance(withName: target.name)
        let settings = target.settings
        amplitudeInstance.trackingSessionEvents = settings.trackingSessionEvents
        amplitudeInstance.eventMaxCount = Int32(settings.eventMaxCount)
        amplitudeInstance.eventUploadMaxBatchSize = Int32(settings.eventUploadMaxBatchSize)
        amplitudeInstance.eventUploadPeriodSeconds = Int32(settings.eventUploadPeriodSeconds)
        amplitudeInstance.eventUploadThreshold = Int32(settings.eventUploadThreshold)
        amplitudeInstance.minTimeBetweenSessionsMillis = settings.minTimeBetweenSessionsMillis
        amplitudeInstance.initializeApiKey(apiKey)
        if let url = target.url {
            amplitudeInstance.setServerUrl(url)
        }
        amplitudeInstances.append(amplitudeInstance)
    }

    public func addTarget(_ target: Target) {
        guard !targets.contains(target) else { return }

        let amplitudeInstance = Amplitude.instance(withName: target.name)
        amplitudeInstance.trackingSessionEvents = target.trackingSessionEvents
        amplitudeInstance.initializeApiKey(target.apiKey)

        if let serverURL = target.serverURL {
            amplitudeInstance.setServerUrl(serverURL.absoluteString)
        }
        amplitudeInstances.append(amplitudeInstance)
    }
    
    public func initializeApiKey(apiKey: String) {
        amplitudeInstances.forEach {
            $0.initializeApiKey(apiKey)
        }
    }
    
    public func initializeApiKey(apiKey: String, userId: String?) {
        amplitudeInstances.forEach {
            $0.initializeApiKey(apiKey, userId: userId)
        }
    }
        
    public func setOffline(_ offline: Bool) {
        amplitudeInstances.forEach {
            $0.setOffline(offline)
        }
    }
    
    public func useAdvertisingIdForDeviceId() {
        amplitudeInstances.forEach {
            $0.useAdvertisingIdForDeviceId()
        }
    }

    public func setTrackingOptions(_ options: AMPTrackingOptions) {
        amplitudeInstances.forEach {
            $0.setTrackingOptions(options)
        }
    }

    public func enableCoppaControl() {
        amplitudeInstances.forEach {
            $0.enableCoppaControl()
        }
    }
    
    public func disableCoppaControl() {
        amplitudeInstances.forEach {
            $0.disableCoppaControl()
        }
    }
    
    public func setServerUrl(_ serverUrl: String) {
        amplitudeInstances.forEach {
            $0.setServerUrl(serverUrl)
        }
    }

    public func setContentTypeHeader(_ contentType: String) {
        amplitudeInstances.forEach {
            $0.setContentTypeHeader(contentType)
        }
    }
    
    public func setBearerToken(_ token: String) {
        amplitudeInstances.forEach {
            $0.setBearerToken(token)
        }
    }
    
    public func setPlan(_ plan: AMPPlan) {
        amplitudeInstances.forEach {
            $0.setPlan(plan)
        }
    }

    public func setServerZone(_ serverZone: AMPServerZone) {
        amplitudeInstances.forEach {
            $0.setServerZone(serverZone)
        }
    }
    
    public func setServerZone(_ serverZone: AMPServerZone, updateServerUrl: Bool) {
        amplitudeInstances.forEach {
            $0.setServerZone(serverZone,
                             updateServerUrl: updateServerUrl)
        }
    }
    
    public func printEventsCount() {
        amplitudeInstances.forEach {
            $0.printEventsCount()
        }
    }
    
    public func getDeviceId() -> String? {
        amplitudeInstances.first?.getDeviceId()
    }
    
    public func regenerateDeviceId() {
        let deviceId = UUID().uuidString.appending("R")
        amplitudeInstances.forEach {
            $0.setDeviceId(deviceId)
        }
    }
    
    public func getSessionId() -> Int64? {
        amplitudeInstances.first?.getSessionId()
    }
    
    public func setSessionId(_ timestamp: Int64) {
        amplitudeInstances.forEach {
            $0.setSessionId(timestamp)
        }
    }
    
    public func uploadEvents() {
        amplitudeInstances.forEach {
            $0.uploadEvents()
        }
    }

    public func startOrContinueSession(_ timestamp: Int64) {
        amplitudeInstances.forEach {
            $0.startOrContinueSession(timestamp)
        }
    }
    
    public func getContentTypeHeader() -> String? {
        amplitudeInstances.first?.getContentTypeHeader()
    }


}
