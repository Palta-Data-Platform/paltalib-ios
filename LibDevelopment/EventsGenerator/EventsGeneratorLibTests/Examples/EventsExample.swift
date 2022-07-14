//  

import PaltaLibAnalytics
import PaltaAnlyticsTransport

public struct PageOpenEvent: PaltaLibAnalytics.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
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

    public init(header: EventHeader = .init(), pageID: String = "", title: String = "") {
        self.header = header
        self._payload = EventPayloadPageOpen.with {
            $0.pageID = pageID
            $0.title = title
        }
    }
}
