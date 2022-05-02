import Amplitude
import PaltaLibCore

public final class PaltaAnalytics {
    public static let instance = PaltaAnalytics()

    var paltaQueues: [EventQueueImpl] {
        paltaQueueAssemblies.map { $0.eventQueue }
    }

    let assembly = AnalyticsAssembly()

    private(set) var targets = [Target]()
    private(set) var amplitudeInstances = [Amplitude]()

    private(set) var paltaQueueAssemblies: [EventQueueAssembly] = []

    private var apiKey: String?
    private var amplitudeApiKey: String?

    @available(
        *,
         deprecated,
         message: "Set trackingSessionEvents locally is ignored. Use func configure(name:amplitudeAPIKey:paltaAPIKey:) instead"
    )
    public func configure(
        name: String,
        amplitudeAPIKey: String? = nil,
        paltaAPIKey: String? = nil,
        trackingSessionEvents: Bool
    ) {
        configure(name: name, amplitudeAPIKey: amplitudeAPIKey, paltaAPIKey: paltaAPIKey)
    }

    public func configure(
        name: String,
        amplitudeAPIKey: String? = nil,
        paltaAPIKey: String? = nil
    ) {
        self.apiKey = paltaAPIKey
        self.amplitudeApiKey = amplitudeAPIKey

        assembly.analyticsCoreAssembly.userPropertiesKeeper.generateDeviceId()
        requestRemoteConfigs()
    }
    
    private func requestRemoteConfigs() {
        guard let apiKey = apiKey else {
            print("PaltaAnalytics: error: API key is not set")
            return
        }

        assembly.analyticsCoreAssembly.configurationService.requestConfigs(apiKey: apiKey) { [self] (result: Result<RemoteConfig, Error>) in
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
    
    private func addConfigTarget(_ target: ConfigTarget) {
        switch target.name {
        case .amplitude:
            addAmplitudeTarget(target)
        case .`default`, .paltabrain:
            addPaltaBrainTarget(target)
        }
    }

    private func addAmplitudeTarget(_ target: ConfigTarget) {
        guard let apiKey = amplitudeApiKey else {
            print("PaltaAnalytics: error: API key for amplitude is not set")
            return
        }

        let amplitudeInstance = Amplitude.instance(withName: target.name.rawValue)
        let settings = target.settings
        amplitudeInstance.trackingSessionEvents = settings.trackingSessionEvents
        amplitudeInstance.eventMaxCount = Int32(settings.eventMaxCount)
        amplitudeInstance.eventUploadMaxBatchSize = Int32(settings.eventUploadMaxBatchSize)
        amplitudeInstance.eventUploadPeriodSeconds = Int32(settings.eventUploadPeriodSeconds)
        amplitudeInstance.eventUploadThreshold = Int32(settings.eventUploadThreshold)
        amplitudeInstance.minTimeBetweenSessionsMillis = settings.minTimeBetweenSessionsMillis
        amplitudeInstance.excludedEvents = settings.excludedEventTypes
        amplitudeInstance.initializeApiKey(apiKey)

        if let url = target.url {
            amplitudeInstance.setServerUrl(url.absoluteString)
        }

        amplitudeInstances.append(amplitudeInstance)
    }

    private func addPaltaBrainTarget(_ target: ConfigTarget) {
        let eventQueueAssembly = assembly.newEventQueueAssembly()

        eventQueueAssembly.eventQueueCore.config = .init(
            maxBatchSize: target.settings.eventUploadMaxBatchSize,
            uploadInterval: TimeInterval(target.settings.eventUploadPeriodSeconds),
            uploadThreshold: target.settings.eventUploadThreshold,
            maxEvents: target.settings.eventMaxCount,
            maxConcurrentOperations: 5
        )

        eventQueueAssembly.liveEventQueueCore.config = .init(
            maxBatchSize: target.settings.eventUploadMaxBatchSize,
            uploadInterval: 0,
            uploadThreshold: 0,
            maxEvents: target.settings.eventMaxCount,
            maxConcurrentOperations: .max
        )

        eventQueueAssembly.eventQueue.liveEventTypes = target.settings.realtimeEventTypes
        eventQueueAssembly.eventQueue.excludedEvents = target.settings.excludedEventTypes

        eventQueueAssembly.eventSender.apiToken = apiKey

        assembly.analyticsCoreAssembly.sessionManager.maxSessionAge = target.settings.minTimeBetweenSessionsMillis
        paltaQueueAssemblies.append(eventQueueAssembly)
    }
        
    public func setOffline(_ offline: Bool) {
        amplitudeInstances.forEach {
            $0.setOffline(offline)
        }

        paltaQueueAssemblies.forEach {
            $0.eventQueueCore.isPaused = offline
            $0.liveEventQueueCore.isPaused = offline
        }
    }
    
    public func useAdvertisingIdForDeviceId() {
        amplitudeInstances.forEach {
            $0.useAdvertisingIdForDeviceId()
        }

        assembly.analyticsCoreAssembly.userPropertiesKeeper.useIDFAasDeviceId = true
    }

    public func setTrackingOptions(_ options: AMPTrackingOptions) {
        amplitudeInstances.forEach {
            $0.setTrackingOptions(options)
        }

        assembly.analyticsCoreAssembly.trackingOptionsProvider.setTrackingOptions(options)
    }

    public func enableCoppaControl() {
        amplitudeInstances.forEach {
            $0.enableCoppaControl()
        }

        assembly.analyticsCoreAssembly.trackingOptionsProvider.coppaControlEnabled = true
    }
    
    public func disableCoppaControl() {
        amplitudeInstances.forEach {
            $0.disableCoppaControl()
        }

        assembly.analyticsCoreAssembly.trackingOptionsProvider.coppaControlEnabled = false
    }
    
    public func getDeviceId() -> String? {
        assembly.analyticsCoreAssembly.userPropertiesKeeper.deviceId
    }
    
    public func regenerateDeviceId() {
        assembly.analyticsCoreAssembly.userPropertiesKeeper.generateDeviceId(forced: true)

        amplitudeInstances.forEach {
            $0.setDeviceId(assembly.analyticsCoreAssembly.userPropertiesKeeper.deviceId ?? "")
        }
    }
    
    public func getSessionId() -> Int64? {
        Int64(assembly.analyticsCoreAssembly.sessionManager.sessionId)
    }
    
    public func setSessionId(_ timestamp: Int64) {
        amplitudeInstances.forEach {
            $0.setSessionId(timestamp)
        }

        assembly.analyticsCoreAssembly.sessionManager.setSessionId(Int(timestamp))
    }
}
