extension PaltaLib {

    public struct ConfigurationOptions {

        let appAmplitudeAPIKey: String
        let paltabrainAmplitudeAPIKey: String
        let additionalTargets: [Target]

        var allTargets: [Target] {
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
            ] + additionalTargets
        }

        public init(appAmplitudeAPIKey: String,
                    paltabrainAmplitudeAPIKey: String,
                    additionalTargets: [Target] = []) {
            self.appAmplitudeAPIKey = appAmplitudeAPIKey
            self.paltabrainAmplitudeAPIKey = paltabrainAmplitudeAPIKey
            self.additionalTargets = additionalTargets
        }
    }
}
