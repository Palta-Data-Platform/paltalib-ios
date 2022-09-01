//  

import Foundation
import PaltaLibAnalyticsModel
import PaltaAnlyticsTransport

extension PaltaLibAnalyticsModel.EventCommon {
    internal var message: PaltaAnlyticsTransport.EventCommon {
        get {
            var msg = PaltaAnlyticsTransport.EventCommon()
            msg.eventType = eventType.intValue
            msg.eventTs = Int64(timestamp)
            msg.sessionID = Int64(sessionId)
            msg.sessionEventSeqNum = sequenceNumber
            return msg
        }
    } 
}

extension PaltaAnlyticsTransport.Event: BatchEvent {
    public var timestamp: Int {
        get {
            Int(common.eventTs)
        }
    } 

    public init(data: Data) throws {
        try self.init(serializedData: data)
    }

    public init(common: PaltaLibAnalyticsModel.EventCommon, header: PaltaLibAnalyticsModel.EventHeader?, payload: PaltaLibAnalyticsModel.EventPayload) {
        self.init()

        guard let payload = payload as? PaltaAnlyticsTransport.EventPayload else {
            assertionFailure("Mixing up different protobufs")
            return
        }

        if let header = header as? EventHeader {
            self.header = header.message
        }

        self.common = common.message
        self.payload = payload
    }

    public func serialize() throws -> Data {
        try serializedData()
    }
}

extension Int: EventType {
    public var intValue: Int64 {
        get {
            Int64(self)
        }
    } 
}

extension PaltaAnlyticsTransport.EventPayload: PaltaLibAnalyticsModel.EventPayload {
}
