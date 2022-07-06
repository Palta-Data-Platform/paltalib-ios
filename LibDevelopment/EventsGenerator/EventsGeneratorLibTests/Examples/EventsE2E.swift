//  

import PaltaLibAnalytics
import PaltaAnlyticsTransport

extension Int: EventType {
}

extension PaltaAnlyticsTransport.EventPayload: PaltaLibAnalytics.EventPayload {
}

public struct EdgeCaseEvent: Event {
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
        header: EventHeader,
        propBoolean: Bool,
        propBooleanArray: [Bool],
        propDecimal1: NSDecimal,
        propDecimal2: NSDecimal,
        propDecimalArray: [NSDecimal],
        propEnum: Result,
        propEnumArray: [Result],
        propInteger: Int,
        propIntegerArray: [Int],
        propString: String,
        propStringArray: [String],
        propTimestamp: Int,
        propTimestampArray: [Int]
    ) {
        self.header = header
        self._payload = EventPayloadEdgeCase.with {
            $0.prop_boolean = propBoolean
            $0.prop_boolean_array = propBooleanArray
            $0.prop_decimal_1 = propDecimal1
            $0.prop_decimal_2 = propDecimal2
            $0.prop_decimal_array = propDecimalArray
            $0.prop_enum = propEnum
            $0.prop_enum_array = propEnumArray
            $0.prop_integer = propInteger
            $0.prop_integer_array = propIntegerArray
            $0.prop_string = propString
            $0.prop_string_array = propStringArray
            $0.prop_timestamp = propTimestamp
            $0.prop_timestamp_array = propTimestampArray
        }
    }
}

public struct OnboardingFinishEvent: Event {
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

    public init(header: EventHeader) {
        self.header = header
        self._payload = EventPayloadOnboardingFinish.with {
        }
    }
}

public struct OnboardingStartEvent: Event {
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

    public init(header: EventHeader) {
        self.header = header
        self._payload = EventPayloadOnboardingStart.with {
        }
    }
}

public struct PageOpenEvent: Event {
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

    public init(header: EventHeader, pageId: String) {
        self.header = header
        self._payload = EventPayloadPageOpen.with {
            $0.page_id = pageId
        }
    }
}

public struct PermissionsRequestEvent: Event {
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

    public init(header: EventHeader, isGranted: Bool, type: String) {
        self.header = header
        self._payload = EventPayloadPermissionsRequest.with {
            $0.is_granted = isGranted
            $0.type = type
        }
    }
}

public struct SessionStartEvent: Event {
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

    public init(header: EventHeader) {
        self.header = header
        self._payload = EventPayloadSessionStart.with {
        }
    }
}
