//
//  IdentifiableEvent.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/06/2022.
//

import Foundation

struct IdentifiableEvent {
    let id: UUID
    let event: BatchEvent
}
