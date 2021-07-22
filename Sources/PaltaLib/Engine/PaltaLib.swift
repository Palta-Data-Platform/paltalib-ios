import Amplitude

public final class PaltaLib {

    var targets = [Target]()
    var amplitudeInstances = [Amplitude]()

    public init() {}

    public static let instance = PaltaLib()

    public func configure(name: String,
                          amplitudeAPIKey: String? = nil,
                          paltaAPIKey: String? = nil) {

        configure(
            using: .init(
                name: name,
                amplitudeAPIKey: amplitudeAPIKey,
                paltaAPIKey: paltaAPIKey
            )
        )
    }

    public func configure(using configurationOptions: ConfigurationOptions) {
        let targets = configurationOptions.allTargets
        targets.forEach(addTarget)

        self.targets = targets
    }

    public func addTarget(_ target: Target) {
        guard !targets.contains(target) else { return }

        let amplitudeInstance = Amplitude.instance(withName: target.name)
        amplitudeInstance.initializeApiKey(target.apiKey)

        if let serverURL = target.serverURL {
            amplitudeInstance.setServerUrl(serverURL.absoluteString)
        }

        amplitudeInstances.append(amplitudeInstance)
    }
}
