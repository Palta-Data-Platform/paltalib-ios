//
//  PaymentsAssembly.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaLibCore

protocol PaymentsAssembly {
    var paidFeaturesService: PaidFeaturesService { get }
}

final class RealPaymentsAssembly: PaymentsAssembly {
    var paidFeaturesService: PaidFeaturesService {
        webPaymentsAssembly.paidFeaturesService
    }
    
    private let coreAssembly = CoreAssembly()
    private lazy var webPaymentsAssembly = WebPaymentsAssembly(coreAssembly: coreAssembly)
}
