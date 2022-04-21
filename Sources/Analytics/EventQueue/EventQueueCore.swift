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
    let maxConcurrentOperations: Int
}

protocol EventQueueCore: AnyObject {
    typealias UploadHandler = (ArraySlice<Event>, @escaping () -> Void) -> Void
    typealias RemoveHandler = (ArraySlice<Event>) -> Void

    var sendHandler: UploadHandler? { get set }
    var removeHandler: RemoveHandler? { get set }

    func addEvent(_ event: Event)
    func addEvents(_ events: [Event])
}

final class EventQueueCoreImpl: EventQueueCore, FunctionalExtension {
    var sendHandler: UploadHandler?
    var removeHandler: RemoveHandler?

    var isPaused = false

    var config: EventQueueConfig? {
        didSet {
            onNewEvents()
        }
    }

    private var operationsInProgress = 0 {
        didSet {
            if
                let maxOperations = config?.maxConcurrentOperations,
                oldValue >= maxOperations,
                operationsInProgress < maxOperations
            {
                resumeOperations()
            }
        }
    }

    private var events: [Event] = []

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

    private func insert(_ event: Event) {
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

        removeHandler?(strippedEvents)
    }

    private func scheduleTimerIfNeeded() {
        guard timerToken == nil, let config = config else {
            return
        }

        timerToken = timer.scheduleTimer(timeInterval: config.uploadInterval, on: workingQueue) { [unowned self] in
            timerFired = true
            attemptFlush()
        }
    }

    private func flushIfNeededByCount() {
        guard let config = config, events.count >= config.uploadThreshold else {
            return
        }

        attemptFlush()
    }

    private func resumeOperations() {
        if timerFired {
            attemptFlush()
        } else {
            flushIfNeededByCount()
        }
    }

    private func attemptFlush() {
        guard let config = config, config.maxConcurrentOperations > operationsInProgress else {
            return
        }

        flush()
    }

    private func flush() {
        assert(Thread.callStackSymbols[1].contains("attemptFlush"))

        timerFired = false

        guard let config = config else {
            assertionFailure("Flush shouldn't be called unless we have a config")
            return
        }

        let batchSize = config.maxBatchSize
        let batchesCount = events.count / batchSize + (events.count % batchSize > 0 ? 1 : 0)

        var lastUploadedIndex: Int?

        for batchIndex in 0..<batchesCount {
            guard operationsInProgress < config.maxConcurrentOperations else {
                break
            }

            let start = batchIndex * batchSize
            let end = min(events.count, (batchIndex + 1) * batchSize)
            lastUploadedIndex = end

            operationsInProgress += 1
            sendHandler?(events[start..<end], { [weak self] in
                self?.workingQueue.async {
                    self?.operationsInProgress -= 1
                }
            })
        }

        events = lastUploadedIndex.map { Array(events.suffix(from: $0)) } ?? events

        if events.isEmpty {
            timerToken = nil
        }
    }
}
