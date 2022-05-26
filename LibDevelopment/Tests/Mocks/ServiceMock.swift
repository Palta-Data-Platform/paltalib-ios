//
//  ServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
@testable import PaltaLibPayments

extension Service {
    static func mock() -> Service {
        Service(
            quantity: 1,
            actualFrom: Date(timeIntervalSince1970: 0),
            actualTill: Date(timeIntervalSince1970: 100),
            sku: "sku-mock"
        )
    }
}
