//
//  EventStorage2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

protocol EventStorage2 {
    func storeEvent(_ event: BatchEvent)
    func removeEvent(_ event: BatchEvent)

    func loadEvents(_ completion: @escaping ([BatchEvent]) -> Void)
}

final class EventStorage2Impl: EventStorage2 {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
//    private let folderURL: URL
//    private let stack: Stack
//    private let fileManager: FileManager
    
    
    func storeEvent(_ event: BatchEvent) {
        print("Store event")
    }
    
    func removeEvent(_ event: BatchEvent) {
        print("Remove event")
    }
    
    func loadEvents(_ completion: @escaping ([BatchEvent]) -> Void) {
        print("Load events")
        completion([])
    }
    
    
}
