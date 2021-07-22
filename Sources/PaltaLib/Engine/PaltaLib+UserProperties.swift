import Amplitude

extension PaltaLib {

    public typealias UserProperties = [AnyHashable: Any]

    public func setUserProperties(_ userProperties: UserProperties) {
        amplitudeInstances.forEach {
            $0.setUserProperties(userProperties)
        }
    }
}
