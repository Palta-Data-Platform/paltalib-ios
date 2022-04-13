import Amplitude

extension PaltaAnalytics {
    public func setUserId(_ userId: String?) {
        amplitudeInstances.forEach {
            $0.setUserId(userId)
        }

        assembly.analyticsCoreAssembly.userPropertiesKeeper.userId = userId
    }
    
    public func setUserId(_ userId: String?, startNewSession: Bool) {
        amplitudeInstances.forEach {
            $0.setUserId(userId, startNewSession: startNewSession)
        }

        assembly.analyticsCoreAssembly.userPropertiesKeeper.userId = userId

        if startNewSession {
            assembly.analyticsCoreAssembly.sessionManager.startNewSession()
        }
    }

    public func identify(
        _ identify: AMPIdentify,
        outOfSession: Bool = false
    ) {
        amplitudeInstances.forEach {
            $0.identify(
                identify,
                outOfSession: outOfSession
            )
        }

        // TODO
    }

    public func groupIdentify(
        withGroupType: String,
        groupName: NSObject,
        groupIdentify: AMPIdentify,
        outOfSession: Bool = false
    ) {

        amplitudeInstances.forEach {
            $0.groupIdentify(
                withGroupType: withGroupType,
                groupName: groupName,
                groupIdentify: groupIdentify,
                outOfSession: outOfSession
            )
        }

        // TODO
    }
    
    public func setUserProperties(_ userProperties: Dictionary<String, Any>) {
        amplitudeInstances.forEach {
            $0.setUserProperties(userProperties)
        }

        // TODO
    }
    
    @available(*, deprecated, message: "Use `- setUserProperties` instead. In earlier versions of the SDK, `replace: YES` replaced the in-memory userProperties dictionary with the input. However, userProperties are no longer stored in memory, so the flag does nothing.")
    public func setUserProperties(_ userProperties: Dictionary<String, Any>, replace: Bool) {
        setUserProperties(userProperties)
    }
    
    public func clearUserProperties() {
        amplitudeInstances.forEach {
            $0.clearUserProperties()
        }

        // TODO
    }
    
    public func setGroup(_ groupType: String, groupName: NSObject) {
        amplitudeInstances.forEach {
            $0.setGroup(groupType, groupName: groupName)
        }

        // TODO
    }
 
    public func groupIdentifyWithGroupType(_ groupType: String,
                                           groupName: NSObject,
                                           groupIdentify: AMPIdentify) {
        amplitudeInstances.forEach {
            $0.groupIdentify(withGroupType: groupType,
                             groupName: groupName,
                             groupIdentify: groupIdentify)
        }

        // TODO
    }
    
    public func groupIdentifyWithGroupType(_ groupType: String,
                                           groupName: NSObject,
                                           groupIdentify: AMPIdentify,
                                           outOfSession: Bool) {
        amplitudeInstances.forEach {
            $0.groupIdentify(withGroupType: groupType,
                             groupName: groupName,
                             groupIdentify: groupIdentify,
                             outOfSession: outOfSession)
        }

        // TODO
    }

    public func setDeviceId(_ deviceId: String) {
        amplitudeInstances.forEach {
            $0.setDeviceId(deviceId)
        }

        assembly.analyticsCoreAssembly.userPropertiesKeeper.deviceId = deviceId
    }

}
