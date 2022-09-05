//
//  EventStorage.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

protocol EventStorage {
    func storeEvent(_ event: Event)
    func removeEvent(_ event: Event)

    func loadEvents(_ completion: @escaping ([Event]) -> Void)
}

final class FileEventStorage: EventStorage {
    private let fileManager: FileManager = .default

    private lazy var folderURL = try! fileManager.url(
        for: .libraryDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    ).appendingPathComponent("PaltaBrainEventsLegacy")
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.description)
        }
        return encoder
    }()
    private let decoder = JSONDecoder()

    private let workingQueue = DispatchQueue(label: "com.paltabrain.EventStorage", attributes: .concurrent)

    init() {
        if !fileManager.fileExists(atPath: folderURL.path) {
            try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func storeEvent(_ event: Event) {
        workingQueue.async { [self] in
            writeEvent(event)
        }
    }

    func removeEvent(_ event: Event) {
        workingQueue.async { [self] in
            eraseEvent(event)
        }
    }

    func loadEvents(_ completion: @escaping ([Event]) -> Void) {
        workingQueue.async(flags: .barrier) { [self] in
            completion(loadEvents())
        }
    }

    #if DEBUG

    // To debug when working queue is empty
    func addBarrier(_ completion: @escaping () -> Void) {
        workingQueue.async(flags: .barrier, execute: completion)
    }

    #endif

    private func writeEvent(_ event: Event) {
        do {
            let data = try encoder.encode(event)
            try data.write(to: url(for: event))
        } catch {
            print("Error storing event: \(error)")
        }
    }

    private func eraseEvent(_ event: Event) {
        do {
            try fileManager.removeItem(at: url(for: event))
        } catch {
            print("Error removing event: \(error)")
        }
    }

    private func loadEvents() -> [Event] {
        do {
            return try fileManager
                .contentsOfDirectory(atPath: folderURL.path)
                .map { try Data(contentsOf: folderURL.appendingPathComponent($0)) }
                .compactMap { try? decoder.decode(Event.self, from: $0) } // Old malformed events might break all queue
        } catch {
            print("Error loading events: \(error)")
        }

        return []
    }

    private func url(for event: Event) -> URL {
        folderURL.appendingPathComponent("\(event.insertId).event")
    }
}
