import Amplitude

public final class PaltaLib {

    public static var instance: PaltaLib {
        .init()
    }

    public static func configure(appAPIKey: String,
                                 paltabrainAPIKey: String) {
        configure(using: .init(appAmplitudeAPIKey: appAPIKey,
                               paltabrainAmplitudeAPIKey: paltabrainAPIKey))
    }

    public static func configure(using configurationOptions: ConfigurationOptions) {
        let sources = configurationOptions.allSources
        sources.forEach(addSource)
        instance.sources = sources
    }

    public static func addSource(_ source: Source) {
        guard !instance.sources.contains(source) else { return }

        let amplitudeInstance = Amplitude.instance(withName: source.name)
        amplitudeInstance.initializeApiKey(source.apiKey)

        if let serverURL = source.serverURL {
            amplitudeInstance.setServerUrl(serverURL.absoluteString)
        }

        instance.amplitureInstances.append(amplitudeInstance)
    }

    var sources = [Source]()
    var amplitureInstances = [Amplitude]()
}
