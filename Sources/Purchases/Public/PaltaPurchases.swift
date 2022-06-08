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
        
        let group = DispatchGroup()
        var error: Error?
        let lock = NSRecursiveLock()
        
        plugins.forEach {
            group.enter()
            $0.logIn(appUserId: appUserId) {
                if case let .failure(err) = $0, error == nil {
                    lock.lock()
                    error = err
                    lock.unlock()
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(error.map { .failure($0) } ?? .success(()))
        }
    }
    
    public func logOut() {
        checkSetupFinished()
        
        plugins.forEach {
            $0.logOut()
        }
    }
    
    public func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        checkSetupFinished()
        
        var features = PaidFeatures()
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        let lock = NSRecursiveLock()
        
        plugins.forEach { plugin in
            dispatchGroup.enter()
            plugin.getPaidFeatures { result in
                lock.lock()
                switch result {
                case .success(let pluginFeatures):
                    features.merge(with: pluginFeatures)
                    
                case .failure(let error):
                    errors.append(error)
                }
                lock.unlock()
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = errors.first {
                completion(.failure(error))
            } else {
                completion(.success(features))
            }
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
    
    public func restorePurchases() {
        checkSetupFinished()
        
        plugins.forEach {
            $0.restorePurchases()
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
                // TODO: Improve error handling
                completion(.failure(NSError(domain: "", code: 0)))
            }
        }
    }

    private func checkSetupFinished() {
        if !setupFinished {
            assertionFailure("Setup palta purchases with plugins first!")
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
