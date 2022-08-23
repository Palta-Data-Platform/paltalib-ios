//
//  AppstoreProductServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 22/08/2022.
//

import Foundation
@testable import PaltaLibPayments

final class AppstoreProductServiceMock: AppstoreProductService {
    var result: Result<[Product], PaymentsError>?
    var ids: Set<String>?
    
    func retrieveProducts(with ids: Set<String>, completion: @escaping (Result<[Product], PaymentsError>) -> Void) {
        self.ids = ids
        
        if let result = result {
            completion(result)
        }
    }
}
