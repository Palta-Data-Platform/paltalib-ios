import Amplitude

public final class PaltaLib {

    public static var instance: PaltaLib {
        .init()
    }

    public static func configure(name: String,
                                 amplitudeAPIKey: String? = nil,
                                 paltaAPIKey: String? = nil) {
        configure(
            using:
                .init(
                    name: name,
                    amplitudeAPIKey: amplitudeAPIKey,
                    paltaAPIKey: paltaAPIKey
                )
        )
    }

    public static func configure(using configurationOptions: ConfigurationOptions) {
        let targets = configurationOptions.allTargets
        targets.forEach(addTarget)
        instance.targets = targets
    }

    public static func addTarget(_ target: Target) {
        guard !instance.targets.contains(target) else { return }

        let amplitudeInstance = Amplitude.instance(withName: target.name)
        amplitudeInstance.initializeApiKey(target.apiKey)

        if let serverURL = target.serverURL {
            amplitudeInstance.setServerUrl(serverURL.absoluteString)
        }

        instance.amplitureInstances.append(amplitudeInstance)
    }

    public func setUserId(_ userId: String) {
        amplitureInstances.forEach {
            $0.setUserId(userId)
        }
    }

    var targets = [Target]()
    var amplitureInstances = [Amplitude]()
}
