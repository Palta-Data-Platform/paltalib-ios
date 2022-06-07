//
//  EventStorage2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

protocol EventStorage2 {
    func storeEvent(_ event: BatchEvent)
    func removeEvent(_ event: BatchEvent)

    func loadEvents(_ completion: @escaping ([BatchEvent]) -> Void)
}
