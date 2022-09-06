//
//  ReceiptProvider.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 06/09/2022.
//

import Foundation

protocol ReceiptProvider {
    func getReceiptData() -> Data?
}

final class ReceiptProviderImpl: ReceiptProvider {
    func getReceiptData() -> Data? {
        Bundle.main.appStoreReceiptURL.flatMap { try? Data(contentsOf: $0) }
    }
}
