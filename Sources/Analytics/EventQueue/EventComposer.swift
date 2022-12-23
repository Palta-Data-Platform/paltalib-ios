//
//  EventComposer.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation
import PaltaLibCore
import Amplitude

protocol EventComposer {
    func composeEvent(
        eventType: String,
        eventProperties: [String: Any],
        apiProperties: [String: Any],
        groups: [String: Any],
        userProperties: [String: Any],
        groupProperties: [String: Any],
        timestamp: Int?,
        sessionId: Int?
    ) -> Event
}

final class EventComposerImpl: EventComposer {
    private let timezoneFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        return formatter
    }()

    private var trackingOptions: AMPTrackingOptions {
        trackingOptionsProvider.trackingOptions
    }
    
    private let sequenceNumberProvider = SequenceNumberProvider()

    private let sessionIdProvider: SessionIdProvider
    private let userPropertiesProvider: UserPropertiesProvider
    private let deviceInfoProvider: DeviceInfoProvider
    private let trackingOptionsProvider: TrackingOptionsProvider

    init(
        sessionIdProvider: SessionIdProvider,
        userPropertiesProvider: UserPropertiesProvider,
        deviceInfoProvider: DeviceInfoProvider,
        trackingOptionsProvider: TrackingOptionsProvider
    ) {
        self.sessionIdProvider = sessionIdProvider
        self.userPropertiesProvider = userPropertiesProvider
        self.deviceInfoProvider = deviceInfoProvider
        self.trackingOptionsProvider = trackingOptionsProvider
    }

    func composeEvent(
        eventType: String,
        eventProperties: [String: Any],
        apiProperties: [String: Any],
        groups: [String: Any],
        userProperties: [String: Any],
        groupProperties: [String: Any],
        timestamp: Int?,
        sessionId: Int?
    ) -> Event {
        let timestamp = timestamp ?? .currentTimestamp()

        let platform = trackingOptions.shouldTrackPlatform() ? "iOS" : nil
        let osName = trackingOptions.shouldTrackOSName() ? "ios" : nil
        let deviceManufacturer = trackingOptions.shouldTrackDeviceManufacturer() ? "Apple" : nil
        let appVersion = trackingOptions.shouldTrackVersionName() ? deviceInfoProvider.appVersion : nil
        let osVersion = trackingOptions.shouldTrackOSVersion() ? deviceInfoProvider.osVersion : nil
        let deviceModel = trackingOptions.shouldTrackDeviceModel() ? deviceInfoProvider.deviceModel : nil
        let carrier = trackingOptions.shouldTrackCarrier() ? deviceInfoProvider.carrier : nil
        let country = trackingOptions.shouldTrackCountry() ? deviceInfoProvider.country : nil
        let language = trackingOptions.shouldTrackLanguage() ? deviceInfoProvider.language : nil
        let timezone = "GMT\(timezoneFormatter.string(from: deviceInfoProvider.timezoneOffset as NSNumber) ?? "")"
        let sessionId = sessionId ?? sessionIdProvider.sessionId

        var apiProperties = apiProperties

        if
            let trackingOptions = trackingOptions.getApiPropertiesTrackingOption() as? [String: Any],
           !trackingOptions.isEmpty
        {
            apiProperties["tracking_options"] = trackingOptions
        }

        return Event(
            eventType: eventType,
            eventProperties: CodableDictionary(eventProperties),
            apiProperties: CodableDictionary(apiProperties),
            userProperties: CodableDictionary(userProperties),
            groups: CodableDictionary(groups),
            groupProperties: CodableDictionary(groupProperties),
            sessionId: sessionId,
            timestamp: timestamp,
            userId: userPropertiesProvider.userId,
            deviceId: userPropertiesProvider.deviceId,
            platform: platform,
            appVersion: appVersion,
            osName: osName,
            osVersion: osVersion,
            deviceModel: deviceModel,
            deviceManufacturer: deviceManufacturer,
            carrier: carrier,
            country: country,
            language: language,
            timezone: timezone,
            insertId: UUID(),
            sequenceNumber: sequenceNumberProvider.getNewSequenceNumber(),
            idfa: trackingOptions.shouldTrackIDFA() ? deviceInfoProvider.idfa : nil,
            idfv: trackingOptions.shouldTrackIDFV() ? deviceInfoProvider.idfv : nil
        )
    }
}

private class SequenceNumberProvider {
    private var currentNumber = UserDefaults.standard.integer(forKey: "sequnce_number") {
        didSet {
            UserDefaults.standard.set(currentNumber, forKey: "sequnce_number")
        }
    }
    
    private let lock = NSRecursiveLock()

    func getNewSequenceNumber() -> Int {
        defer {
            currentNumber += 1
            lock.unlock()
        }
        
        lock.lock()
        return currentNumber
    }
}
