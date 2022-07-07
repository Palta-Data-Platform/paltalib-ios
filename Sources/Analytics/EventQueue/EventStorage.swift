//
//  EventStorage.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

protocol EventStorage {
    func storeEvent(_ event: StorableEvent)
    func removeEvent(with id: UUID)

    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void)
}

final class EventStorageImpl: EventStorage {
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
        let url = url(for: event.event.id)
        workingQueue.async {
            do {
                let data = try event.serialize()
                try data.write(to: url)
            } catch {
                print("PaltaLib: Analytics: Error storing event: \(error)")
            }
        }
    }
    
    func removeEvent(with id: UUID) {
        let url = url(for: id)
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
    
    private func url(for id: UUID) -> URL {
        folderURL.appendingPathComponent("\(id).event")
    }
}
