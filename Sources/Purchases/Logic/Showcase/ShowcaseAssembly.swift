//
//  ShowcaseAssembly.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 24/08/2022.
//

import Foundation
import PaltaLibCore

protocol ShowcaseAssembly {
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow
}

final class ShowcaseAssemblyImpl: ShowcaseAssembly {
    let showcaseService: ShowcaseService
    let appstoreProductService: AppstoreProductService
    
    init(showcaseService: ShowcaseService, appstoreProductService: AppstoreProductService) {
        self.showcaseService = showcaseService
        self.appstoreProductService = appstoreProductService
    }
    
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow {
        ShowcaseFlowImpl(
            userId: userId,
            showcaseService: showcaseService,
            appStoreProductsService: appstoreProductService
        )
    }
}

extension ShowcaseAssemblyImpl {
    convenience init(environment: Environment, coreAssembly: CoreAssembly) {
        let showcaseService = ShowcaseServiceImpl(
            environment: environment,
            httpClient: coreAssembly.httpClient
        )
        
        let appstoreProductService = AppstoreProductServiceImpl(mapper: AppstoreProductMapperImpl())
        
        self.init(showcaseService: showcaseService, appstoreProductService: appstoreProductService)
    }
}
