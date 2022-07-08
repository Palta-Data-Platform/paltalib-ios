//  

import Foundation
import PaltaAnlyticsTransport

public struct Context: BatchContext {
    public var application: Application

    public var appsflyer: Appsflyer

    public var device: Device

    public var identify: Identify

    public var os: Os

    public var user: User

    internal var message: Context {
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

    public init(data: Data) {
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

        public init(appId: String, appPlatform: String, appVersion: String) {
            message = .init()
            message.app_id = appId
            message.app_platform = appPlatform
            message.app_version = appVersion
        }
    }

    public struct Appsflyer {
        internal var message: ContextAppsflyer

        public init(appsflyerId: String, appsflyerMediaSource: String) {
            message = .init()
            message.appsflyer_id = appsflyerId
            message.appsflyer_media_source = appsflyerMediaSource
        }
    }

    public struct Device {
        internal var message: ContextDevice

        public init(deviceBrand: String, deviceCarrier: String, deviceModel: String) {
            message = .init()
            message.device_brand = deviceBrand
            message.device_carrier = deviceCarrier
            message.device_model = deviceModel
        }
    }

    public struct Identify {
        internal var message: ContextIdentify

        public init(gaid: String, idfa: String, idfv: String) {
            message = .init()
            message.gaid = gaid
            message.idfa = idfa
            message.idfv = idfv
        }
    }

    public struct Os {
        internal var message: ContextOs

        public init(osName: String, osVersion: String) {
            message = .init()
            message.os_name = osName
            message.os_version = osVersion
        }
    }

    public struct User {
        internal var message: ContextUser

        public init(userId: String) {
            message = .init()
            message.user_id = userId
        }
    }
}
