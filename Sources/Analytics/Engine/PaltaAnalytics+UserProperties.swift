import Amplitude

extension PaltaAnalytics {

    public func setUserProperties(_ userProperties: [AnyHashable: Any]) {
        guard let userProperties = userProperties as? [String: Any] else {
            assertionFailure("Dictionary must have only String keys")
            return
        }

        setUserProperties(userProperties)
    }
}
