//
//  ShowcaseFlowMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 24/08/2022.
//

import Foundation
@testable import PaltaLibPayments

final class ShowcaseFlowMock: ShowcaseFlow {
    var result: Result<[Product], PaymentsError>?
    
    func start(with completion: @escaping (Result<[Product], PaymentsError>) -> Void) {
        if let result = result {
            completion(result)
        }
    }
}
