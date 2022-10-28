//
//  ShowcaseFlow.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 19/08/2022.
//

import Foundation

protocol ShowcaseFlow {
    func start(with completion: @escaping (Result<[Product], PaymentsError>) -> Void)
}

final class ShowcaseFlowImpl: ShowcaseFlow {
    private let userId: UserId
    private let showcaseService: ShowcaseService
    private let appStoreProductsService: AppstoreProductService
    
    private var isInProgress = false
    private let traceId = UUID()
    
    init(userId: UserId, showcaseService: ShowcaseService, appStoreProductsService: AppstoreProductService) {
        self.userId = userId
        self.showcaseService = showcaseService
        self.appStoreProductsService = appStoreProductsService
    }
    
    func start(with completion: @escaping (Result<[Product], PaymentsError>) -> Void) {
        guard !isInProgress else {
            assertionFailure()
            return
        }
        
        isInProgress = true

        showcaseService.getProductIds(for: userId, traceId: traceId) { [self] result in
            switch result {
            case .success(let pricePoints):
                getProducts(for: pricePoints, completion: completion)
            case .failure(let error):
                completion(.failure(error))
                isInProgress = false
            }
        }
    }
    
    private func getProducts(
        for pricePoints: [PricePoint],
        completion: @escaping (Result<[Product], PaymentsError>) -> Void
    ) {
        let idents = makePricePointMap(from: pricePoints).mapValues { $0.ident }
        
        let ids = Set(pricePoints.map { $0.productId })
        appStoreProductsService.retrieveProducts(with: ids, idents: idents) { [self] result in
            switch result {
            case .success(let products):
                matchProducts(products, and: pricePoints, completion: completion)
            case .failure(let error):
                completion(.failure(error))
                isInProgress = false
            }
        }
    }
    
    private func matchProducts(
        _ products: [Product],
        and pricePoints: [PricePoint],
        completion: @escaping (Result<[Product], PaymentsError>) -> Void
    ) {
        let pricePointMap = makePricePointMap(from: pricePoints)
        
        let priorityForProduct: (Product) -> Int = {
            pricePointMap[$0.productIdentifier]?.priority ?? 0
        }
        
        completion(
            .success(products.sorted(by: { priorityForProduct($0) > priorityForProduct($1) }))
        )
    }
    
    private func makePricePointMap(from pricePoints: [PricePoint]) -> [String: PricePoint] {
        Dictionary(
            grouping: pricePoints,
            by: { $0.productId }
        ).compactMapValues { $0.first }
    }
}
