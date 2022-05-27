//
//  PaymentsAssemblyMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaLibPayments

final class PaymentsAssemblyMock: PaymentsAssembly {
    let paidFeaturesMock = PaidFeaturesServiceMock()
    
    var paidFeaturesService: PaidFeaturesService {
        paidFeaturesMock
    }
}
