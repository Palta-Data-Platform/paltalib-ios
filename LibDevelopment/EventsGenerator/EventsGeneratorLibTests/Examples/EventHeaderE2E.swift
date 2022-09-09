//  

import Foundation
import PaltaAnlyticsTransport
import PaltaLibAnalyticsModel

public struct EventHeader: PaltaLibAnalyticsModel.EventHeader {
    public var parent: Parent

    internal var message: PaltaAnlyticsTransport.EventHeader {
        get {
            PaltaAnlyticsTransport.EventHeader.with {
                $0.parent = parent.message
            }
        }
    } 

    public init() {
        parent = Parent()
    }

    public init(data: Data) throws {
        let proto = try PaltaAnlyticsTransport.EventHeader(serializedData: data)
        parent = Parent(message: proto.parent)
    }

    public func serialize() throws -> Data {
        try message.serializedData()
    }
}

extension EventHeader {
    public struct Parent {
        internal var message: EventHeaderParent

        fileprivate init(message: EventHeaderParent) {
            self.message = message
        }

        public init(parentElements: [String]? = nil) {
            message = .init()
            

            if let parentElements = parentElements {
                message.parentElements = parentElements.map { $0 }
            }
        }
    }
}
