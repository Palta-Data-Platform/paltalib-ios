//
//  PaltaPurchases2.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import PaltaLibCore

public final class PaltaPurchases2 {
    public static let instance = PaltaPurchases2()

    var setupFinished = false
    var plugins: [PurchasePlugin] = []

    public func setup(with plugins: [PurchasePlugin]) {
        guard !setupFinished else {
            assertionFailure("Attempt to setup PaltaPurchases twice")
            return
        }

        setupFinished = true
        self.plugins = plugins
    }
    
    public func logIn(appUserId: String) {
        checkSetupFinished()
        
        plugins.forEach {
            $0.logIn(appUserId: appUserId)
        }
    }
    
    public func logOut() {
        checkSetupFinished()
        
        plugins.forEach {
            $0.logOut()
        }
    }
    
    public func getPaidServices(_ completion: @escaping (Result<PaidServices, Error>) -> Void) {
        checkSetupFinished()
        
        var services = PaidServices()
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        let lock = NSRecursiveLock()
        
        plugins.forEach { plugin in
            dispatchGroup.enter()
            plugin.getPaidServices { result in
                lock.lock()
                switch result {
                case .success(let pluginServices):
                    services.merge(with: pluginServices)
                    
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
                completion(.success(services))
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
    
        guard let firstPlugin = plugins.first else {
            return
        }
        
        getPromotionalOffer(for: productDiscount, product: product, with: firstPlugin, completion)
    }
    
    @available(iOS 12.2, *)
    private func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        with plugin: PurchasePlugin,
        _ completion: @escaping (Result<PromoOffer, Error>) -> Void
    ) {
        plugin.getPromotionalOffer(for: productDiscount, product: product) { [weak self, unowned plugin] pluginResult in
            guard let self = self else {
                return
            }
            
            if let result = pluginResult.result {
                DispatchQueue.main.async {
                    completion(result)
                }
            } else if let nextPlugin = self.plugins.nextElement(after: { $0 === plugin }) {
                self.getPromotionalOffer(for: productDiscount, product: product, with: nextPlugin, completion)
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
