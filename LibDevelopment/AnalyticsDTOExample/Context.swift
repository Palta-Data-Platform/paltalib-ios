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
        var message: ContextApplication = .init()
        
        public init(
            appID: String = "",
            appVersion: String = "",
            appPlatform: String = ""
        ) {
            message.appID = appID
            message.appVersion = appVersion
            message.appPlatform = appPlatform
        }
    }
    
    public struct Device {
        var message: ContextDevice = .init()
        
        public init(
            deviceBrand: String = "",
            deviceModel: String = "",
            deviceCarrier: String = ""
        ) {
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
}
