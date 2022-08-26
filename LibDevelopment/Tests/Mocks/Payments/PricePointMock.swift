//
//  PricePointMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 22/08/2022.
//

import Foundation
@testable import PaltaLibPayments

extension PricePoint {
    static func mock(priority: Int? = nil) -> PricePoint {
        PricePoint(ident: UUID().uuidString, parameters: .init(productId: UUID().uuidString), priority: priority)
    }
}
