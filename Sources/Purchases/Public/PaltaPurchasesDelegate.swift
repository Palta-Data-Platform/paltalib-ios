//
//  PaltaPurchasesDelegate.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 08/06/2022.
//

import Foundation

public protocol PaltaPurchasesDelegate: AnyObject {
    typealias DefermentCallback = (@escaping (Result<SuccessfulPurchase, Error>) -> Void) -> Void
    
    func purchases(
        _ purchases: PaltaPurchases,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback
    )
}
