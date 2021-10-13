import Foundation

extension PaltaAttribution {

    struct Configuration {
        let appsFlyerDevKey: String
        let appleAppID: String
        let userID: String?
        let useUninstallSandbox: Bool

        public init(appsFlyerDevKey: String,
                    appleAppID: String,
                    userID: String?,
                    useUninstallSandbox: Bool) {
            self.appsFlyerDevKey = appsFlyerDevKey
            self.appleAppID = appleAppID
            self.userID = userID
            self.useUninstallSandbox = useUninstallSandbox
        }
    }
}
