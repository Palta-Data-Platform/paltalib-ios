//
//  ContextReservedFields.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 14/07/2022.
//

import Foundation

private protocol Handler {
    func defaultValue(for fieldName: String, and value: SchemaValue) -> String?
}

final class ContextReservedFields {
    private let handlers: [String: Handler] = [
        "Application": AppFields(),
        "Identify": IdentifyFields(),
        "Device": DeviceFields(),
        "Os": OsFields()
    ]
    
    func initArgument(for field: (String, SchemaValue), in entityName: String) -> Init.Argument {
        return .init(
            label: field.0.snakeCaseToCamelCase,
            type: field.1.type,
            defaultValue: handlers[entityName]?.defaultValue(for: field.0, and: field.1) ?? field.1.defaultValue
        )
    }
}

private let prefix = "PaltaAnalytics.deviceInfoProvider."

private final class AppFields: Handler {
    func defaultValue(for fieldName: String, and value: SchemaValue) -> String? {
        if fieldName == "app_version" {
            return prefix + "appVersion"
        } else if fieldName == "app_platform" {
            return "\"iOS\""
        } else {
            return nil
        }
    }
}

private final class IdentifyFields: Handler {
    func defaultValue(for fieldName: String, and value: SchemaValue) -> String? {
        if fieldName == "idfa" {
            return prefix + "idfa"
        } else if fieldName == "idfv" {
            return prefix + "idfv"
        } else {
            return nil
        }
    }
}

private final class DeviceFields: Handler {
    func defaultValue(for fieldName: String, and value: SchemaValue) -> String? {
        if fieldName == "device_brand" {
            return "\"Apple\""
        } else if fieldName == "device_carrier" {
            return prefix + "carrier"
        } else if fieldName == "device_model" {
            return prefix + "deviceModel"
        } else {
            return nil
        }
    }
}

private final class OsFields: Handler {
    func defaultValue(for fieldName: String, and value: SchemaValue) -> String? {
        if fieldName == "os_name" {
            return "\"iOS\""
        } else if fieldName == "os_version" {
            return prefix + "osVersion"
        } else {
            return nil
        }
    }
}
