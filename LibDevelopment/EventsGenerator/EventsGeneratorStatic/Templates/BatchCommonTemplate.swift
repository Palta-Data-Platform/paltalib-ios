//
//  BatchCommonTemplate.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import Foundation

struct BatchCommonTemplate: Template {
    var filename: String {
        "BatchCommon"
    }
    
    var imports: [String] {
        [
            "Foundation",
            "PaltaLibAnalyticsModel",
            "PaltaAnlyticsTransport"
        ]
    }
    
    var statements: [Statement] {
        [batchCommonExtension]
    }
    
    private var batchCommonExtension: Statement {
        Extension(
            type: "PaltaAnlyticsTransport.BatchCommon",
            conformances: ["PaltaLibAnalyticsModel.BatchCommon"],
            statements: [
                initt
            ]
        )
    }
    
    private var initt: Statement {
        Init(
            visibility: .public,
            arguments: [
                .init(label: "instanceId", type: ReturnType(type: UUID.self)),
                .init(label: "batchId", type: ReturnType(type: UUID.self)),
                .init(label: "countryCode", type: ReturnType(type: String.self)),
                .init(label: "locale", type: ReturnType(type: Locale.self)),
                .init(label: "utcOffset", type: ReturnType(type: Int64.self))
            ],
            statements: [
                "self.init()\n",
                "self.instanceID = instanceId.uuidString",
                "self.batchID = batchId.uuidString",
                "self.countryCode = countryCode",
                "self.locale = locale.identifier",
                "self.utcOffset = utcOffset"
            ]
        )
    }
}

