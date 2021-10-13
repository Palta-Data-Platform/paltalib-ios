import Amplitude

extension PaltaAnalytics {

    public func setUserId(_ userId: String?) {
        amplitudeInstances.forEach {
            $0.setUserId(userId)
        }
    }

    public func identify(_ identify: AMPIdentify,
                         outOfSession: Bool = false) {

        amplitudeInstances.forEach {
            $0.identify(
                identify,
                outOfSession: outOfSession
            )
        }
    }

    public func groupIdentify(withGroupType: String,
                              groupName: NSObject,
                              groupIdentify: AMPIdentify,
                              outOfSession: Bool = false) {

        amplitudeInstances.forEach {
            $0.groupIdentify(
                withGroupType: withGroupType,
                groupName: groupName,
                groupIdentify: groupIdentify,
                outOfSession: outOfSession
            )
        }
    }
}
