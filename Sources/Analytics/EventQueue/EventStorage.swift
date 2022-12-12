//
//  EventStorage.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

protocol EventStorage {
    func storeEvent(_ event: Event)
    func removeEvent(_ event: Event)

    func loadEvents(_ completion: @escaping ([Event]) -> Void)
}
