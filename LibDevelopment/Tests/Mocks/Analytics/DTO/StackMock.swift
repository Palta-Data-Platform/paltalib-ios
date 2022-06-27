//
//  StackMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 24/06/2022.
//

import Foundation
import PaltaLibAnalytics

extension Stack {
    static let mock = Stack(
        batchCommon: BatchCommonMock.self,
        context: BatchContextMock.self,
        batch: BatchMock.self,
        event: BatchEventMock.self
    )
}
