extension PaltaLib {

    public struct ConfigurationOptions {

        let name: String
        let amplitudeAPIKey: String?
        let paltaAPIKey: String?
        let additionalTargets: [Target]

        private var amplitudeName: String {
            name + Settings.amplitudeSuffix
        }

        private var paltaName: String {
            name + Settings.paltaSuffix
        }

        var allTargets: [Target] {
            var targets = [Target]()

            if let amplitudeAPIKey = amplitudeAPIKey {
                targets.append(
                    .init(
                        name: amplitudeName,
                        apiKey: amplitudeAPIKey
                    )
                )
            }

            if let paltaAPIKey = paltaAPIKey {
                targets.append(
                    .init(
                        name: paltaName,
                        apiKey: paltaAPIKey,
                        serverURL: Settings.paltaServerURL
                    )
                )
            }

            targets += additionalTargets

            return targets
        }

        public init(name: String,
                    amplitudeAPIKey: String? = nil,
                    paltaAPIKey: String? = nil,
                    additionalTargets: [Target] = []) {

            self.name = name
            self.amplitudeAPIKey = amplitudeAPIKey
            self.paltaAPIKey = paltaAPIKey
            self.additionalTargets = additionalTargets
        }
    }
}
