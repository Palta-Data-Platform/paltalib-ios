//
//  EventQueueCore2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation
import PaltaLibCore

struct EventQueue2Config {
    let maxBatchSize: Int
    let uploadInterval: TimeInterval
    let uploadThreshold: Int
    let maxEvents: Int
}

protocol EventQueueCore2: AnyObject {
    typealias UploadHandler = (ArraySlice<BatchEvent>, Telemetry) -> Bool
    typealias RemoveHandler = (ArraySlice<BatchEvent>) -> Void

    var sendHandler: UploadHandler? { get set }
    var removeHandler: RemoveHandler? { get set }

    func addEvent(_ event: BatchEvent)
    func addEvents(_ events: [BatchEvent])
    
    func sendEventsAvailable()
}

final class EventQueueCore2Impl: EventQueueCore2, FunctionalExtension {
    var sendHandler: UploadHandler?
    var removeHandler: RemoveHandler?

    var isPaused = false

    var config: EventQueue2Config? {
        didSet {
            onNewEvents()
        }
    }

    private var events: [BatchEvent] = []

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

    func addEvent(_ event: BatchEvent) {
        workingQueue.async {
            self.insert(event)
            self.onNewEvents()
        }
    }

    func addEvents(_ events: [BatchEvent]) {
        workingQueue.async {
            events.forEach(self.insert)
            self.onNewEvents()
        }
    }
    
    func sendEventsAvailable() {
        if timerFired {
            flush()
        } else {
            flushIfNeededByCount()
        }
    }

    private func insert(_ event: BatchEvent) {
        let index = events.lastIndex(where: { $0.timestamp > event.timestamp }) ?? 0
        events.insert(event, at: index)
    }

    private func onNewEvents() {
        stripEventsIfNeeded()
        scheduleTimerIfNeeded()
        flushIfNeededByCount()
    }

    private func onOperationsCountReduced() {
        if timerFired {
            flush()
        } else {
            flushIfNeededByCount()
        }
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

        timerToken = timer.scheduleTimer(timeInterval: config.uploadInterval, on: workingQueue) { [unowned self] in
            timerFired = true
            flush()
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

        let range = 0..<min(batchSize, events.count)

        let telemetry = Telemetry(
            eventsInBatch: range.count,
            batchLoad: Double(range.count) / Double(batchSize),
            eventsDroppedSinceLastBatch: droppedEventsCount
        )

        let batchFormed = sendHandler?(events[range], telemetry) ?? false
        
        guard batchFormed else {
            timerFired = timerWasFired
            return
        }
        
        droppedEventsCount = 0

        events = Array(events.suffix(from: range.upperBound))

        if events.isEmpty {
            timerToken = nil
        }
    }
}

