//
//  PaltaPurchases.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import PaltaLibCore

public final class PaltaPurchases {
    public static let instance = PaltaPurchases()
    
    public private(set) var userId: UserId?
    
    public weak var delegate: PaltaPurchasesDelegate?

    var setupFinished = false
    var plugins: [PurchasePlugin] = [] {
        didSet {
            plugins.forEach {
                $0.delegate = self
            }
        }
    }

    public func setup(with plugins: [PurchasePlugin]) {
        guard !setupFinished else {
            assertionFailure("Attempt to setup PaltaPurchases twice")
            return
        }

        setupFinished = true
        self.plugins = plugins
    }
    
    public func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void) {
        checkSetupFinished()
        
        callAndCollect(call: { plugin, callback in
            plugin.logIn(appUserId: appUserId, completion: callback)
        }, completion: { [weak self] result in
            switch result {
            case .success:
                self?.userId = appUserId
                
            case .failure:
                // Some plugins definetly failed, but some may be logged in. Need to logout.
                self?.logOut()
            }
            
            completion(result.map { _ in })
        })
    }
    
    public func logOut() {
        checkSetupFinished()
        
        userId = nil
        plugins.forEach {
            $0.logOut()
        }
    }
    
    public func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        checkSetupFinished()
        
        callAndCollectPaidFeatures(to: completion) { plugin, callback in
            plugin.getPaidFeatures(callback)
        }
    }
    
    @available(iOS 12.2, *)
    public func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (Result<PromoOffer, Error>) -> Void
    ) {
        checkSetupFinished()
    
        start(completion: completion) { plugin, completion in
            plugin.getPromotionalOffer(for: productDiscount, product: product, completion)
        }
    }
    
    public func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (Result<SuccessfulPurchase, Error>) -> Void
    ) {
        checkSetupFinished()
        
        start(completion: completion) { plugin, completion in
            plugin.purchase(product, with: promoOffer, completion)
        }
    }
    
    public func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        checkSetupFinished()
        
        callAndCollectPaidFeatures(to: completion) { plugin, callback in
            plugin.restorePurchases(completion: callback)
        }
    }
    
    private func start<T>(
        completion: @escaping (Result<T, Error>) -> Void,
        execute: @escaping (PurchasePlugin, @escaping (PurchasePluginResult<T, Error>) -> Void) -> Void
    ) {
        guard let firstPlugin = plugins.first else {
            return
        }
        
        with(firstPlugin, completion: completion, execute: execute)
    }
    
    private func with<T>(
        _ plugin: PurchasePlugin,
        completion: @escaping (Result<T, Error>) -> Void,
        execute: @escaping (PurchasePlugin, @escaping (PurchasePluginResult<T, Error>) -> Void) -> Void
    ) {
        execute(plugin) { [weak self, unowned plugin] pluginResult in
            guard let self = self else {
                return
            }
            
            if let result = pluginResult.result {
                DispatchQueue.main.async {
                    completion(result)
                }
            } else if let nextPlugin = self.plugins.nextElement(after: { $0 === plugin }) {
                self.with(nextPlugin, completion: completion, execute: execute)
            } else {
                completion(.failure(PaymentsError.sdkError(.noSuitablePlugin)))
            }
        }
    }

    private func checkSetupFinished() {
        if !setupFinished {
            assertionFailure("Setup palta purchases with plugins first!")
        }
    }
    
    private func callAndCollect<T>(
        call: (PurchasePlugin, @escaping (Result<T, Error>) -> Void) -> Void,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var values: [T] = []
        var error: Error?
        
        let lock = NSRecursiveLock()
        let group = DispatchGroup()
        
        plugins.forEach { plugin in
            group.enter()
            call(plugin) { result in
                lock.lock()
                
                switch result {
                case .success(let value):
                    values.append(value)
                    
                case .failure(let err):
                    error = error ?? err
                }
                
                lock.unlock()
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(values))
            }
        }
    }
    
    private func callAndCollectPaidFeatures(
        to completion: @escaping (Result<PaidFeatures, Error>) -> Void,
        call: (PurchasePlugin, @escaping (Result<PaidFeatures, Error>) -> Void) -> Void
    ) {
        callAndCollect(call: call) { result in
            completion(
                result.map {
                    $0.reduce(PaidFeatures()) {
                        $0.merged(with: $1)
                    }
                }
            )
        }
    }
}

extension PaltaPurchases: PurchasePluginDelegate {
    public func purchasePlugin(
        _ plugin: PurchasePlugin,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback
    ) {
        delegate?.purchases(self, shouldPurchase: promoProduct, defermentCallback: { completion in
            defermentCallback {
                switch $0 {
                case .success(let purchase):
                    completion(.success(purchase))
                    
                case .failure(let error):
                    completion(.failure(error))
                    
                case .notSupported:
                    completion(.failure(PaymentsError.sdkError(.other(nil))))
                }
            }
        })
    }
}
