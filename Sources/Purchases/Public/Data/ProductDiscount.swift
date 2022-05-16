//
//  ProductDiscount.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 08.05.2022.
//

import Foundation

public protocol ProductDiscount {
    var offerIdentifier: String? { get }
    var currencyCode: String? { get }
    var price: Decimal { get }
    var numberOfPeriods: Int { get }
}
