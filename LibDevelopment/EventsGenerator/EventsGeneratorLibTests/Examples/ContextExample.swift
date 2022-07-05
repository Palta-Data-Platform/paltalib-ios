//  

import Foundation
import PaltaAnlyticsTransport

public struct Context: BatchContext {
    public var application: Application

    public var device: Device

    internal var message: Context {
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

    public init(data: Data) {
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

        public init(appID: String, appVersion: String) {
            message = .init()
            message.appID = appID
            message.app_version = appVersion
        }
    }

    public struct Device {
        internal var message: ContextDevice

        public init(deviceBrand: String, deviceModel: String) {
            message = .init()
            message.device_brand = deviceBrand
            message.device_model = deviceModel
        }
    }
}
