//
//  BatchComposer.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

protocol BatchComposer {
    func makeBatch(of events: [BatchEvent], with contextId: UUID) -> Batch
}

final class BatchComposerImpl: BatchComposer {
    private let stack: Stack
    private let uuidGenerator: UUIDGenerator
    private let contextProvider: ContextProvider
    private let userInfoProvider: UserPropertiesProvider
    private let deviceInfoProvider: DeviceInfoProvider
    
    init(
        stack: Stack,
        uuidGenerator: UUIDGenerator,
        contextProvider: ContextProvider,
        userInfoProvider: UserPropertiesProvider,
        deviceInfoProvider: DeviceInfoProvider
    ) {
        self.stack = stack
        self.uuidGenerator = uuidGenerator
        self.contextProvider = contextProvider
        self.userInfoProvider = userInfoProvider
        self.deviceInfoProvider = deviceInfoProvider
    }
    
    func makeBatch(of events: [BatchEvent], with contextId: UUID) -> Batch {
        let common = stack.batchCommon.init(
            instanceId: userInfoProvider.instanceId,
            batchId: uuidGenerator.generateUUID(),
            countryCode: deviceInfoProvider.country ?? "",
            locale: .current,
            utcOffset: Int64(deviceInfoProvider.timezoneOffset)
        )
        
        let batch = stack.batch.init(
            common: common,
            context: contextProvider.context(with: contextId),
            events: events
        )
        
        return batch
    }
}
