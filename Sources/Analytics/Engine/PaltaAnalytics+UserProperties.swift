import Amplitude

extension PaltaAnalytics {

    public func setUserProperties(_ userProperties: [AnyHashable: Any]) {
        amplitudeInstances.forEach {
            $0.setUserProperties(userProperties)
        }
    }
}
