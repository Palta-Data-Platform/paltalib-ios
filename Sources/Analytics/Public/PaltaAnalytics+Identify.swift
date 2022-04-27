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

        paltaQueueAssemblies.forEach {
            $0.identityLogger.identify(identify, outOfSession: outOfSession)
        }
    }

    public func groupIdentify(
        withGroupType groupType: String,
        groupName: NSObject,
        groupIdentify: AMPIdentify,
        outOfSession: Bool = false
    ) {

        amplitudeInstances.forEach {
            $0.groupIdentify(
                withGroupType: groupType,
                groupName: groupName,
                groupIdentify: groupIdentify,
                outOfSession: outOfSession
            )
        }

        paltaQueueAssemblies.forEach {
            $0.identityLogger.groupIdentify(
                groupType: groupType,
                groupName: groupName,
                groupIdentify: groupIdentify,
                outOfSession: outOfSession
            )
        }
    }
    
    public func setUserProperties(_ userProperties: Dictionary<String, Any>) {
        amplitudeInstances.forEach {
            $0.setUserProperties(userProperties)
        }

        paltaQueueAssemblies.forEach {
            $0.identityLogger.setUserProperties(userProperties)
        }
    }
    
    @available(*, deprecated, message: "Use `- setUserProperties` instead. In earlier versions of the SDK, `replace: YES` replaced the in-memory userProperties dictionary with the input. However, userProperties are no longer stored in memory, so the flag does nothing.")
    public func setUserProperties(_ userProperties: Dictionary<String, Any>, replace: Bool) {
        setUserProperties(userProperties)
    }
    
    public func clearUserProperties() {
        amplitudeInstances.forEach {
            $0.clearUserProperties()
        }

        paltaQueueAssemblies.forEach {
            $0.identityLogger.clearUserProperties()
        }
    }
    
    public func setGroup(_ groupType: String, groupName: NSObject) {
        amplitudeInstances.forEach {
            $0.setGroup(groupType, groupName: groupName)
        }

        paltaQueueAssemblies.forEach {
            $0.identityLogger.setGroup(groupType: groupType, groupName: groupName)
        }
    }

    @available(*, deprecated, message: "Use groupIdentify(withGroupType:groupName:groupIdentify:outOfSession:) instead")
    public func groupIdentifyWithGroupType(_ groupType: String,
                                           groupName: NSObject,
                                           groupIdentify: AMPIdentify) {
        self.groupIdentify(
            withGroupType: groupType,
            groupName: groupName,
            groupIdentify: groupIdentify,
            outOfSession: false
        )
    }

    @available(*, deprecated, message: "Use groupIdentify(withGroupType:groupName:groupIdentify:outOfSession:) instead")
    public func groupIdentifyWithGroupType(_ groupType: String,
                                           groupName: NSObject,
                                           groupIdentify: AMPIdentify,
                                           outOfSession: Bool) {
        self.groupIdentify(
            withGroupType: groupType,
            groupName: groupName,
            groupIdentify: groupIdentify,
            outOfSession: outOfSession
        )
    }

    public func setDeviceId(_ deviceId: String) {
        amplitudeInstances.forEach {
            $0.setDeviceId(deviceId)
        }

        assembly.analyticsCoreAssembly.userPropertiesKeeper.deviceId = deviceId
    }

}
