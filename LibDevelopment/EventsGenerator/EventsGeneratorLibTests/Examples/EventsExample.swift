//  

import PaltaLibAnalyticsModel
import PaltaAnlyticsTransport

public struct PageOpenEvent: PaltaLibAnalyticsModel.Event {
    public typealias Header = PaltaEvents.EventHeader
    public typealias Payload = PaltaAnlyticsTransport.EventPayload
    public typealias EventType = Int
    public let header: EventHeader?

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

    public init(header: EventHeader? = nil, pageID: String? = nil, title: String? = nil) {
        self.header = header
        self._payload = EventPayloadPageOpen.with {
            if let pageID = pageID {
                $0.pageID = pageID
            }

            if let title = title {
                $0.title = title
            }
        }
    }
}
