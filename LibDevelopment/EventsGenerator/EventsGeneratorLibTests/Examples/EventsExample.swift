//  

import PaltaLibAnalytics
import PaltaAnlyticsTransport

extension Int: EventType {
}

extension PaltaAnlyticsTransport.EventPayload: PaltaLibAnalytics.EventPayload {
}

public struct PageOpenEvent: Event {
    public let header: EventHeader

    public var payload: Payload {
        get {
            PaltaAnlyticsTransport.EventPayload.with {
                $0.event0 = _payload
            }
        }
    } 

    public var type: EventType {
        get {
            0
        }
    } 

    private let _payload: EventPayloadPageOpen

    public init(header: EventHeader, pageID: String, title: String) {
        self.header = header
        self._payload = EventPayloadPageOpen.with {
            $0.pageID = pageID
            $0.title = title
        }
    }
}
