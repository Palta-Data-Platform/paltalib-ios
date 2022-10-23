//
//  EventQueueCore.swift
//  
//
//  Created by Vyacheslav Beltyukov on 31.03.2022.
//

import Foundation
import PaltaLibCore

struct EventQueueConfig {
    let maxBatchSize: Int
    let uploadInterval: TimeInterval
    let uploadThreshold: Int
    let maxEvents: Int
}

protocol EventQueueCore: AnyObject {
    typealias UploadHandler = (ArraySlice<Event>, Telemetry) -> Bool
    typealias RemoveHandler = (ArraySlice<Event>) -> Void

    var sendHandler: UploadHandler? { get set }
    var removeHandler: RemoveHandler? { get set }

    func addEvent(_ event: Event)
    func addEvents(_ events: [Event])
    
    func sendEventsAvailable()
    func forceFlush()
}

final class EventQueueCoreImpl: EventQueueCore, FunctionalExtension {
    var sendHandler: UploadHandler?
    var removeHandler: RemoveHandler?

    var isPaused = false
    
    private(set) var config: EventQueueConfig? {
        didSet {
            onNewEvents()
        }
    }

    private var events: [Event] = []

    private var droppedEventsCount = 0

    private var timerFired = false

    private var timerToken: TimerToken? {
        didSet {
            oldValue?.cancel()
        }
    }

    private let workingQueue = DispatchQueue(label: "com.paltabrain.analytics.eventQueueCore")
    private let timer: Timer

    init(timer: Timer) {
        self.timer = timer
    }

    func addEvent(_ event: Event) {
        workingQueue.async {
            self.insert(event)
            self.onNewEvents()
        }
    }

    func addEvents(_ events: [Event]) {
        workingQueue.async {
            events.forEach(self.insert)
            self.onNewEvents()
        }
    }
    
    func sendEventsAvailable() {
        workingQueue.async { [self] in
            if timerFired {
                flush()
            } else {
                flushIfNeededByCount()
            }
        }
    }
    
    func apply(_ config: EventQueueConfig) {
        workingQueue.async {
            self.config = config
        }
    }
    
    func forceFlush() {
        workingQueue.async { [self] in
            flush()
        }
    }
    
    #if DEBUG
    func addBarrier(_ block: @escaping () -> Void) {
        workingQueue.async(flags: .barrier, execute: block)
    }
    #endif

    private func insert(_ event: Event) {
        let index = events.lastIndex(where: { $0.timestamp > event.timestamp }) ?? 0
        events.insert(event, at: index)
    }

    private func onNewEvents() {
        stripEventsIfNeeded()
        scheduleTimerIfNeeded()
        flushIfNeededByCount()
    }

    private func stripEventsIfNeeded() {
        guard let config = config, events.count > config.maxEvents else {
            return
        }

        let strippedEvents = events.suffix(from: config.maxEvents)
        events = Array(events.prefix(config.maxEvents))

        droppedEventsCount += strippedEvents.count
        removeHandler?(strippedEvents)
    }

    private func scheduleTimerIfNeeded() {
        guard timerToken == nil, let config = config else {
            return
        }

        timerToken = timer.scheduleTimer(timeInterval: config.uploadInterval, on: workingQueue) { [weak self] in
            self?.timerFired = true
            self?.flush()
        }
    }

    private func flushIfNeededByCount() {
        guard let config = config, events.count >= config.uploadThreshold else {
            return
        }

        flush()
    }

    private func flush() {
        let timerWasFired = timerFired
        timerFired = false

        guard let config = config else {
            assertionFailure("Flush shouldn't be called unless we have a config")
            return
        }

        let batchSize = config.maxBatchSize
        let range = max(0, events.count - batchSize)..<events.count
        
        let telemetry = Telemetry(
            eventsInBatch: range.count,
            batchLoad: Double(range.count) / Double(batchSize),
            eventsDroppedSinceLastBatch: droppedEventsCount
        )

        let batchEvents = events[range]
        let batchFormed = sendHandler?(batchEvents, telemetry) ?? false

        guard batchFormed else {
            timerFired = timerWasFired
            return
        }
        
        droppedEventsCount = 0

        events = Array(events.prefix(upTo: range.lowerBound))

        if events.isEmpty {
            timerToken = nil
        }
    }
}
