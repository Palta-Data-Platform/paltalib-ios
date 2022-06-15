//
//  Stack.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import PaltaLibAnalytics
import ProtobufExample

public extension Stack {
    static let `default` = Stack(
        batchCommon: ProtobufExample.BatchCommon.self,
        context: Context.self,
        batch: ProtobufExample.Batch.self,
        event: ProtobufExample.Event.self
    )
}
