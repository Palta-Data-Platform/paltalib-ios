//  

import PaltaLibAnalyticsModel
import PaltaAnlyticsTransport

public struct EdgeCaseEvent: PaltaLibAnalyticsModel.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader?

    public var payload: Payload {
        get {
            PaltaAnlyticsTransport.EventPayload.with {
                $0.event6 = _payload
            }
        }
    } 

    public var type: EventType {
        get {
            6
        }
    } 

    private let _payload: EventPayloadEdgeCase

    public init(
        header: EventHeader? = nil,
        propBoolean: Bool? = nil,
        propBooleanArray: [Bool]? = nil,
        propDecimal1: Decimal? = nil,
        propDecimal2: Decimal? = nil,
        propDecimalArray: [Decimal]? = nil,
        propEnum: Result? = nil,
        propEnumArray: [Result]? = nil,
        propInteger: Int? = nil,
        propIntegerArray: [Int]? = nil,
        propString: String? = nil,
        propStringArray: [String]? = nil,
        propTimestamp: Int? = nil,
        propTimestampArray: [Int]? = nil
    ) {
        self.header = header
        self._payload = EventPayloadEdgeCase.with {
            if let propBoolean = propBoolean {
                $0.propBoolean = propBoolean
            }

            if let propBooleanArray = propBooleanArray {
                $0.propBooleanArray = propBooleanArray.map { $0 }
            }

            if let propDecimal1 = propDecimal1 {
                $0.propDecimal1 = String(describing: propDecimal1)
            }

            if let propDecimal2 = propDecimal2 {
                $0.propDecimal2 = String(describing: propDecimal2)
            }

            if let propDecimalArray = propDecimalArray {
                $0.propDecimalArray = propDecimalArray.map { String(describing: $0) }
            }

            if let propEnum = propEnum {
                $0.propEnum = propEnum.rawValue
            }

            if let propEnumArray = propEnumArray {
                $0.propEnumArray = propEnumArray.map { $0.rawValue }
            }

            if let propInteger = propInteger {
                $0.propInteger = Int64(propInteger)
            }

            if let propIntegerArray = propIntegerArray {
                $0.propIntegerArray = propIntegerArray.map { Int64($0) }
            }

            if let propString = propString {
                $0.propString = propString
            }

            if let propStringArray = propStringArray {
                $0.propStringArray = propStringArray.map { $0 }
            }

            if let propTimestamp = propTimestamp {
                $0.propTimestamp = Int64(propTimestamp)
            }

            if let propTimestampArray = propTimestampArray {
                $0.propTimestampArray = propTimestampArray.map { Int64($0) }
            }
        }
    }
}

public struct OnboardingFinishEvent: PaltaLibAnalyticsModel.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader?

    public var payload: Payload {
        get {
            PaltaAnlyticsTransport.EventPayload.with {
                $0.event3 = _payload
            }
        }
    } 

    public var type: EventType {
        get {
            3
        }
    } 

    private let _payload: EventPayloadOnboardingFinish

    public init(header: EventHeader? = nil) {
        self.header = header
        self._payload = EventPayloadOnboardingFinish.with { _ in
        }
    }
}

public struct OnboardingStartEvent: PaltaLibAnalyticsModel.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader?

    public var payload: Payload {
        get {
            PaltaAnlyticsTransport.EventPayload.with {
                $0.event2 = _payload
            }
        }
    } 

    public var type: EventType {
        get {
            2
        }
    } 

    private let _payload: EventPayloadOnboardingStart

    public init(header: EventHeader? = nil) {
        self.header = header
        self._payload = EventPayloadOnboardingStart.with { _ in
        }
    }
}

public struct PageOpenEvent: PaltaLibAnalyticsModel.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader?

    public var payload: Payload {
        get {
            PaltaAnlyticsTransport.EventPayload.with {
                $0.event4 = _payload
            }
        }
    } 

    public var type: EventType {
        get {
            4
        }
    } 

    private let _payload: EventPayloadPageOpen

    public init(header: EventHeader? = nil, pageID: String? = nil) {
        self.header = header
        self._payload = EventPayloadPageOpen.with {
            if let pageID = pageID {
                $0.pageID = pageID
            }
        }
    }
}

public struct PermissionsRequestEvent: PaltaLibAnalyticsModel.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader?

    public var payload: Payload {
        get {
            PaltaAnlyticsTransport.EventPayload.with {
                $0.event5 = _payload
            }
        }
    } 

    public var type: EventType {
        get {
            5
        }
    } 

    private let _payload: EventPayloadPermissionsRequest

    public init(header: EventHeader? = nil, isGranted: Bool? = nil, type: String? = nil) {
        self.header = header
        self._payload = EventPayloadPermissionsRequest.with {
            if let isGranted = isGranted {
                $0.isGranted = isGranted
            }

            if let type = type {
                $0.type = type
            }
        }
    }
}

public struct SessionStartEvent: PaltaLibAnalyticsModel.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader?

    public var payload: Payload {
        get {
            PaltaAnlyticsTransport.EventPayload.with {
                $0.event1 = _payload
            }
        }
    } 

    public var type: EventType {
        get {
            1
        }
    } 

    private let _payload: EventPayloadSessionStart

    public init(header: EventHeader? = nil) {
        self.header = header
        self._payload = EventPayloadSessionStart.with { _ in
        }
    }
}
