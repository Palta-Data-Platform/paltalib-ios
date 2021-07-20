extension PaltaLib {

    public struct ConfigurationOptions {

        let appAmplitudeAPIKey: String
        let paltabrainAmplitudeAPIKey: String
        let additionalSources: [Source]

        var allSources: [Source] {
            [
                .init(
                    name: Settings.appAmplitudeInstanceName,
                    apiKey: appAmplitudeAPIKey
                ),
                .init(
                    name: Settings.paltabrainAmplitudeInstanceName,
                    apiKey: paltabrainAmplitudeAPIKey,
                    serverURL: Settings.paltabrainEventsURL
                )
            ] + additionalSources
        }

        public init(appAmplitudeAPIKey: String,
                    paltabrainAmplitudeAPIKey: String,
                    additionalSources: [Source] = []) {
            self.appAmplitudeAPIKey = appAmplitudeAPIKey
            self.paltabrainAmplitudeAPIKey = paltabrainAmplitudeAPIKey
            self.additionalSources = additionalSources
        }
    }
}
