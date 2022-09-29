//
//  BackgroundNotifierTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/09/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class BackgroundNotifierTests: XCTestCase {
    private var notifier: BackgroundNotifierImpl!
    private var notificationCenter: NotificationCenter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        notificationCenter = NotificationCenter()
        notifier = BackgroundNotifierImpl(notificationCenter: notificationCenter)
    }
    
    func testSimpleCase() {
        let blockCalled = expectation(description: "Block called")
        
        notifier.addListener {
            blockCalled.fulfill()
        }
        
        notificationCenter.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: NSObject()
        )
        
        wait(for: [blockCalled], timeout: 0.1)
    }
    
    func testConcurrentListenersAdd() {
        let blockCalled = expectation(description: "Block called")
        blockCalled.expectedFulfillmentCount = 10
        
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            notifier.addListener {
                blockCalled.fulfill()
            }
        }
        
        notificationCenter.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: NSObject()
        )
        
        wait(for: [blockCalled], timeout: 0.1)
    }
    
    func testConcurrentNotifications() {
        let blockCalled = expectation(description: "Block called")
        blockCalled.expectedFulfillmentCount = 10
        
        notifier.addListener {
            blockCalled.fulfill()
        }
        
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            notificationCenter.post(
                name: UIApplication.didEnterBackgroundNotification,
                object: NSObject()
            )
        }
        
        wait(for: [blockCalled], timeout: 0.1)
    }
}
