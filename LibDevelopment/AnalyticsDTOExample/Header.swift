//
//  Header.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import ProtobufExample
import PaltaLibAnalytics

public struct Header: PaltaLibAnalytics.EventHeader {
    public struct Pora {
        let message: EventHeaderPora
        
        public init(designID: String = "") {
            message = EventHeaderPora.with {
                $0.designID = designID
            }
        }
    }
    
    let message: ProtobufExample.EventHeader
    
    public init(pora: Pora = Pora()) {
        message = EventHeader.with {
            $0.pora = pora.message
        }
    }
    
    public init() {
        message = EventHeader()
    }
}
