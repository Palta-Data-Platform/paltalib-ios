import Amplitude
import PaltaLibCore

public final class PaltaAnalytics {
    public static let instance = PaltaAnalytics()

    var paltaQueues: [EventQueueImpl] {
        paltaQueueAssemblies.map { $0.eventQueue }
    }

    let assembly = AnalyticsAssembly()
    
    var paltaQueueAssemblies: [EventQueueAssembly] {
        if let defaultPaltaInstance = defaultPaltaInstance {
            return [defaultPaltaInstance]
        } else {
            return _paltaQueueAssemblies
        }
    }
    
    var amplitudeInstances: [Amplitude] {
        if let defaultAmplitudeInstance = defaultAmplitudeInstance {
            return [defaultAmplitudeInstance]
        } else {
            return _amplitudeInstances
        }
    }

    private(set) var targets = [Target]()
    
    private lazy var defaultAmplitudeInstance: Amplitude? = Amplitude
        .instance(withName: ConfigTarget.defaultAmplitude.name.rawValue)
        .do {
            $0.apply(.defaultAmplitude)
            $0.setOffline(true)
        }
    
    private lazy var defaultPaltaInstance: EventQueueAssembly? = assembly.newEventQueueAssembly()
    
    private var _paltaQueueAssemblies: [EventQueueAssembly] = []
    private var _amplitudeInstances: [Amplitude] = []

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
                applyRemoteConfig(.default)
            case .success(let config):
                applyRemoteConfig(config)
            }
        }
    }
    
    private func applyRemoteConfig(_ remoteConfig: RemoteConfig) {
        let service = ConfigApplyService(
            remoteConfig: remoteConfig,
            apiKey: apiKey,
            amplitudeApiKey: amplitudeApiKey,
            eventQueueAssemblyProvider: assembly
        )
        
        service.apply(
            defaultPaltaAssembly: &defaultPaltaInstance,
            defaultAmplitude: &defaultAmplitudeInstance,
            paltaAssemblies: &_paltaQueueAssemblies,
            amplitudeInstances: &_amplitudeInstances
        )
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
