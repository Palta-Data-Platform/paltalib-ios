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
    
    var hashValue: Int { get }
}

extension Optional where Wrapped == ProductDiscount {
    func isEqual(to anotherDiscount: ProductDiscount?) -> Bool {
        self?.offerIdentifier == anotherDiscount?.offerIdentifier
        && self?.currencyCode == anotherDiscount?.currencyCode
        && self?.price == anotherDiscount?.price
        && self?.numberOfPeriods == anotherDiscount?.numberOfPeriods
    }
}
