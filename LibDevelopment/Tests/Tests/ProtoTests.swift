//
//  ProtoTests.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 14/06/2022.
//

import Foundation
import XCTest
import AnalyticsDTOExample
@testable import PaltaLibAnalytics

final class ProtoTests: XCTestCase {
    func testSend() {
        let eq: EventQueue2 = {
            fatalError()
        }()
        eq.logEvent(
            PageOpenEvent(
                header: .init(pora: .init(designID: "")),
                pageID: "",
                title: ""
            ),
            outOfSession: false
        )
        let exp = expectation(description: "Finished")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 60) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2000000)
    }
}
