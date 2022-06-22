//
//  EventStorage2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

protocol EventStorage2 {
    func storeEvent(_ event: StorableEvent)
    func removeEvent(_ event: StorableEvent)

    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void)
}

final class EventStorage2Impl: EventStorage2 {
    private let folderURL: URL
    private let stack: Stack
    private let fileManager: FileManager
    
    private let workingQueue = DispatchQueue(
        label: "com.paltabrain.eventstorage",
        qos: .default,
        attributes: .concurrent
    )
    
    init(folderURL: URL, stack: Stack, fileManager: FileManager) {
        self.folderURL = folderURL
        self.stack = stack
        self.fileManager = fileManager
    }
    
    func storeEvent(_ event: StorableEvent) {
        let url = url(for: event)
        workingQueue.async {
            do {
                let data = try event.serialize()
                try data.write(to: url)
            } catch {
                print("PaltaLib: Analytics: Error storing event: \(error)")
            }
        }
    }
    
    func removeEvent(_ event: StorableEvent) {
        let url = url(for: event)
        workingQueue.async { [fileManager] in
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("PaltaLib: Analytics: Error removing event: \(error)")
            }
        }
    }
    
    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void) {
        workingQueue.async(flags: .barrier) { [fileManager, folderURL, stack] in
            do {
                let events = try fileManager
                    .contentsOfDirectory(atPath: folderURL.path)
                    .map { folderURL.appendingPathComponent($0) }
                    .map { try Data(contentsOf: $0) }
                    .compactMap { try? StorableEvent(data: $0, eventType: stack.event) }
                
                completion(events)
            } catch {
                print("PaltaLib: Analytics: Error getting events from disk: \(error)")
            }
        }
    }
    
    #if DEBUG
    func addBarrier(_ barrier: @escaping () -> Void) {
        workingQueue.async(flags: .barrier, execute: barrier)
    }
    #endif
    
    private func url(for event: StorableEvent) -> URL {
        folderURL.appendingPathComponent("\(event.event.id).\(event.contextId).event")
    }
}
