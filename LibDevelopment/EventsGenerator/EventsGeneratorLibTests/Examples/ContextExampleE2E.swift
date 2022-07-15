//  

import Foundation
import PaltaLibAnalytics
import PaltaAnlyticsTransport

public struct Context: BatchContext {
    public var application: Application

    public var appsflyer: Appsflyer

    public var device: Device

    public var identify: Identify

    public var os: Os

    public var user: User

    internal var message: PaltaAnlyticsTransport.Context {
        get {
            PaltaAnlyticsTransport.Context.with {
                $0.application = application.message
                $0.appsflyer = appsflyer.message
                $0.device = device.message
                $0.identify = identify.message
                $0.os = os.message
                $0.user = user.message
            }
        }
    } 

    public init() {
        application = Application()
        appsflyer = Appsflyer()
        device = Device()
        identify = Identify()
        os = Os()
        user = User()
    }

    public init(data: Data) throws {
        let proto = try PaltaAnlyticsTransport.Context(serializedData: data)
        application = Application(message: proto.application)
        appsflyer = Appsflyer(message: proto.appsflyer)
        device = Device(message: proto.device)
        identify = Identify(message: proto.identify)
        os = Os(message: proto.os)
        user = User(message: proto.user)
    }

    public func serialize() throws -> Data {
        try message.serializedData()
    }
}

extension Context {
    public struct Application {
        internal var message: ContextApplication

        fileprivate init(message: ContextApplication) {
            self.message = message
        }

        public init(appID: String = "", appPlatform: String = "iOS", appVersion: String = PaltaAnalytics.deviceInfoProvider.appVersion) {
            message = .init()
            message.appID = appID
            message.appPlatform = appPlatform
            message.appVersion = appVersion
        }
    }

    public struct Appsflyer {
        internal var message: ContextAppsflyer

        fileprivate init(message: ContextAppsflyer) {
            self.message = message
        }

        public init(appsflyerID: String = "", appsflyerMediaSource: String = "") {
            message = .init()
            message.appsflyerID = appsflyerID
            message.appsflyerMediaSource = appsflyerMediaSource
        }
    }

    public struct Device {
        internal var message: ContextDevice

        fileprivate init(message: ContextDevice) {
            self.message = message
        }

        public init(deviceBrand: String = "Apple", deviceCarrier: String = PaltaAnalytics.deviceInfoProvider.carrier, deviceModel: String = PaltaAnalytics.deviceInfoProvider.deviceModel) {
            message = .init()
            message.deviceBrand = deviceBrand
            message.deviceCarrier = deviceCarrier
            message.deviceModel = deviceModel
        }
    }

    public struct Identify {
        internal var message: ContextIdentify

        fileprivate init(message: ContextIdentify) {
            self.message = message
        }

        public init(gaid: String = "", idfa: String = PaltaAnalytics.deviceInfoProvider.idfa, idfv: String = PaltaAnalytics.deviceInfoProvider.idfv) {
            message = .init()
            message.gaid = gaid
            message.idfa = idfa
            message.idfv = idfv
        }
    }

    public struct Os {
        internal var message: ContextOs

        fileprivate init(message: ContextOs) {
            self.message = message
        }

        public init(osName: String = "iOS", osVersion: String = PaltaAnalytics.deviceInfoProvider.osVersion) {
            message = .init()
            message.osName = osName
            message.osVersion = osVersion
        }
    }

    public struct User {
        internal var message: ContextUser

        fileprivate init(message: ContextUser) {
            self.message = message
        }

        public init(userID: String = "") {
            message = .init()
            message.userID = userID
        }
    }
}
