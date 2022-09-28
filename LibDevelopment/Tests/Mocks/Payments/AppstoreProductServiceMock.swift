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
    var idents: [String: String]?
    var ids: Set<String>?
    
    func retrieveProducts(with ids: Set<String>, idents: [String : String], completion: @escaping (Result<[Product], PaymentsError>) -> Void) {
        self.idents = idents
        self.ids = ids
        
        if let result = result {
            completion(result)
        }
    }
}
