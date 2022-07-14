//  

import PaltaLibAnalytics
import PaltaAnlyticsTransport

public struct EdgeCaseEvent: PaltaLibAnalytics.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader

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
        header: EventHeader = .init(),
        propBoolean: Bool = false,
        propBooleanArray: [Bool] = [],
        propDecimal1: Decimal = 0,
        propDecimal2: Decimal = 0,
        propDecimalArray: [Decimal] = [],
        propEnum: Result = Result(rawValue: 0),
        propEnumArray: [Result] = [],
        propInteger: Int = 0,
        propIntegerArray: [Int] = [],
        propString: String = "",
        propStringArray: [String] = [],
        propTimestamp: Int = 0,
        propTimestampArray: [Int] = []
    ) {
        self.header = header
        self._payload = EventPayloadEdgeCase.with {
            $0.propBoolean = propBoolean
            $0.propBooleanArray = propBooleanArray.map { $0 }
            $0.propDecimal1 = String(describing: propDecimal1)
            $0.propDecimal2 = String(describing: propDecimal2)
            $0.propDecimalArray = propDecimalArray.map { String(describing: $0) }
            $0.propEnum = propEnum.rawValue
            $0.propEnumArray = propEnumArray.map { $0.rawValue }
            $0.propInteger = Int64(propInteger)
            $0.propIntegerArray = propIntegerArray.map { Int64($0) }
            $0.propString = propString
            $0.propStringArray = propStringArray.map { $0 }
            $0.propTimestamp = Int64(propTimestamp)
            $0.propTimestampArray = propTimestampArray.map { Int64($0) }
        }
    }
}

public struct OnboardingFinishEvent: PaltaLibAnalytics.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader

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

    public init(header: EventHeader = .init()) {
        self.header = header
        self._payload = EventPayloadOnboardingFinish.with { _ in
        }
    }
}

public struct OnboardingStartEvent: PaltaLibAnalytics.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader

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

    public init(header: EventHeader = .init()) {
        self.header = header
        self._payload = EventPayloadOnboardingStart.with { _ in
        }
    }
}

public struct PageOpenEvent: PaltaLibAnalytics.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader

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

    public init(header: EventHeader = .init(), pageID: String = "") {
        self.header = header
        self._payload = EventPayloadPageOpen.with {
            $0.pageID = pageID
        }
    }
}

public struct PermissionsRequestEvent: PaltaLibAnalytics.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader

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

    public init(header: EventHeader = .init(), isGranted: Bool = false, type: String = "") {
        self.header = header
        self._payload = EventPayloadPermissionsRequest.with {
            $0.isGranted = isGranted
            $0.type = type
        }
    }
}

public struct SessionStartEvent: PaltaLibAnalytics.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader

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

    public init(header: EventHeader = .init()) {
        self.header = header
        self._payload = EventPayloadSessionStart.with { _ in
        }
    }
}
