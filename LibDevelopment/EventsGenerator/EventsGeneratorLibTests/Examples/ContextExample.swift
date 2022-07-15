//  

import Foundation
import PaltaLibAnalytics
import PaltaAnlyticsTransport

public struct Context: BatchContext {
    public var application: Application

    public var device: Device

    internal var message: PaltaAnlyticsTransport.Context {
        get {
            PaltaAnlyticsTransport.Context.with {
                $0.application = application.message
                $0.device = device.message
            }
        }
    } 

    public init() {
        application = Application()
        device = Device()
    }

    public init(data: Data) throws {
        let proto = try PaltaAnlyticsTransport.Context(serializedData: data)
        application = Application(message: proto.application)
        device = Device(message: proto.device)
    }

    public func serialize() throws -> Data {
        try message.serializedData()
    }
}

extension Context {
    public struct Application {
        internal var message: ContextApplication

        public init(message: ContextApplication) {
            self.message = message
        }

        public init(appID: String = "", appVersion: String = PaltaAnalytics.deviceInfoProvider.appVersion) {
            message = .init()
            message.appID = appID
            message.appVersion = appVersion
        }
    }

    public struct Device {
        internal var message: ContextDevice

        public init(message: ContextDevice) {
            self.message = message
        }

        public init(deviceBrand: String = "Apple", deviceModel: String = PaltaAnalytics.deviceInfoProvider.deviceModel) {
            message = .init()
            message.deviceBrand = deviceBrand
            message.deviceModel = deviceModel
        }
    }
}
