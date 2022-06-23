//
//  Context.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import ProtobufExample
import PaltaLibAnalytics

public struct Context: BatchContext {
    public struct Application {
        var message: ContextApplication
        
        init(message: ContextApplication) {
            self.message = message
        }
        
        public init(
            appID: String = "",
            appVersion: String = "",
            appPlatform: String = ""
        ) {
            message = .init()
            
            message.appID = appID
            message.appVersion = appVersion
            message.appPlatform = appPlatform
        }
    }
    
    public struct Device {
        var message: ContextDevice
        
        init(message: ContextDevice) {
            self.message = message
        }
        
        public init(
            deviceBrand: String = "",
            deviceModel: String = "",
            deviceCarrier: String = ""
        ) {
            message = .init()
            
            message.deviceBrand = deviceBrand
            message.deviceModel = deviceModel
            message.deviceCarrier = deviceCarrier
        }
    }
    
    public var application: Application
    public var device: Device
    
    var message: ProtobufExample.Context {
        ProtobufExample.Context.with {
            $0.application = application.message
            $0.device = device.message
        }
    }
    
    public init() {
        application = Application()
        device = Device()
    }
    
    public init(data: Data) throws {
        let proto = try ProtobufExample.Context(serializedData: data)
        
        application = Application(message: proto.application)
        device = Device(message: proto.device)
    }
    
    public func serialize() throws -> Data {
        try message.serializedData()
    }
}
