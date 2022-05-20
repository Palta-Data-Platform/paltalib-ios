//
//  AmplitudeExtensionTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 17/05/2022.
//

import XCTest
import Foundation
import Amplitude
@testable import PaltaLibAnalytics

final class AmplitudeExtensionTests: XCTestCase {
    private var middleware: Middleware!
    private var instance: Amplitude!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        middleware = Middleware()
        instance = Amplitude()
        
        instance.initializeApiKey("api-key")
        instance.addEventMiddleware(middleware)
    }
    
    func testApplyTargetWithoutURL() {
        let target = ConfigTarget(
            name: .amplitude,
            settings: ConfigSettings(
                eventUploadThreshold: 23,
                eventUploadMaxBatchSize: 67,
                eventMaxCount: 89,
                eventUploadPeriodSeconds: 12,
                minTimeBetweenSessionsMillis: 79,
                trackingSessionEvents: true,
                realtimeEventTypes: ["real-time"],
                excludedEventTypes: ["excluded"],
                sendMechanism: .paltaBrain
            ),
            url: nil
        )
        
        instance.apply(target)
        
        XCTAssertEqual(instance.eventUploadThreshold, 23)
        XCTAssertEqual(instance.eventUploadMaxBatchSize, 67)
        XCTAssertEqual(instance.eventMaxCount, 89)
        XCTAssertEqual(instance.eventUploadPeriodSeconds, 12)
        XCTAssertEqual(instance.minTimeBetweenSessionsMillis, 79)
        XCTAssertEqual(instance.trackingSessionEvents, true)
        XCTAssertEqual(instance.excludedEvents, ["excluded"])
        
        XCTAssertEqual(instance.value(forKey: "serverUrl") as? String, "https://api2.amplitude.com/")
    }
    
    func testApplyTargetWithURL() {
        let target = ConfigTarget(
            name: .amplitude,
            settings: ConfigSettings(
                eventUploadThreshold: 98,
                eventUploadMaxBatchSize: 234,
                eventMaxCount: 12,
                eventUploadPeriodSeconds: 15,
                minTimeBetweenSessionsMillis: 87,
                trackingSessionEvents: true,
                realtimeEventTypes: ["real-time"],
                excludedEventTypes: ["excluded-event"],
                sendMechanism: .paltaBrain
            ),
            url: URL(string: "http://example.com")
        )
        
        instance.apply(target)
        
        XCTAssertEqual(instance.eventUploadThreshold, 98)
        XCTAssertEqual(instance.eventUploadMaxBatchSize, 234)
        XCTAssertEqual(instance.eventMaxCount, 12)
        XCTAssertEqual(instance.eventUploadPeriodSeconds, 15)
        XCTAssertEqual(instance.minTimeBetweenSessionsMillis, 87)
        XCTAssertEqual(instance.trackingSessionEvents, true)
        XCTAssertEqual(instance.excludedEvents, ["excluded-event"])
        
        XCTAssertEqual(instance.value(forKey: "serverUrl") as? String, "http://example.com")
    }
    
    func testExcludedEvent() {
        instance.excludedEvents = ["excluded-event"]
        let middlewareNotCalled = expectation(description: "Middleware not called")
        middlewareNotCalled.isInverted = true
        middleware.middlewareCalled = middlewareNotCalled.fulfill
        
        instance.pb_logEvent(eventType: "excluded-event")
        
        wait(for: [middlewareNotCalled], timeout: 0.5)
    }
    
    func testNotExcludedEvent() {
        instance.excludedEvents = ["excluded-event"]
        let middlewareCalled = expectation(description: "Middleware called")
        middleware.middlewareCalled = middlewareCalled.fulfill
        
        instance.pb_logEvent(eventType: "not-excluded-event")
        
        wait(for: [middlewareCalled], timeout: 0.5)
    }
}

private final class Middleware: NSObject, AMPMiddleware {
    var middlewareCalled: (() -> Void)?
    
    func run(_ payload: AMPMiddlewarePayload, next: @escaping AMPMiddlewareNext) {
        middlewareCalled?()
        next(payload)
    }
}
