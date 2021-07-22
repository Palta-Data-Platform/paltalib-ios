import Amplitude

public final class PaltaLib {

    public init() { }

    public static let instance: PaltaLib = {
        .init()
    }()

    public func configure(name: String,
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

    public func setUserId(_ userId: String) {
        amplitudeInstances.forEach {
            $0.setUserId(userId)
        }
    }

    public func identify(with values: [String: NSObject],
                         outOfSession: Bool = false) {
        let identify = AMPIdentify()
        values.forEach { key, value in
            identify.append(key, value: value)
        }

        amplitudeInstances.forEach {
            $0.identify(
                identify,
                outOfSession: outOfSession
            )
        }
    }

    public func groupIdentify(withGroupType: String,
                              groupName: NSObject,
                              with values: [String: NSObject],
                              outOfSession: Bool = false) {
        let identify = AMPIdentify()
        values.forEach { key, value in
            identify.append(key, value: value)
        }

        amplitudeInstances.forEach {
            $0.groupIdentify(
                withGroupType: withGroupType,
                groupName: groupName,
                groupIdentify: identify,
                outOfSession: outOfSession
            )
        }
    }

    var targets = [Target]()
    var amplitudeInstances = [Amplitude]()
}
