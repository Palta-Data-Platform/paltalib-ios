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
    
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow
}

final class RealPaymentsAssembly: PaymentsAssembly {
    var paidFeaturesService: PaidFeaturesService {
        webPaymentsAssembly.paidFeaturesService
    }
    
    private let coreAssembly: CoreAssembly
    private let webPaymentsAssembly: WebPaymentsAssembly
    private let showcaseAssembly: ShowcaseAssembly
    
    private init(
        coreAssembly: CoreAssembly,
        webPaymentsAssembly: WebPaymentsAssembly,
        showcaseAssembly: ShowcaseAssembly
    ) {
        self.coreAssembly = coreAssembly
        self.webPaymentsAssembly = webPaymentsAssembly
        self.showcaseAssembly = showcaseAssembly
    }
    
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow {
        showcaseAssembly.makeShowcaseFlow(userId: userId)
    }
}

extension RealPaymentsAssembly {
    convenience init(apiKey: String, environment: Environment) {
        let core = CoreAssembly()
        let webPayments = WebPaymentsAssembly(apiKey: apiKey, environment: environment, coreAssembly: core)
        let showcaseAssembly = ShowcaseAssemblyImpl(environment: environment, coreAssembly: core)
        
        self.init(coreAssembly: core, webPaymentsAssembly: webPayments, showcaseAssembly: showcaseAssembly)
    }
}
