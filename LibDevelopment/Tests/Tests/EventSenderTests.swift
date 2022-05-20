//
//  EventSenderTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import XCTest
@testable import PaltaLibCore
@testable import PaltaLibAnalytics

final class EventSenderTests: XCTestCase {
    let events: [Event] = [.mock()]

    var httpClientMock: HTTPClientMock!
    var eventSender: EventSenderImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        httpClientMock = HTTPClientMock()
        eventSender = EventSenderImpl(httpClient: httpClientMock)
        eventSender.apiToken = "mockToken"
    }
    
    func testSuccessfulRequest() {
        httpClientMock.result = .success(EmptyResponse())
        let successCalled = expectation(description: "Success called")
        
        eventSender.baseURL = URL(string: "http://mock.com")

        eventSender.sendEvents(events, telemetry: .mock()) { result in
            switch result {
            case .success:
                successCalled.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [successCalled], timeout: 0.05)
        XCTAssertEqual(
            httpClientMock.request as? AnalyticsHTTPRequest,
            AnalyticsHTTPRequest.sendEvents(
                URL(string: "http://mock.com"),
                SendEventsPayload(apiKey: "mockToken", events: events, serviceInfo: .init(telemetry: .mock()))
            )
        )
    }

    func testNoInternet() {
        httpClientMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.notConnectedToInternet)))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events, telemetry: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .noInternet)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.05)
    }

    func testTimeout() {
        httpClientMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.timedOut)))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events, telemetry: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .timeout)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.05)
    }

    func test400() {
        httpClientMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(422, nil))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events, telemetry: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .badRequest)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.05)
    }

    func test500() {
        httpClientMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(501, nil))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events, telemetry: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .serverError)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.05)
    }

    func testUnknownError() {
        httpClientMock.result = .failure(NetworkErrorWithoutResponse.other(NSError(domain: "Some domain", code: 1001, userInfo: nil)))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events, telemetry: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .unknown)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.05)
    }
}
