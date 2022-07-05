//  

import Foundation
import PaltaAnlyticsTransport
import PaltaLibAnalytics

public struct Header: PaltaLibAnalytics.EventHeader {
    public var parent: Parent

    internal var message: Context {
        get {
            PaltaAnlyticsTransport.Context.with {
                $0.parent = parent.message
            }
        }
    } 

    public init() {
        parent = Parent()
    }

    public init(data: Data) {
        let proto = try PaltaAnlyticsTransport.EventHeader(serializedData: data)
        parent = Parent(message: proto.eventHeaderParent)
    }

    public func serialize() throws -> Data {
        try message.serializedData()
    }
}

extension Header {
    public struct Parent {
        internal var message: EventHeaderParent

        public init(parentElements: [String]) {
            message = .init()
            message.parent_elements = parentElements.map { $0 }
        }
    }
}
