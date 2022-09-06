//
//  ReceiptProviderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 06/09/2022.
//

import Foundation
@testable import PaltaLibPayments

final class ReceiptProviderMock: ReceiptProvider {
    var data: Data?
    
    func getReceiptData() -> Data? {
        data
    }
}
